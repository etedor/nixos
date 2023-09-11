{ config, lib, ... }:

let
  locals = config.lib.locals.rt-sea;
in
{
  services.bird2 =
    let
      bird = import ../../../common/lib/bird;
      defaults = {
        localAs = locals.localAs;
        exportFilter = "rfc1918_v4";
        importFilter = "rfc1918_v4";
      };
    in
    {
      enable = true;
      config = bird.baseline {
        routerId = locals.routerId;
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
