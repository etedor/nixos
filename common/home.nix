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

    programs.tmux = {
      enable = true;
      mouse = true;
      baseIndex = 1;
      historyLimit = 50000; # 50,000 lines in history
      package = pkgs.tmux;
      terminal = "screen-256color";
      escapeTime = 0;
      prefix = "C-b"; # Using Ctrl-a as the prefix key instead of the default Ctrl-b
      newSession = true;
      plugins = with pkgs; [
        tmuxPlugins.resurrect
        {
          plugin = tmuxPlugins.yank;
          extraConfig = "set -g @plugin 'tmux-plugins/tmux-yank'";
        }
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '60' # Save every 60 minutes
          '';
        }
      ];
      extraConfig = ''
        set-option -g set-clipboard on # Enables clipboard integration
        bind r source-file ~/.tmux.conf \; display-message "~/.tmux.conf reloaded" # Keybind to reload tmux config
      '';
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

