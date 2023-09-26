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

  # cf. https://web.archive.org/web/20221209151134/https://felschr.com/blog/nixos-restic-backups
  services.restic.backups =
    let
      dirs = [
        {
          path = "/pool0/docker/volumes";
          excludes = [
            "media_jellyfin_config/_data/data/metadata"
            "media_radarr_config/_data/MediaCover"
            "media_sonarr_config/_data/MediaCover"
          ];
        }
        { path = "/pool0/users/eric"; excludes = [ "**/.git" ]; }
      ];

      fdCmd = dir:
        let
          excludes = builtins.concatStringsSep " " (map (ex: "--exclude=${ex}") dir.excludes);
        in
        ''
          ${pkgs.fd}/bin/fd \
            --hidden \
            --type f \
            ${excludes} \
            . ${dir.path} \
            | sed "s/\\[/\\\\\\[/g" | sed "s/\\]/\\\\\\]/g"
        '';
      fdCmds = builtins.concatStringsSep "\n" (map fdCmd dirs);

    in
    {
      rsyncNet = {
        repositoryFile = config.age.secrets.restic-repo.path;
        passwordFile = config.age.secrets.restic-pass.path;
        dynamicFilesFrom = fdCmds;
        timerConfig = {
          OnCalendar = "04:00";
          Persistent = true;
          RandomizedDelaySec = "30m";
        };
      };
    };

}
