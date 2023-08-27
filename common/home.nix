{ config, lib, pkgs, ... }:

let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz";
    sha256 = "0dfshsgj93ikfkcihf4c5z876h4dwjds998kvgv7sqbfv0z6a4bc";
  };
in
{
  imports = [ "${home-manager}/nixos" ];

  home-manager.users.eric = {
    home.stateVersion = "23.05";

    programs.bash = {
      enable = true;
      initExtra = ''
        export HISTSIZE=10000
        export HISTFILESIZE=20000
        shopt -s histappend
        PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
      '';
    };

    programs.git = {
      enable = true;
      userName = "Eric Tedor";
      userEmail = "eric@tedor.org";
    };

    programs.ssh = {
      enable = true;
      matchBlocks = {
        "nix-vscode" = {
          hostname = "10.0.2.153";
          user = "eric";
        };
        "nix-router-sea" = {
          hostname = "10.127.99.1";
          user = "eric";
        };
      };
    };

    programs.starship = {
      enable = true;
      settings = {
        hostname = {
          ssh_symbol = "🌎 ";
          style = "bold green";
        };
        nix_shell = {
          symbol = "❄️ ";
        };
        time = {
          disabled = false;
        };
      };
    };

    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        vim-airline
        vim-commentary
      ];
      settings = {
        "expandtab" = true;
        "ignorecase" = true;
        "mouse" = "r";
        "number" = true;
        "shiftwidth" = 4;
        "tabstop" = 4;
      };
      extraConfig = ''
        set smartindent
        set autoindent

        noremap <C-_> :Commentary<CR>
        xnoremap <C-_> :Commentary<CR>
        noremap <31> <C-_>
      '';
    };
  };
}
