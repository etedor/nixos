{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fd
    restic
  ];

  age.secrets = {
    code-restic-pass = {
      file = ../../../../../secrets/code-restic-pass.age;
      mode = "400";
      owner = "root";
      group = "root";
    };
    code-restic-repo = {
      file = ../../../../../secrets/code-restic-repo.age;
      mode = "400";
      owner = "root";
      group = "root";
    };
  };

  services.restic.backups = {
    rsyncNet = {
      repositoryFile = config.age.secrets.code-restic-repo.path;
      passwordFile = config.age.secrets.code-restic-pass.path;
      dynamicFilesFrom = "${pkgs.fd}/bin/fd -t f -H . /home/eric/code/ --exclude '**/.git/**'";
      timerConfig = {
        OnCalendar = "04:00";
        Persistent = true;
        RandomizedDelaySec = "30m";
      };
    };
  };
}
