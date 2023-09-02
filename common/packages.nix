{ config, pkgs, ... }:

let
  bgptool = pkgs.writeShellScriptBin "bgptool" (builtins.readFile ./bin/bgptool.sh);
  nix-build = pkgs.writeShellScriptBin "nix-build" (builtins.readFile ./bin/nix-build.sh);
  nix-clone = pkgs.writeShellScriptBin "nix-clone" (builtins.readFile ./bin/nix-clone.sh);
in
{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    fish
    starship

    jq
    vim

    curl
    wget

    duf
    glances
    iotop
    ncdu
    sshs
    tree

    dig
    ethtool
    grepcidr
    inetutils
    ipcalc
    iperf
    mtr
    netdata
    nmap
    speedtest-cli
    tcpdump
    traceroute
    whois

    bgptool
    nix-build
    nix-clone
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      starship init fish | source
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      hostname = {
        ssh_symbol = "⚡ ";
        style = "bold green";
      };
      time = {
        disabled = false;
      };
    };
  };
}
