{ config, pkgs, ... }:

{
  environment.etc = {
    "home/eric/.ssh/id_ed25519".source = "/mnt/c/Users/eric/.ssh/id_ed25519";
    "home/eric/.ssh/id_ed25519.pub".source = "/mnt/c/Users/eric/.ssh/id_ed25519.pub";
  };
}
