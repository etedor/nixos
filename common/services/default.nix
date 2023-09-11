{ pkgs, ... }:

{
  imports = [
    ./chrony
    ./journald
    ./msmtp
    ./openssh
  ];

  services = {
    netdata.enable = true;
  };
}
