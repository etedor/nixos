{ config, lib, ... }:

let
  locals = config.lib.locals.rt-sea;
in
{
  imports = [
    ./bird
    ./nftables
    ./wireguard
  ];

  networking = {
    hostName = "rt-sea";
    domain = locals.domainName;
    useDHCP = false; # Managed by systemd-networkd
  };

  # https://nixos.wiki/wiki/Systemd-networkd
  systemd.network = {
    enable = true;
    networks = {
      "01-lo" = { name = "lo"; address = [ locals.routerId ]; };
      "02-${locals.extIntf}" = { name = locals.extIntf; networkConfig = { DHCP = "yes"; }; };
    };
  };
}
