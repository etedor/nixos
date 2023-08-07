{ pkgs, ... }:

let
  nix-router-sea-wg0-pub = "hewTOjDLRD5ML+d3bsHb7RFDsRt9bNFxhoMfOrd0F0A=";
  nix-router-sea-wg1-pub = "niKrQNH3U7QGSsqvxL+rK5UAZTHEADkYWAk/GHy1YHc=";

  nfw = pkgs.writeShellScriptBin "nfw" (builtins.readFile ./bin/nfw.sh);
  sho = pkgs.writeShellScriptBin "sho" (builtins.readFile ./bin/sho.sh);
  wg-mkclient = pkgs.writeShellScriptBin "wg-mkclient" (builtins.readFile ./bin/wg-mkclient.sh);
in
{
  boot.kernel.sysctl."net.ipv4.ip_forward" = "1";
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = "1";

  environment.systemPackages = with pkgs; [
    bird
    conntrack-tools
    wireguard-tools

    iftop
    termshark
    tshark
    qrencode

    # ntopng
    # redis

    nfw
    sho
    wg-mkclient
  ];

  # services.ntopng = {
  #   enable = true;
  #   extraConfig = ''
  #     --local-networks "10.0.0.0/8,172.16. 0.0/12,192.168.0.0/16"
  #   '';
  # };
}
