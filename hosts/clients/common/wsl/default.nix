{ pkgs, ... }:

let
  nixosWslSrc = pkgs.fetchGit {
    url = "https://github.com/nix-community/NixOS-WSL.git";
    rev = "e7d93d0";
  };

  nixos-wsl = import nixosWslSrc;
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
