{ pkgs, ... }:

{
  virtualisation.oci-containers.containers = {
    flame = {
      image = "pawelmalak/flame:2.3.1";
      ports = [ "5005:5005" ];
      volumes = [ "flame:/app/data" ];
    };
  };
}
