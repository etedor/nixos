{ ... }:

{
  virtualisation.arion.projects.sabnzbd.settings = {
    services.sabnzbd = {
      service.image = "lscr.io/linuxserver/sabnzbd:4.0.3";
      service.container_name = "sabnzbd";
      service.environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "America/Los_Angeles";
      };
      service.volumes = [
        {
          type = "volume";
          source = "config";
          target = "/config";
        }
        {
          type = "bind";
          source = "/pool0/media/downloads/complete";
          target = "/downloads";
        }
        {
          type = "bind";
          source = "/pool0/media/downloads/incomplete";
          target = "/incomplete-downloads";
        }
      ];
      service.ports = [ "8080:8080" ];
      service.restart = "unless-stopped";
    };
    docker-compose.volumes = {
      config = { };
    };
  };
}
