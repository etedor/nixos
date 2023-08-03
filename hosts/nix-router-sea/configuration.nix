{ config, pkgs, ... }:

{
  networking.hostName = "nix-router-sea";
  system.stateVersion = "23.05";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  age.secrets.nix-sea-router-wg0.file = ../../secrets/nix-router-sea-wg0.age;
  age.secrets.nix-sea-router-wg1.file = ../../secrets/nix-router-sea-wg1.age;

  networking.interfaces = {
    lo1 = {
      virtual = true;
      ipv4.addresses = [{
        address = "10.99.1.1";
        prefixLength = 32;
      }];
    };
  };

  networking.wireguard.interfaces = {
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

  services.frr = {
    bgp.config = ''
      router bgp 65099
        bgp router-id 10.99.1.1
        neighbor 10.99.0.1 remote-as 65000
        address-family ipv4 unicast
          redistribute connected route-map RM-4-CONNECTED
          neighbor 10.99.0.1 soft-reconfiguration inbound
          neighbor 10.99.0.1 route-map RM-4-WG0-IN in
          neighbor 10.99.0.1 route-map RM-4-WG0-OUT out
        exit-address-family
      exit
      !
    '';
    zebra.config = ''
      ip prefix-list PL-4-ALL seq 10 permit 0.0.0.0/0 le 32
      ip prefix-list PL-4-DEFAULT seq 10 permit 0.0.0.0/0
      ip prefix-list PL-4-ORIGIN seq 10 permit 10.99.0.0/16 le 32
      ip prefix-list PL-4-RFC1918 seq 10 permit 10.0.0.0/8 le 32
      ip prefix-list PL-4-RFC1918 seq 20 permit 172.16.0.0/12 le 32
      ip prefix-list PL-4-RFC1918 seq 30 permit 192.168.0.0/16 le 32
      !
      route-map RM-4-CONNECTED permit 10
      match ip address prefix-list PL-4-ORIGIN
      exit
      !
      route-map RM-4-WG0-IN deny 10
      match ip address prefix-list PL-4-DEFAULT
      exit
      !
      route-map RM-4-WG0-IN deny 20
      match ip address prefix-list PL-4-ORIGIN
      exit
      !
      route-map RM-4-WG0-IN permit 30
      match ip address prefix-list PL-4-RFC1918
      exit
      !
      route-map RM-4-WG0-OUT deny 10
      match ip address prefix-list PL-4-DEFAULT
      exit
      !
      route-map RM-4-WG0-OUT permit 20
      match ip address prefix-list PL-4-ORIGIN
      exit
      !
    '';
  };

  networking.firewall.allowedTCPPorts = [ 179 ];
  networking.firewall.allowedUDPPorts = [ 51820 51821 ];
}
