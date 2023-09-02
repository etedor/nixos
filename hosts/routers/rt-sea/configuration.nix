{ config, lib, pkgs, ... }:

let
  options = {
    hostName = "rt-sea";
    domainName = "int.tedor.org";

    extIntf = "ens3";
    localAs = 65099;
    routerId = "10.127.99.1";
  };
in
{
  system.stateVersion = "23.05";
  boot.loader.grub = { enable = true; device = "/dev/vda"; };

  imports = [
    ./hardware-configuration.nix
    ../common/router.nix
  ];

  networking = {
    hostName = options.hostName;
    domain = options.domainName;
    useDHCP = false; # Managed by systemd-networkd
  };

  # We're managing the firewall ourself
  networking = {
    firewall.enable = false;
    nat.enable = false;
  };
  services.openssh.openFirewall = false;

  age.secrets = {
    rt-sea-wg0 = { file = ../../../secrets/rt-sea-wg0.age; mode = "444"; };
    rt-sea-wg1 = { file = ../../../secrets/rt-sea-wg1.age; mode = "444"; };
  };

  # https://nixos.wiki/wiki/Systemd-networkd
  systemd.network = {
    enable = true;
    netdevs = {
      "10-wg0" = {
        netdevConfig = { Name = "wg0"; Kind = "wireguard"; };
        wireguardConfig = {
          PrivateKeyFile = config.age.secrets.rt-sea-wg0.path;
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
        netdevConfig = { Name = "wg1"; Kind = "wireguard"; };
        wireguardConfig = {
          PrivateKeyFile = config.age.secrets.rt-sea-wg1.path;
          ListenPort = 51821;
        };
        wireguardPeers = [
          {
            wireguardPeerConfig = {
              # pine
              PublicKey = "xBNt1u2PhjNwRdZbGqPUYg89ZgXtK96CdzdgGHBkzgE=";
              AllowedIPs = [ "10.99.1.11/32" ];
            };
          }
          {
            wireguardPeerConfig = {
              # et
              PublicKey = "Hu7N0lVpDz2JjH3CiE2D1x0jHlWbsXCbVGPeoC4DpV4=";
              AllowedIPs = [ "10.99.1.12/32" ];
            };
          }
        ];
      };
    };

    networks = {
      "01-lo" = { name = "lo"; address = [ options.routerId ]; };
      "02-${options.extIntf}" = { name = options.extIntf; address = [ "66.42.76.194" ]; networkConfig = { DHCP = "yes"; }; };
      "10-wg0" = { matchConfig.Name = "wg0"; address = [ "10.99.0.0/31" ]; };
      "20-wg1" = { matchConfig.Name = "wg1"; address = [ "10.99.1.1/24" ]; };
    };
  };

  networking.nftables =
    let
      nft = import ../common/lib/nftables.nix { inherit lib; };
      wg = import ../common/lib/wireguard.nix { inherit config; };

      zoneTrust = [ "wg0" "wg1" ];
      zoneUntrust = [ options.extIntf ];

      tcpAccept = { proto = "tcp"; action = "accept"; };
      udpAccept = { proto = "udp"; action = "accept"; };

      dnatIntfs = { iifs = [ options.extIntf ]; oifs = zoneTrust; };
    in
    {
      enable = true;
      ruleset = nft.baseline {
        extraInputRules = map nft.mkRule [
          ({
            name = "BGP";
            iifs = zoneTrust;
            dpts = [ 179 ];
          } // tcpAccept)
          ({
            name = "SSH";
            iifs = zoneTrust;
            dips = [ options.routerId ];
            dpts = [ 22 ];
          } // tcpAccept)
          ({
            name = "WireGuard";
            iifs = zoneUntrust;
            dpts = wg.ports;
          } // udpAccept)
        ];

        extraForwardRules = map nft.mkRule [
          {
            name = "trust to trust";
            iifs = zoneTrust;
            oifs = zoneTrust;
            action = "accept";
          }
        ];

        dnatRules = map nft.mkDNATRule [ ];
      };
    };

  services.bird2 =
    let
      bird = import ../common/lib/bird.nix;
      defaults = {
        localAs = options.localAs;
        exportFilter = "rfc1918_v4";
        importFilter = "rfc1918_v4";
      };
    in
    {
      enable = true;
      config = bird.baseline {
        routerId = options.routerId;
        peers = map bird.mkPeer [
          ({
            name = "rt_ggz";
            ip = "10.99.0.1";
            remoteAs = 65000;
          } // defaults)
        ];
        extraConfig = ''
        '';
      };
    };
}

