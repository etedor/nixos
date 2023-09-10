{ pkgs, ... }:

{
  imports = [
    ./acme
    ./flame
    ./flatnotes
    ./nginx
    ./restic
    ./zfs
  ];

  environment.systemPackages = [ pkgs.arion ];
  virtualisation.arion.backend = "docker";
}
