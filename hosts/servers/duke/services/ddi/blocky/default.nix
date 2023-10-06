{ ... }:

{
  imports = [
    ./blocking.nix
  ];

  services.blocky = {
    enable = true;
    settings = {
      caching.prefetching = true;
      ports = { dns = "10.0.5.101:53"; }; # TODO use a variable
      upstream = {
        default = [
          "10.127.99.1"
        ];
      };
      conditional = {
        fallbackUpstream = false;

        mapping =
          let
            dnsmasq = "127.0.0.1:5353";
          in
          {
            "." = dnsmasq;
            "in-addr.arpa" = dnsmasq;

            "et42.net" = dnsmasq;
            "int.tedor.org" = dnsmasq;
            "lab.tedor.org" = dnsmasq;
          };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
