{ config, lib, pkgs, ... }:

let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz";
    sha256 = "0n047422nnk5f0z6s8jkvdhq3qy7lyjc6fv3dk12gb6chsx2457h";
  };
in
{
  imports = [ "${home-manager}/nixos" ];

  home-manager.users.eric = {
    home.stateVersion = "23.05";
    nixpkgs.overlays = [
      (self: super: { lsd = pkgs.unstable.lsd; })
    ];

    programs.lsd = {
      enable = true;
      settings = {
        date = "relative";
        ignore-globs = [ ".git" ];
        sorting = {
          dir-grouping = "first";
        };
        total-size = true;
      };
    };

    programs.git = {
      enable = true;
      userName = "Eric Tedor";
      userEmail = "eric@tedor.org";
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
      };
    };

    programs.ssh = {
      enable = true;
      matchBlocks = {
        "code" = {
          hostname = "10.0.2.153";
          user = "eric";
        };
        "duke" = {
          hostname = "10.0.5.202";
          user = "eric";
        };
        "rt-sea" = {
          hostname = "10.127.99.1";
          user = "eric";
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
