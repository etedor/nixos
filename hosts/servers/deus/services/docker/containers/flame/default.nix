{ ... }:

{
  virtualisation.arion.projects.flame.settings = {
    services.flame = {
      service.image = "pawelmalak/flame:2.3.1";
      service.ports = [ "5005:5005" ];
      service.volumes = [
        {
          type = "volume";
          source = "data";
          target = "/app/data";
        }
      ];
    };

    docker-compose.volumes = {
      data = { };
    };
  };
}
