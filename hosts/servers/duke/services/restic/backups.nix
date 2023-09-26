{
  specs = [
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
}
