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
    };
  };

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
