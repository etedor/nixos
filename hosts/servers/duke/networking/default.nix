{ config, lib, ... }:

{
  networking = {
    hostName = "duke";
    domain = "int.et42.net";
    useDHCP = false; # Managed by systemd-networkd
  };

  # https://nixos.wiki/wiki/Systemd-networkd
  systemd.network = {
    enable = true;
    netdevs = {
      "10-bond0" = {
        netdevConfig = {
          Kind = "bond";
          Name = "bond0";
        };
        bondConfig = {
          Mode = "802.3ad";
          TransmitHashPolicy = "layer3+4";
        };
      };
    };
    networks = {
      "10-enp3s0" = {
        matchConfig.Name = "enp3s0";
        networkConfig.Bond = "bond0";
      };
      "10-enp3s0d1" = {
        matchConfig.Name = "enp3s0d1";
        networkConfig.Bond = "bond0";
      };
      "20-bond0" = {
        matchConfig.Name = "bond0";
        linkConfig = {
          RequiredForOnline = "carrier";
        };
        networkConfig = {
          Address = [ "10.0.5.101/24" ];
          Gateway = "10.0.5.1";
          DNS = [ "10.0.1.1" ];
          LinkLocalAddressing = "no";
        };
      };
    };
  };
}
