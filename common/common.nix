{ config, lib, pkgs, ... }:

let
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICgNd8ZgyJiay+vUZxvOzXqNsbmjhqzwFZx1U3+LnAVz eric@machina"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJ9Ya8PpfcuSHtX52hJUXMDFJwUUyJR+0s6FuSTfEKn eric@nix-vscode"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJSFNrJr2ZKEbNljmxxN4ib8Lf1vL4KJSSoWmbrssZOk eric@nix-router-sea"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPpKGHFRcaoD5K6EWfpSnVIKM0dh5jUL3o217NS5hmaf et@et"
  ];

  bgptool = pkgs.writeShellScriptBin "bgptool" (builtins.readFile ./bin/bgptool.sh);
  flake-test-remote = pkgs.writeShellScriptBin "flake-test-remote" (builtins.readFile ./bin/flake-test-remote.sh);
  flake-test = pkgs.writeShellScriptBin "flake-test" (builtins.readFile ./bin/flake-test.sh);
  nixos-clone = pkgs.writeShellScriptBin "nixos-clone" (builtins.readFile ./bin/nixos-clone.sh);
in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    jq
    vim

    curl
    wget

    duf
    glances
    iotop
    ncdu
    sshs
    tree

    dig
    ethtool
    inetutils
    ipcalc
    iperf
    mtr
    netdata
    nmap
    speedtest-cli
    tcpdump
    traceroute
    whois

    bgptool
    flake-test-remote
    flake-test
    nixos-clone
  ];

  users.users.eric = {
    isNormalUser = true;
    description = "Eric Tedor";
    extraGroups = [ "docker" "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = authorizedKeys;
  };
  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };
}
