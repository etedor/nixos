{ config, lib, pkgs, ... }:

let
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICgNd8ZgyJiay+vUZxvOzXqNsbmjhqzwFZx1U3+LnAVz eric@tedor.org"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINICpMw3RFwuHL0YbGzZRwsDao2oOtbi5ErAiO42rVki eric@nix-vscode"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC1NcdYnJ8R0Psv/at5ql4tI1pHzEUV8FR8lIpOjLW30 eric@nix-router-sea"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPpKGHFRcaoD5K6EWfpSnVIKM0dh5jUL3o217NS5hmaf et@et"
  ];

  flake-rebuild = pkgs.writeShellScriptBin "flake-rebuild" (builtins.readFile ./bin/flake-rebuild.sh);
  nixos-clone = pkgs.writeShellScriptBin "nixos-clone" (builtins.readFile ./bin/nixos-clone.sh);
in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    duf
    glances
    iotop
    ncdu
    tmux
    tree

    jq
    vim

    curl
    dnsutils
    wget
  ];

  users.users.eric = {
    isNormalUser = true;
    description = "Eric Tedor";
    extraGroups = [ "docker" "networkmanager" "wheel" ];
    packages = [
      flake-rebuild
      nix-clone
    ];
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
