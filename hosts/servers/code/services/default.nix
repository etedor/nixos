{ pkgs, ... }:

{
  imports = [
    ./acme
    ./flame
    ./nginx
    ./restic
    ./zfs
  ];

  environment.systemPackages = [ pkgs.arion ];
  virtualisation.arion.backend = "docker";
}
