{ pkgs, ... }:

let
  nixos-wsl = import ./nixos-wsl;
in
{
  imports = [
    nixos-wsl.nixosModules.wsl
    ./services
  ];

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "eric";
    startMenuLaunchers = true;
  };
}
