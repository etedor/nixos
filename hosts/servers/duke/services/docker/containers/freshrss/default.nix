{ config, ... }:

let
  tz = config.lib.globals.tz;
  extensionsSrc = builtins.fetchGit {
    url = "https://github.com/FreshRSS/Extensions.git";
    rev = "0aa6e4c1866f088f4de26889867360a34114b709";
  };
  catppuccinSrc = builtins.fetchGit {
    url = "https://github.com/catppuccin/freshrss.git";
    rev = "6b9889f7c63eec734fc76f787e13fb282c5ab742";
  };
in
{
  virtualisation.arion.projects.freshrss.settings = {
    services.freshrss = {
      service.image = "lscr.io/linuxserver/freshrss:version-1.21.0";
      service.container_name = "freshrss";
      service.environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = tz;
      };
      service.volumes = [
        {
          type = "volume";
          source = "config";
          target = "/config";
        }
        {
          type = "bind";
          source = "${extensionsSrc}/xExtension-CustomCSS";
          target = "/tmp/xExtension-CustomCSS";
        }
        {
          type = "bind";
          source = "${catppuccinSrc}/palettes/frappe.css";
          target = "/tmp/palettes/frappe.css";
        }
      ];
      service.entrypoint =
        let
          extensionsPath = "/config/www/freshrss/extensions";
          user = "eric";
        in
        ''
          sh -c '\
          # install frappé theme - switch to nord to activate!
          cp -R /tmp/xExtension-CustomCSS ${extensionsPath} &&
          cp /tmp/palettes/frappe.css ${extensionsPath}/static/style.${user}.css &&
          chown -R 1000:1000 ${extensionsPath}/xExtension-CustomCSS &&
          chmod -R u+w ${extensionsPath}/xExtension-CustomCSS/static/

          /init'
        '';
      service.ports = [ "8091:80" ];
      service.restart = "unless-stopped";
    };

    docker-compose.volumes = {
      config = { };
    };
  };
}

