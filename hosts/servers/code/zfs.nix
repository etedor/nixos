{ config, pkgs, ... }:

let
  zone = config.lib.globals.zone;
in
{
  # cf. https://gist.github.com/bitonic/78529d3dd007d779d60651db076a321a

  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs.extraPools = [ "pool0" ];
  };
  networking.hostId = "f6ea8d27";

  nixpkgs = {
    config = {
      packageOverrides = super:
        let self = super.pkgs; in {
          zfs = super.zfs.override { enableMail = true; };
        };
    };
  };
  environment.systemPackages = with pkgs; [ zfs ];

  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "monthly";
      pools = [ "pool0" ];
    };

    autoSnapshot = {
      enable = true;
      flags = "-k -p --utc";

      frequent = 4;
      hourly = 24;
      daily = 7;
      weekly = 4;
      monthly = 12;
    };

    zed = {
      enableMail = true;

      settings = {
        ZED_EMAIL_ADDR = [ "admin@${zone}" ];
        ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
        ZED_EMAIL_OPTS = "@ADDRESS@";

        ZED_NOTIFY_INTERVAL_SECS = 3600;
        ZED_NOTIFY_VERBOSE = true;
        ZED_USE_ENCLOSURE_LEDS = true;
        ZED_SCRUB_AFTER_RESILVER = false;
      };
    };
  };

  age.secrets = {
    code-mailgun = {
      file = ../../../secrets/code-mailgun.age;
      mode = "400";
      owner = "root";
      group = "root";
    };
  };

  programs.msmtp = {
    enable = true;
    setSendmail = true;

    defaults = {
      tls = true;
      tls_starttls = true;
      tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
    };

    accounts = {
      default = {
        host = "smtp.mailgun.org";
        port = 587;
        auth = true;
        from = "system@mg.${zone}";
        user = "system@mg.${zone}";
        passwordeval = "cat ${config.age.secrets.code-mailgun.path}";
      };
    };
  };
}
