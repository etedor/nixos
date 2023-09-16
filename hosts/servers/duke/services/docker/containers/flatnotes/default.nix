{ ... }:

{
  virtualisation.arion.projects.flatnotes.settings = {
    services.flatnotes = {
      service.image = "dullage/flatnotes:v3.2.3";
      service.container_name = "flatnotes";
      service.environment = {
        PUID = "1000";
        PGID = "1000";
        FLATNOTES_AUTH_TYPE = "none";
      };
      service.volumes = [
        {
          type = "bind";
          source = "/pool0/users/eric/notes";
          target = "/data";
        }
      ];
      service.ports = [ "8081:8080" ];
      service.restart = "unless-stopped";
    };
  };
}
