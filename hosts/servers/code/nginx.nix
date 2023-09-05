{ config, pkgs, ... }:

let
  zone = config.lib.globals.zone;
in
{
  virtualisation.oci-containers.containers = {
    flame = {
      image = "pawelmalak/flame:2.3.1";
      ports = [ "5005:5005" ];
      volumes = [ "flame:/app/data" ];
    };
  };

  age.secrets = {
    code-acme = {
      file = ../../../secrets/code-acme.age;
      mode = "400";
      owner = "acme";
      group = "acme";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@${zone}";

    certs."${zone}" = {
      domain = "${zone}";
      extraDomainNames = [ "*.${zone}" ];
      dnsProvider = "cloudflare";
      dnsPropagationCheck = true;
      credentialsFile = config.age.secrets.code-acme.path;
    };
  };

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

        "nr.${zone}" = ({
          locations."/" = {
            proxyPass = "http://10.0.11.11:1880";
            proxyWebsockets = true;
          };
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
