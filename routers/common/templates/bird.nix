{ extraConfig, routerId }:

let
  baseline = ''
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
    
    ${extraConfig}
  '';
in
baseline
