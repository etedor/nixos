{ config, pkgs, ... }:

let
  zone = config.lib.globals.zone;
in
{
  users.users.nginx.extraGroups = [ "acme" ];
  services.nginx =
    let
      defaults = {
        extraConfig = ''
          proxy_buffering off;
        '';
        forceSSL = true;
        useACMEHost = zone;
      };

      pduFavicon = {
        proxyPass = "https://www.apc.com/favicon.ico";
        recommendedProxySettings = false;
        extraConfig = ''
          proxy_set_header Referer "";
          proxy_set_header Origin "";
        '';
      };
    in
    {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = {
        "_" = { locations."/" = { return = "404"; }; };

        "go.${zone}" = ({
          locations."/" = {
            proxyPass = "http://127.0.0.1:5005";
            proxyWebsockets = true;
          };
        } // defaults);

        "ha.${zone}" = ({
          locations."/" = {
            proxyPass = "http://10.0.11.11:8123";
            proxyWebsockets = true;
          };
        } // defaults);

        "notes.${zone}" = ({
          locations."/".proxyPass = "http://127.0.0.1:8081";
        } // defaults);

        "nr.${zone}" = ({
          locations."/" = {
            proxyPass = "http://10.0.11.11:1880";
            proxyWebsockets = true;
          };
        } // defaults);

        "nzb.${zone}" = ({
          locations."/".proxyPass = "http://127.0.0.1:8080";
        } // defaults);

        "og.${zone}" = ({
          locations."/".proxyPass = "https://10.0.2.253:443";
        } // defaults);

        "pdu1.${zone}" = ({
          locations."/".proxyPass = "http://10.0.2.12:80";
          locations."/favicon.ico" = pduFavicon;
        } // defaults);
        "pdu2.${zone}" = ({
          locations."/".proxyPass = "http://10.0.2.13:80";
          locations."/favicon.ico" = pduFavicon;
        } // defaults);
        "pdu3.${zone}" = ({
          locations."/".proxyPass = "http://10.0.2.14:80";
          locations."/favicon.ico" = pduFavicon;
        } // defaults);

        "ups.${zone}" = ({
          locations."/".proxyPass = "http://10.0.2.11:80";
        } // defaults);
      };
    };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
