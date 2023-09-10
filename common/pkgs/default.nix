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

    bat # replaces cat
    htop # replaces top
    ripgrep # replaces grep

    curl
    fd
    glances
    iotop
    jq
    duf
    ncdu
    sshs
    vim
    wget

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
      set fish_greeting
      starship init fish | source
    '';
    shellAliases = {
      ls = "lsd --almost-all";
      cat = "bat --plain";
      top = "htop";
      grep = "rg";
      tree = "lsd --tree";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      hostname = {
        ssh_symbol = "📡 ";
        style = "bold green";
      };
      time = {
        disabled = false;
      };
    };
  };
}
