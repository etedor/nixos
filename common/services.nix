{ pkgs, ... }:

{
  time.timeZone = "America/Los_Angeles";

  services = {
    timesyncd.enable = false;
    chrony = {
      enable = true;
      servers = [ "10.0.2.123" ];
    };

    netdata.enable = true;

    openssh.enable = true;
  };
}
