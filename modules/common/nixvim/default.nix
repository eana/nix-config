{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.module.nixvim;
in
{
  options.module.nixvim = {
    enable = lib.mkEnableOption "nixvim";
  };

  config = lib.mkIf cfg.enable {

    programs.nixvim = {
      enable = true;
      globals.mapleader = " ";

      clipboard = {
        register = "unnamedplus";
        providers.wl-copy.enable = pkgs.stdenv.hostPlatform.isLinux;
      };

      opts = {
        number = true;
        relativenumber = false;
        shiftwidth = 2;
      };

      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      colorschemes.gruvbox.enable = true;

      imports = [
        # ./keymaps.nix
        # ./nvim-cmp.nix
        # ./lsp.nix
        # ./bufferline.nix
        # ./telescope.nix
        # ./neo-tree.nix
        # ./prettier.nix
        # ./lsp-servers.nix
        # ./treesitter.nix
        # ./autopairs.nix
        # ./which-key.nix
        # ./dashboard.nix
        # ./efmls.nix
        # ./lsp-format.nix
        # ./conform.nix
      ];
    };
  };
}
