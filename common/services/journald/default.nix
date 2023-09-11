{ pkgs, ... }:

{
  services = {
    journald = {
      rateLimitBurst = 0;
      extraConfig = "SystemMaxUse=256M";
    };
  };
}
