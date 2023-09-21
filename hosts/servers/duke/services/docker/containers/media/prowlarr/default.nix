{ config, ... }:

let
  tz = config.lib.globals.tz;
in
{
  virtualisation.arion.projects.media.settings = {
    services.prowlarr = {
      service.image = "lscr.io/linuxserver/prowlarr:version-1.8.6.3946";
      service.container_name = "prowlarr";
      service.environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = tz;
      };
      service.volumes = [
        {
          type = "volume";
          source = "prowlarr_config";
          target = "/config";
        }
      ];
      service.ports = [ "9696:9696" ];
      service.restart = "unless-stopped";
    };

    docker-compose.volumes = {
      prowlarr_config = { };
    };
  };
}
