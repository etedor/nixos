{ config, lib, pkgs, ... }:

let
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJ9Ya8PpfcuSHtX52hJUXMDFJwUUyJR+0s6FuSTfEKn eric@code"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOu8kbwE6phergM4akwVvxsiTyq/aJlWYOHYc7I4h8nA eric@deus"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICgNd8ZgyJiay+vUZxvOzXqNsbmjhqzwFZx1U3+LnAVz eric@machina"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJSFNrJr2ZKEbNljmxxN4ib8Lf1vL4KJSSoWmbrssZOk eric@rt-sea"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPpKGHFRcaoD5K6EWfpSnVIKM0dh5jUL3o217NS5hmaf et@et"
  ];

  shell = if config.programs.nix-ld.enable then pkgs.bash else pkgs.fish;
  wslEnabled = if lib.options ? config.wsl.enable then config.wsl.enable else false;
in
{
  # Keep default shell for WSL root user
  users.users.root = {
    openssh.authorizedKeys.keys = authorizedKeys;
  } // (if wslEnabled then { } else { shell = shell; });

  users.users.eric = {
    isNormalUser = true;
    description = "Eric Tedor";
    extraGroups = [ "docker" "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = authorizedKeys;
    shell = shell;
    uid = 1000;
  };
}

