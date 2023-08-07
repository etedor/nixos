{ config, lib, pkgs, ... }:

let
  options = {
    hostName = "nix-router-sea";
    domainName = "int.tedor.org";

    extInterface = "ens3";
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

  # We're managing the firewall ourselves
  networking = {
    firewall.enable = false;
    nat.enable = false;
  };
  services.openssh.openFirewall = false;

  age.secrets = {
    nix-router-sea-wg0 = { file = ../../secrets/nix-router-sea-wg0.age; mode = "444"; };
    nix-router-sea-wg1 = { file = ../../secrets/nix-router-sea-wg1.age; mode = "444"; };
  };

  # https://nixos.wiki/wiki/Systemd-networkd
  systemd.network = {
    enable = true;
    netdevs = {
      "10-wg0" = {
        netdevConfig = { Name = "wg0"; Kind = "wireguard"; };
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
        netdevConfig = { Name = "wg1"; Kind = "wireguard"; };
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
      "01-lo" = { name = "lo"; address = [ options.routerId ]; };
      "02-${options.extInterface}" = { name = options.extInterface; networkConfig = { DHCP = "yes"; }; };
      "10-wg0" = { matchConfig.Name = "wg0"; address = [ "10.99.0.0/31" ]; };
      "20-wg1" = { matchConfig.Name = "wg1"; address = [ "10.99.1.1/24" ]; };
    };
  };

  networking.nftables =
    let
      zoneTrust = [ "wg0" "wg1" ];
      zoneUntrust = [ options.extInterface ];

      baseline = import ../common/templates/nftables.nix;
      wgPorts = import ../common/lib/make-wg-ports.nix { inherit config; };
      mkRule = import ../common/lib/make-nft-rule.nix { inherit lib; };
    in
    {
      enable = true;
      ruleset = baseline {
        extraInputRules = map mkRule [
          { name = "Allow SSH"; iif = zoneTrust; dip = options.routerId; proto = "tcp"; dport = 22; action = "accept"; }
          { name = "Allow BGP"; iif = zoneTrust; proto = "tcp"; dport = 179; action = "accept"; }
          { name = "Allow WireGuard"; iif = zoneUntrust; dport = wgPorts; proto = "udp"; action = "accept"; }
        ];
        extraForwardRules = map mkRule [
          { name = "Allow trust to trust"; iif = zoneTrust; oif = zoneTrust; action = "accept"; }
          { name = "Allow untrust to trust for DNAT"; iif = zoneUntrust; oif = zoneTrust; proto = "tcp"; dport = 443; action = "accept"; }
          { name = "Allow trust to untrust for DNAT"; iif = zoneTrust; oif = zoneUntrust; proto = "tcp"; sport = 443; action = "accept"; }
        ];
        extraPreRoutingRules = [
          "iifname ${options.extInterface} tcp dport 443 dnat ip to 10.0.2.91:443 comment \"DNAT for HTTPS\""
        ];
      };
    };

  services.bird2 =
    let
      baseline = import ../common/templates/bird.nix;
    in
    {
      enable = true;
      config = baseline {
        routerId = options.routerId;
        extraConfig = ''
          protocol bgp wg0 {
            local as ${toString options.localAs};
            neighbor 10.99.0.1 as 65000;
            ipv4 {
              import filter rfc1918_v4;
              export filter rfc1918_v4;
            };
          }
        '';
      };
    };
}
