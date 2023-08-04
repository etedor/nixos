{ config, lib, pkgs, ... }:

let
  routerId = "10.127.99.1";
  baseline = import ../common/bird.nix { routerId = routerId; };
in
{
  imports = [ ../common/router.nix ./hardware-configuration.nix ];

  networking.hostName = "nix-router-sea";
  system.stateVersion = "23.05";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  age.secrets.nix-sea-router-wg0.file = ../../secrets/nix-router-sea-wg0.age;
  age.secrets.nix-sea-router-wg1.file = ../../secrets/nix-router-sea-wg1.age;

  networking = {
    interfaces = {
      lo = {
        ipv4.addresses = [{
          address = routerId;
          prefixLength = 32;
        }];
      };
    };

    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.99.0.0/31" ];
        privateKeyFile = config.age.secrets.nix-sea-router-wg0.path;
        listenPort = 51820;
        allowedIPsAsRoutes = false;
        peers = [
          {
            # vyos-ggz
            publicKey = "H1UlGv6+J9r9XfMWTJxzbC5mIUbGTFvZMeHhJAvvRVQ=";
            allowedIPs = [ "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" ];
          }
        ];
      };
      wg1 = {
        ips = [ "10.99.1.1/24" ];
        privateKeyFile = config.age.secrets.nix-sea-router-wg1.path;
        listenPort = 51821;
        allowedIPsAsRoutes = false;
        peers = [
          {
            # pine
            publicKey = "xBNt1u2PhjNwRdZbGqPUYg89ZgXtK96CdzdgGHBkzgE=";
            allowedIPs = [ "10.99.1.11/32" ];
          }
        ];
      };
    };

    nftables.enable = true;
    firewall =
      let
        ifaceTrustList = [ "wg0" "wg1" ];
        ifaceUntrustList = [ "ens3" ];

        ifaceTrust = "{ ${builtins.concatStringsSep ", " ifaceTrustList} }";
        ifaceUntrust = "{ ${builtins.concatStringsSep ", " ifaceUntrustList} }";

        wgPorts = "{ ${builtins.concatStringsSep ", " (builtins.map toString (builtins.attrValues (builtins.mapAttrs (name: value: value.listenPort) config.networking.wireguard.interfaces)))} }";
      in
      {
        enable = true;
        allowPing = true;
        logReversePathDrops = true;
        filterForward = true;
        extraForwardRules = ''
          iifname ${ifaceTrust}     oifname ${ifaceTrust}               accept
          iifname ${ifaceUntrust}   oifname ${ifaceTrust}               drop
        '';
        extraInputRules = ''
          iifname ${ifaceTrust}     tcp dport 22  ip daddr ${routerId}  accept
          iifname ${ifaceTrust}     tcp dport 179                       accept
          iifname ${ifaceUntrust}   udp dport ${wgPorts}                accept
        '';
      };
  };
  services.openssh.openFirewall = false;

  services.bird2 = {
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
