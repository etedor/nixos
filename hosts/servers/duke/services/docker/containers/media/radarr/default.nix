{ config, ... }:

let
  tz = config.lib.globals.tz;
in
{
  virtualisation.arion.projects.media.settings = {
    services.radarr = {
      service.image = "lscr.io/linuxserver/radarr:version-4.7.5.7809";
      service.container_name = "radarr";
      service.environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = tz;
      };
      service.volumes = [
        {
          type = "volume";
          source = "radarr_config";
          target = "/config";
        }
        {
          type = "bind";
          source = "/pool0/media/downloads";
          target = "/media/downloads";
        }
        {
          type = "bind";
          source = "/pool0/media/library/movies";
          target = "/media/library/movies";
        }
      ];
      service.ports = [ "7878:7878" ];
      service.restart = "unless-stopped";
    };

    docker-compose.volumes = {
      radarr_config = { };
    };
  };
}
