{ ... }:

let
  nextdns = "https://raw.githubusercontent.com/nextdns";
  stevenb = "https://raw.githubusercontent.com/StevenBlack/hosts/master";
in
{
  services.blocky.settings.blocking = {
    blackLists = {
      default = [
        "use-application-dns.net" # DoH canary domain
        "${nextdns}/native-tracking-domains/main/domains/apple"
        "${nextdns}/native-tracking-domains/main/domains/samsung"
        "${nextdns}/native-tracking-domains/main/domains/sonos"
        "${nextdns}/native-tracking-domains/main/domains/windows"
        "${stevenb}/alternates/fakenews-only/hosts"
        "${stevenb}/alternates/gambling-only/hosts"
        "${stevenb}/alternates/porn-only/hosts"
        "${stevenb}/hosts" # ads + malware
      ];

      tlds =
        let
          formatTlds = tlds: builtins.concatStringsSep "\n" (map (tld: "/.*\\.${tld}$/") tlds);
          tlds = [
            "cn"
            "ir"
            "kp"
            "ru"
            "zip"
          ];
          formattedTlds = formatTlds tlds;
          tldsFile = builtins.toFile "tld-patterns.txt" formattedTlds;
        in
        [ tldsFile ];
    };

    clientGroupsBlock = {
      default = [
        "default"
        "tlds"
      ];
    };
  };
}
