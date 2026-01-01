{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      vim-hybrid-material
    ];

    opts = {
      termguicolors = true;
      background = "dark";
    };

    globals = {
      enable_bold_font = 1;
    };

    extraConfigLua = ''
      -- Enable true color
      vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1

      -- Set initial colorscheme
      vim.cmd("colorscheme hybrid_reverse")

      -- Toggle between dark and light variants
      vim.api.nvim_create_user_command("ToggleTheme", function()
        if vim.opt.background:get() == "dark" then
          vim.opt.background = "light"
          vim.cmd("colorscheme hybrid_material")
        else
          vim.opt.background = "dark"
          vim.cmd("colorscheme hybrid_reverse")
        end
      end, {})
    '';

    keymaps = [
      {
        mode = "n";
        key = "<Leader>tt";
        action = "<cmd>ToggleTheme<CR>";
        options.desc = "Toggle between dark and light themes";
      }
    ];
  };
}
