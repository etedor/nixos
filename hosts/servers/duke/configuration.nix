{ config, lib, pkgs, ... }:

{
  system.stateVersion = "23.05";

  imports =
    [
      ./networking
      ./services
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
