{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fd
    restic
  ];

  age.secrets = {
    deus-restic-pass = {
      file = ../../../../../secrets/deus-restic-pass.age;
      mode = "400";
      owner = "root";
      group = "root";
    };
    deus-restic-repo = {
      file = ../../../../../secrets/deus-restic-repo.age;
      mode = "400";
      owner = "root";
      group = "root";
    };
  };

  services.restic.backups =
    let
      backupDirs = [
        { path = "/pool0/users/eric/code/"; exclude = [ "**/.git/**" ]; }
        { path = "/pool0/users/eric/notes/"; exclude = [ ]; }
      ];
    in
    {
      rsyncNet = {
        repositoryFile = config.age.secrets.deus-restic-repo.path;
        passwordFile = config.age.secrets.deus-restic-pass.path;
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
