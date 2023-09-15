{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fd
    restic
  ];

  age.secrets = {
    restic-pass = {
      file = ../../../../../secrets/duke/restic-pass.age;
      mode = "400";
      owner = "root";
      group = "root";
    };
    restic-repo = {
      file = ../../../../../secrets/duke/restic-repo.age;
      mode = "400";
      owner = "root";
      group = "root";
    };
  };

  services.restic.backups =
    let
      backupDirs = [
        { path = "/pool0/users/eric/"; exclude = [ "**/.git/**" ]; }
      ];
    in
    {
      rsyncNet = {
        repositoryFile = config.age.secrets.restic-repo.path;
        passwordFile = config.age.secrets.restic-pass.path;
        dynamicFilesFrom = lib.concatStringsSep " ; " (map
          (dir:
            "${pkgs.fd}/bin/fd -t f -H . ${dir.path} ${lib.concatMapStringsSep " " (pattern: "--exclude '${pattern}'") dir.exclude}"
          )
          backupDirs);
        timerConfig = {
          OnCalendar = "04:00";
          Persistent = true;
          RandomizedDelaySec = "30m";
        };
      };
    };

}
