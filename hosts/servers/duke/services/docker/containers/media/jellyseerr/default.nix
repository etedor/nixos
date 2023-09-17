{ config, ... }:

let
  tz = config.lib.globals.tz;
in
{
  virtualisation.arion.projects.media.settings = {
    services.jellyseerr = {
      service.image = "fallenbagel/jellyseerr:1.7.0";
      service.container_name = "jellyseerr";
      service.environment = {
        PUID = "1000";
        PGID = "1000";
        LOG_LEVEL = "debug";
        TZ = tz;
      };
      service.volumes = [
        {
          type = "volume";
          source = "jellyseerr_config";
          target = "/app/config";
        }
      ];
      service.ports = [ "5055:5055" ];
      service.restart = "unless-stopped";
    };

    docker-compose.volumes = {
      jellyseerr_config = { };
    };
  };
}
