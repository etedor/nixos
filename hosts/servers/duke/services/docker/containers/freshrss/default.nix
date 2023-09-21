{ config, ... }:

let
  tz = config.lib.globals.tz;
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
      ];
      service.ports = [ "8091:80" ];
      service.restart = "unless-stopped";
    };

    docker-compose.volumes = {
      config = { };
    };
  };
}
