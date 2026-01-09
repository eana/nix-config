_:

{
  programs.nixvim = {
    colorschemes.gruvbox-material = {
      enable = true;
      settings = {
        enable_bold = 1;
        enable_italic = 1;
        foreground = "material";
        spell_foreground = "colored";
        material_cursor = "green";
        material_better_performance = 1;
      };
    };

    extraConfigLua = ''
      vim.cmd("colorscheme gruvbox-material")

      vim.api.nvim_create_user_command("ToggleTheme", function()
        if vim.opt.background:get() == "dark" then
          vim.opt.background = "light"
        else
          vim.opt.background = "dark"
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
