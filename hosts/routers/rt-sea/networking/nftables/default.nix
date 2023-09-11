{ config, lib, ... }:

let
  locals = config.lib.locals.rt-sea;
in
{
  networking = {
    firewall.enable = false; # We're managing the firewall ourself
    nat.enable = false;

    nftables =
      let
        nft = import ../../../common/lib/nftables { inherit lib; };
        wg = import ../../../common/lib/wireguard { inherit config; };

        zoneTrust = [ "wg0" "wg1" ];
        zoneUntrust = [ locals.extIntf ];

        tcpAccept = { proto = "tcp"; action = "accept"; };
        udpAccept = { proto = "udp"; action = "accept"; };

        dnatIntfs = { iifs = [ locals.extIntf ]; oifs = zoneTrust; };
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
              dips = [ locals.routerId ];
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
  };
  services.openssh.openFirewall = false;
}
