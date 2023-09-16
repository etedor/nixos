{ config, ... }:

let
  tz = config.lib.globals.tz;
in
{
  virtualisation.arion.projects.media.settings = {
    services.sabnzbd = {
      service.image = "lscr.io/linuxserver/sabnzbd:version-4.0.3";
      service.container_name = "sabnzbd";
      service.environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = tz;
      };
      service.volumes = [
        {
          type = "volume";
          source = "sabnzbd_config";
          target = "/config";
        }
        {
          type = "bind";
          source = "/pool0/media/downloads";
          target = "/downloads";
        }
      ];
      service.ports = [ "8080:8080" ];
      service.restart = "unless-stopped";
    };

    docker-compose.volumes = {
      sabnzbd_config = { };
    };
  };
}
