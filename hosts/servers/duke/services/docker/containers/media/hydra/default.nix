{ config, ... }:

let
  tz = config.lib.globals.tz;
in
{
  virtualisation.arion.projects.media.settings = {
    services.hydra = {
      service.image = "lscr.io/linuxserver/nzbhydra2:version-v5.1.11";
      service.container_name = "hydra";
      service.environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = tz;
      };
      service.volumes = [
        {
          type = "volume";
          source = "hydra_config";
          target = "/config";
        }
        {
          type = "bind";
          source = "/pool0/media/downloads";
          target = "/downloads";
        }
      ];
      service.ports = [ "5076:5076" ];
      service.restart = "unless-stopped";
    };

    docker-compose.volumes = {
      hydra_config = { };
    };
  };
}
