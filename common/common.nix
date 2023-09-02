{ config, lib, pkgs, ... }:

let
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJ9Ya8PpfcuSHtX52hJUXMDFJwUUyJR+0s6FuSTfEKn eric@code"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICgNd8ZgyJiay+vUZxvOzXqNsbmjhqzwFZx1U3+LnAVz eric@machina"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJSFNrJr2ZKEbNljmxxN4ib8Lf1vL4KJSSoWmbrssZOk eric@rt-sea"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPpKGHFRcaoD5K6EWfpSnVIKM0dh5jUL3o217NS5hmaf et@et"
  ];

  shell = if config.networking.hostName != "code" then pkgs.fish else pkgs.bash;
in
{
  imports = [
    ./home.nix
    ./globals.nix
    ./packages.nix
    ./services.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.eric = {
    isNormalUser = true;
    description = "Eric Tedor";
    extraGroups = [ "docker" "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = authorizedKeys;
    shell = shell;
  };

  users.users.root = {
    openssh.authorizedKeys.keys = authorizedKeys;
    shell = shell;
  };

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
