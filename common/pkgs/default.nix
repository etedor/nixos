{ config, pkgs, ... }:

let
  bgptool = pkgs.writeShellScriptBin "bgptool" (builtins.readFile ./bin/bgptool.sh);
  nixos-build = pkgs.writeShellScriptBin "nixos-build" (builtins.readFile ./bin/nixos-build.sh);
  nixos-clone = pkgs.writeShellScriptBin "nixos-clone" (builtins.readFile ./bin/nixos-clone.sh);
in
{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    fish
    starship

    bat # replaces cat
    unstable.lsd # replaces ls
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
    nixos-build
    nixos-clone
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit =
      let
        commonInit = ''
          set fish_greeting
          starship init fish | source
        '';
        nixLdInit = ''
          # cf. https://github.com/Mic92/nix-ld/issues/59#issuecomment-1719226789
          set -x NIX_LD (grep "export NIX_LD=" /etc/set-environment | cut -d'=' -f2 | sed 's/\"//g')
          set -x NIX_LD_LIBRARY_PATH (grep "export NIX_LD_LIBRARY_PATH=" /etc/set-environment | cut -d'=' -f2 | sed 's/\"//g')
          direnv hook fish | source
        '';
      in
      if config.programs.nix-ld.enable then "${nixLdInit}\n${commonInit}" else commonInit;
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
