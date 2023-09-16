{ config, ... }:

let
  tz = config.lib.globals.tz;
in
{
  virtualisation.arion.projects.media.settings = {
    services.sonarr = {
      service.image = "lscr.io/linuxserver/sonarr:version-3.0.10.1567";
      service.container_name = "sonarr";
      service.environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = tz;
      };
      service.volumes = [
        {
          type = "volume";
          source = "sonarr_config";
          target = "/config";
        }
        {
          type = "bind";
          source = "/pool0/media/library/tv";
          target = "/tv";
        }
        {
          type = "bind";
          source = "/pool0/media/downloads";
          target = "/downloads";
        }
      ];
      service.ports = [ "8989:8989" ];
      service.restart = "unless-stopped";
    };

    docker-compose.volumes = {
      sonarr_config = { };
    };
  };
}
