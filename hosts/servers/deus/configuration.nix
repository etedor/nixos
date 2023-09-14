{ config, pkgs, ... }:

{
  imports =
    [
      ./networking
      ./services
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "23.05";
}
