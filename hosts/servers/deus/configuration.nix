{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "deus";

  networking.networkmanager.enable = true;
  networking.enableIPv6 = false;
  boot.kernel.sysctl."net.ipv6.conf.ens192.disable_ipv6" = true;

  services.openssh.enable = true;

  system.stateVersion = "23.05";

}
