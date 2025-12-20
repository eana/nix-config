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
  programs.nixvim = lib.mkIf cfg.enable {
    enable = true;

    # IMPORTANT: These are loaded as Nixvim-specific modules
    imports = [
      ./keymaps.nix
      ./nvim-cmp.nix
      ./lsp.nix
      ./bufferline.nix
      ./telescope.nix
      ./neo-tree.nix
      ./prettier.nix
      ./lsp-servers.nix
      ./treesitter.nix
      ./autopairs.nix
      ./whichkey.nix
      ./dashboard.nix
      ./efmls.nix
      ./lsp-format.nix
      ./conform.nix
    ];

    globals.mapleader = " ";
    clipboard.providers.wl-copy.enable = true;

    options = {
      number = true;
      relativenumber = false;
      shiftwidth = 2;
    };

    plugins = {
      nix.enable = true;
      lsp-lines.enable = true;
      lspkind.enable = true;
      neogit.enable = true;
      cmp-zsh.enable = true;
      noice.enable = true;
      nvim-colorizer.enable = true;
      luasnip.enable = true;
      rust-tools.enable = true;

      notify = {
        enable = true;
        timeout = 2000;
        fps = 120;
        stages = "fade";
      };
      airline = {
        enable = true;
        settings.theme = "catppuccin";
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      telescope-ui-select-nvim
      vim-jsbeautify
    ];

    extraConfigLua = ''
      if vim.g.neovide then
        vim.o.guifont = "Hurmit Nerd Font:h14"
        vim.keymap.set('n', '<C-S-s>', ':w<CR>')
        vim.keymap.set('v', '<C-S-c>', '"+y')
        vim.keymap.set('n', '<C-S-v>', '"+P')
        vim.keymap.set('v', '<C-S-v>', '"+P')
        vim.keymap.set('c', '<C-S-v>', '<C-R>+')
        vim.keymap.set('i', '<C-S-v>', '<ESC>l"+Pli')
      end
    '';

    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        transparentBackground = false;
      };
    };
  };
}
