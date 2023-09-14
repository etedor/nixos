{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.arion ];
  virtualisation.arion.backend = "docker";
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
    extraOptions = "--graph=/pool0/docker";
  };
}

