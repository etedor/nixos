{ config, lib, pkgs, ... }:

let
  zone = config.lib.globals.zone;
in
{
  imports = [
    ./hardware-configuration.nix
    ./services
  ];

  networking.hostName = "code";
  system.stateVersion = "23.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  virtualisation.vmware.guest.enable = true;

  networking.networkmanager.enable = true;
  networking.enableIPv6 = false;
  boot.kernel.sysctl."net.ipv6.conf.ens192.disable_ipv6" = true;

  environment.systemPackages = with pkgs; [
    nixfmt
    nixpkgs-fmt

    direnv
    nix-direnv
  ];

  programs.nix-ld.enable = true;
  environment = {
    pathsToLink = [ "/share/nix-direnv" ];
    variables = {
      NIX_LD_LIBRARY_PATH = lib.mkForce (lib.makeLibraryPath [
        pkgs.stdenv.cc.cc
      ]);
      NIX_LD = lib.mkForce "${pkgs.stdenv.cc.bintools.dynamicLinker}";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 19999 50080 ];
}
