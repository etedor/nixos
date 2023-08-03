{ pkgs, ... }:

let
  nix-router-sea-wg0-pub = "hewTOjDLRD5ML+d3bsHb7RFDsRt9bNFxhoMfOrd0F0A=";
  nix-router-sea-wg1-pub = "niKrQNH3U7QGSsqvxL+rK5UAZTHEADkYWAk/GHy1YHc=";

  sho = pkgs.writeShellScriptBin "sho" (builtins.readFile ./bin/sho.sh);
  wg-mkclient = pkgs.writeShellScriptBin "wg-mkclient" (builtins.readFile ./bin/wg-mkclient.sh);
in
{
  boot.kernel.sysctl."net.ipv4.ip_forward" = "1";
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = "1";

  environment.systemPackages = with pkgs; [
    frr
    
    iftop
    tshark
    wireguard-tools
    qrencode

    sho
    wg-mkclient
  ];

  services.frr = {
    bgp.enable = true;
  };
}
