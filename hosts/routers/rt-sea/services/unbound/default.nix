{ ... }:

let
  locals = config.lib.locals.rt-sea;
in
{
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [ locals.routerId ];

        access-control = [
          "10.0.0.0/8 allow"
          "172.16.0.0/12 allow"
          "192.168.0.0/16 allow"
        ];

        edns-buffer-size = 1232;
        harden-dnssec-stripped = true;
        harden-glue = true;
        num-threads = 1;
        prefetch = true;
        so-rcvbuf = "1m";
        use-caps-for-id = false;

        local-zone = [
          "int.et42.net. static"
          "int.tedor.org. static"
        ];

        private-address = [
          "10.0.0.0/8"
          "172.16.0.0/12"
          "192.168.0.0/16"
          "169.254.0.0/16"
          "fd00::/8"
          "fe80::/10"
        ];
      };
    };
  };
}
