{ config, ... }:

let
  zone = config.lib.globals.zone;
in
{
  imports = [
    ./hydra
    ./radarr
    ./sabnzbd
    ./sonarr
  ];

  services.nginx =
    let
      defaults = {
        extraConfig = ''
          proxy_buffering off;
        '';
        forceSSL = true;
        useACMEHost = zone;
      };
    in
    {
      virtualHosts = {
        "hydra.${zone}" = ({
          locations."/".proxyPass = "http://127.0.0.1:5076";
        } // defaults);

        "movies.${zone}" = ({
          locations."/".proxyPass = "http://127.0.0.1:7878";
        } // defaults);

        "nzb.${zone}" = ({
          locations."/".proxyPass = "http://127.0.0.1:8080";
        } // defaults);

        "tv.${zone}" = ({
          locations."/".proxyPass = "http://127.0.0.1:8989";
        } // defaults);
      };
    };
}
