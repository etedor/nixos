{ config, ... }:

let
  zone = config.lib.globals.zone;
in
{
  imports = [
    ./jellyfin
    ./jellyseerr
    ./prowlarr
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
        "jf.${zone}" = ({
          locations."/" = {
            proxyPass = "http://127.0.0.1:8096";
            proxyWebsockets = true;
          };
        } // defaults);

        "movies.${zone}" = ({
          locations."/".proxyPass = "http://127.0.0.1:7878";
        } // defaults);

        "nzb.${zone}" = ({
          locations."/".proxyPass = "http://127.0.0.1:8080";
        } // defaults);

        "prowl.${zone}" = ({
          locations."/".proxyPass = "http://127.0.0.1:9696";
        } // defaults);

        "requests.${zone}" = ({
          locations."/".proxyPass = "http://127.0.0.1:5055";
        } // defaults);

        "tv.${zone}" = ({
          locations."/".proxyPass = "http://127.0.0.1:8989";
        } // defaults);
      };
    };
}
