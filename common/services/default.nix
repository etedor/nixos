{ pkgs, ... }:

{
  imports = [
    ./chrony
    ./msmtp
  ];

  services = {
    netdata.enable = true;
    openssh.enable = true;
  };
}
