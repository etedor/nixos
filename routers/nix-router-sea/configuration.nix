{ config, lib, pkgs, ... }:

let
  options = {
    hostName = "nix-router-sea";
    domainName = "int.tedor.org";
    routerId = "10.127.99.1";
  };
in
{
  system.stateVersion = "23.05";

  imports = [
    ./hardware-configuration.nix
    ../common/router.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  age.secrets = {
    nix-router-sea-wg0 = {
      file = ../../secrets/nix-router-sea-wg0.age;
      mode = "444";
    };
    nix-router-sea-wg1 = {
      file = ../../secrets/nix-router-sea-wg1.age;
      mode = "444";
    };
  };

  networking = {
    hostName = options.hostName;
    domain = options.domainName;
    # Let networkd manage things
    useDHCP = false;
  };

  # https://nixos.wiki/wiki/Systemd-networkd
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/tests/systemd-networkd-ipv6-prefix-delegation.nix#L156
  systemd.network = {
    enable = true;
    netdevs = {
      "10-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
        };
        wireguardConfig = {
          PrivateKeyFile = config.age.secrets.nix-router-sea-wg0.path;
          ListenPort = 51820;
        };
        wireguardPeers = [{
          wireguardPeerConfig = {
            PublicKey = "H1UlGv6+J9r9XfMWTJxzbC5mIUbGTFvZMeHhJAvvRVQ=";
            AllowedIPs = [ "0.0.0.0/0" ];
          };
        }];
      };
      "20-wg1" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg1";
        };
        wireguardConfig = {
          PrivateKeyFile = config.age.secrets.nix-router-sea-wg1.path;
          ListenPort = 51821;
        };
        wireguardPeers = [{
          wireguardPeerConfig = {
            PublicKey = "xBNt1u2PhjNwRdZbGqPUYg89ZgXtK96CdzdgGHBkzgE=";
            AllowedIPs = [ "10.99.1.0/24" ];
          };
        }];
      };
    };
    networks = {
      "01-lo" = {
        name = "lo";
        address = [ options.routerId ];
      };
      "02-ens3" = {
        name = "ens3";
        networkConfig = {
          Description = "WAN interface";
          DHCP = "yes";
        };
      };
      "10-wg0" = {
        matchConfig.Name = "wg0";
        address = [ "10.99.0.0/31" ];
      };
      "20-wg1" = {
        matchConfig.Name = "wg1";
        address = [ "10.99.1.1/24" ];
      };
    };
  };

  networking = {
    # interfaces = {
    #   lo = {
    #     ipv4.addresses = [{
    #       address = routerId;
    #       prefixLength = 32;
    #     }];
    #   };
    # };

    # wireguard.interfaces = {
    #   wg0 = {
    #     ips = [ "10.99.0.0/31" ];
    #     privateKeyFile = config.age.secrets.nix-router-sea-wg0.path;
    #     listenPort = 51820;
    #     allowedIPsAsRoutes = false;
    #     peers = [
    #       {
    #         # vyos-ggz
    #         publicKey = "H1UlGv6+J9r9XfMWTJxzbC5mIUbGTFvZMeHhJAvvRVQ=";
    #         # allowedIPs = [ "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" ];
    #         allowedIPs = [ "0.0.0.0/0" ];
    #       }
    #     ];
    #   };
    #   wg1 = {
    #     ips = [ "10.99.1.1/24" ];
    #     privateKeyFile = config.age.secrets.nix-router-sea-wg1.path;
    #     listenPort = 51821;
    #     allowedIPsAsRoutes = false;
    #     peers = [
    #       {
    #         # pine
    #         publicKey = "xBNt1u2PhjNwRdZbGqPUYg89ZgXtK96CdzdgGHBkzgE=";
    #         allowedIPs = [ "10.99.1.0/24" ];
    #       }
    #     ];
    #   };
    # };

    nftables.enable = true;
    firewall =
      let
        ifaceTrustList = [ "wg0" "wg1" ];
        ifaceUntrustList = [ "ens3" ];

        ifaceTrust = "{ ${builtins.concatStringsSep ", " ifaceTrustList} }";
        ifaceUntrust = "{ ${builtins.concatStringsSep ", " ifaceUntrustList} }";

        wgPorts = "{ ${builtins.concatStringsSep ", " (builtins.map toString (builtins.attrValues (builtins.mapAttrs (name: value: value.wireguardConfig.ListenPort) config.systemd.network.netdevs)))} }";
      in
      {
        enable = true;
        allowPing = true;
        logReversePathDrops = true;
        filterForward = false;
        extraForwardRules = ''
          iifname ${ifaceTrust}     oifname ${ifaceTrust}                       accept
          iifname ${ifaceUntrust}   oifname ${ifaceTrust} tcp dport 443         accept
        '';
        extraInputRules = ''
          iifname ${ifaceTrust}     ip daddr ${options.routerId}  tcp dport 22          accept
          iifname ${ifaceTrust}                                   tcp dport 179         accept
          iifname ${ifaceUntrust}                                 udp dport ${wgPorts}  accept
        '';
      };
    nat = {
      enable = true;
      externalInterface = "ens3";
      internalInterfaces = [ "wg0" "wg1" ];
      internalIPs = [ "10.0.0.0/8" ];
      forwardPorts = [
        { sourcePort = 443; destination = "10.0.2.91:443"; proto = "tcp"; }
      ];
    };
  };
  services.openssh.openFirewall = false;

  services.bird2 =
    let
      baseline = import
        ../common/bird.nix
        { routerId = options.routerId; };
    in
    {
      enable = true;
      config = ''
        ${baseline}

        protocol bgp wg0 {
          local as 65099;
          neighbor 10.99.0.1 as 65000;
          ipv4 {
            import filter rfc1918_v4;
            export filter rfc1918_v4;
          };
        }
      '';
    };
}
