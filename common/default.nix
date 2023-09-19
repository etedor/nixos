{ ... }:

{
  imports = [
    ./home
    ./lib
    ./pkgs
    ./services
    ./users
  ];

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  i18n = { defaultLocale = "en_US.UTF-8"; };
  services.xserver = { layout = "us"; };
}
