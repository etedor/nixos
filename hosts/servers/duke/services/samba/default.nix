{ ... }:

{
  services.samba = {
    enable = true;
    shares = {
      eric = {
        path = "/pool0/users/eric";
        "valid users" = [ "eric" ];
        "write list" = [ "eric" ];
        "read only" = "no";
        browsable = "yes";
      };
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 135 139 445 ];
    allowedUDPPorts = [ 137 138 ];
  };
}
