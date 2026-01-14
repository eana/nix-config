{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      themery-nvim
    ];

    extraConfigLua = ''
      require("themery").setup({
        themes = {
          {
            name = "Catppuccin Mocha",
            colorscheme = "catppuccin-mocha",
          },
          {
            name = "Gruvbox Material",
            colorscheme = "gruvbox-material",
          },
          {
            name = "Hybrid Material",
            colorscheme = "hybrid_reverse",
          },
        },
        livePreview = true,
      })
    '';

    keymaps = [
      {
        key = "<leader>ut";
        action = "<cmd>Themery<CR>";
        options.desc = "Theme switcher";
      }
    ];
  };
}
