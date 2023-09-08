let
  join = lines: builtins.concatStringsSep "\n" lines;

  mkPeer = attrs:
    let
      name = if attrs ? name then attrs.name else throw "The 'name' attribute is mandatory!";
      ip = attrs.ip;

      localAs = attrs.localAs;
      remoteAs = attrs.remoteAs;
      exportFilter = attrs.exportFilter;
      importFilter = attrs.importFilter;
    in
    ''
      protocol bgp ${name} {
        local as ${toString localAs};
        neighbor ${ip} as ${toString remoteAs};
        ipv4 {
          export filter ${exportFilter};
          import filter ${importFilter};
        };
      }'';

  baseline =
    { routerId ? "", peers ? [ ], extraConfig ? "" }: ''
      router id ${routerId};

      filter rfc1918_v4 {
        if net ~ [
          10.0.0.0/8{8,32},
          172.16.0.0/12{12,32},
          192.168.0.0/16{16,32}
        ] then accept;
        reject;
      }

      protocol device {
        scan time 10;
      }

      protocol kernel {
        ipv4 {
          export filter rfc1918_v4;
        };
      }

      protocol direct {
        ipv4 {
          import filter rfc1918_v4;
        };
      }

      ${join peers}
      ${extraConfig}
    ''; # TODO: deal with extra newlines if above is empty
in
{
  mkPeer = mkPeer;
  baseline = baseline;
}
