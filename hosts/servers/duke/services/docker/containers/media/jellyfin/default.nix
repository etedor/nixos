{ config, ... }:

let
  tz = config.lib.globals.tz;
in
{
  virtualisation.arion.projects.media.settings = {
    services.jellyfin = {
      service.image = "lscr.io/linuxserver/jellyfin:version-10.8.10-1";
      service.container_name = "jellyfin";
      service.environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = tz;
        JELLYFIN_PublishedServerUrl =
          let
            first = list: builtins.elemAt list 0;
            cidrAddress = first config.systemd.network.networks."20-bond0".networkConfig.Address;
            ipAddress = builtins.head (builtins.match "([0-9.]+).*" cidrAddress);
          in
          ipAddress;
      };
      service.volumes = [
        {
          type = "volume";
          source = "jellyfin_config";
          target = "/config";
        }
        {
          type = "bind";
          source = "/pool0/media/library/movies";
          target = "/media/library/movies";
        }
        {
          type = "bind";
          source = "/pool0/media/library/tv";
          target = "/media/library/tv";
        }
      ];
      service.ports = [
        "8096:8096"
        "8920:8920"
        "1900:1900/udp"
        "7359:7359/udp"
      ];
      service.restart = "unless-stopped";
    };

    docker-compose.volumes = {
      jellyfin_config = { };
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 8096 8920 ];
    allowedUDPPorts = [ 1900 7359 ];
  };
}
