{ pkgs, ... }:

let
  nfw = pkgs.writeShellScriptBin "nfw" (builtins.readFile ./bin/nfw.sh);
  sho = pkgs.writeShellScriptBin "sho" (builtins.readFile ./bin/sho.sh);
  wg-mkclient = pkgs.writeShellScriptBin "wg-mkclient" (builtins.readFile ./bin/wg-mkclient.sh);
in
{
  environment.systemPackages = with pkgs; [
    bird
    conntrack-tools
    wireguard-tools

    iftop
    termshark
    tshark
    qrencode

    nfw
    sho
    wg-mkclient
  ];
}
