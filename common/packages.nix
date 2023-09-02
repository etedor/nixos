{ pkgs, ... }:

let
  bgptool = pkgs.writeShellScriptBin "bgptool" (builtins.readFile ./bin/bgptool.sh);
  flake-test-remote = pkgs.writeShellScriptBin "flake-test-remote" (builtins.readFile ./bin/flake-test-remote.sh);
  flake-test = pkgs.writeShellScriptBin "flake-test" (builtins.readFile ./bin/flake-test.sh);
  nixos-clone = pkgs.writeShellScriptBin "nixos-clone" (builtins.readFile ./bin/nixos-clone.sh);
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
    flake-test-remote
    flake-test
    nixos-clone
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # c.f. https://github.com/Mic92/nix-ld/issues/59
      if test -n "$NIX_LD_LIBRARY_PATH"
        set -x LD_LIBRARY_PATH $NIX_LD_LIBRARY_PATH
      end

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
