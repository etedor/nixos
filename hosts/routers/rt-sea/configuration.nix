{ config, lib, pkgs, ... }:

{
  system.stateVersion = "23.05";
  boot.loader.grub = { enable = true; device = "/dev/vda"; };

  imports = [
    ../common
    ./lib
    ./networking
    ./hardware-configuration.nix
  ];
}

