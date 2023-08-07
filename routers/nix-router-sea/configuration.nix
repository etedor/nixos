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
    nat.enable = false;
    firewall.enable = false;
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

  # extraForwardRules = ''
  #   iifname ${ifaceTrust}     oifname ${ifaceTrust}                       accept
  #   iifname ${ifaceUntrust}   oifname ${ifaceTrust} tcp dport 443         accept
  # '';
  # extraInputRules = ''
  #   iifname ${ifaceTrust}     ip daddr ${options.routerId}  tcp dport 22          accept
  #   iifname ${ifaceTrust}                                   tcp dport 179         accept
  #   iifname ${ifaceUntrust}                                 udp dport ${wgPorts}  accept
  # '';

  networking.nftables =
    let
      ifaceTrustList = [ "wg0" "wg1" ];
      ifaceUntrustList = [ "ens3" ];

      ifaceTrust = "{ ${builtins.concatStringsSep ", " ifaceTrustList} }";
      ifaceUntrust = "{ ${builtins.concatStringsSep ", " ifaceUntrustList} }";

      wgPorts = "{ ${builtins.concatStringsSep ", " (builtins.map toString (builtins.attrValues (builtins.mapAttrs (name: value: value.wireguardConfig.ListenPort) config.systemd.network.netdevs)))} }";

      baseline = import
        ../common/nftables.nix
        {
          extraInputRules = [
            "iifname ${ifaceTrust} ip daddr ${options.routerId} tcp dport 22 accept"
            "iifname ${ifaceTrust} tcp dport 179 accept"
            "iifname ${ifaceUntrust} udp dport ${wgPorts} accept"
          ];
          extraOutputRules = [ ];
          extraForwardRules = [
            "iifname ${ifaceTrust} oifname ${ifaceTrust} accept"

            "iifname ${ifaceUntrust} oifname ${ifaceTrust} tcp dport 443 accept"
            "iifname ${ifaceTrust} oifname ${ifaceUntrust} tcp sport 443 accept"
          ];
          extraPreRoutingRules = [
            "iifname ${ifaceUntrust} tcp dport 443 dnat ip to 10.0.2.91:443"
          ];
          extraPostRoutingRules = [ ];
        };
    in
    {
      enable = true;
      ruleset = ''
        ${baseline}
      '';
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
