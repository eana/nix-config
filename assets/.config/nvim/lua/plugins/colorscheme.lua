return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "default",
    },
  },
  {
    "kristijanhusak/vim-hybrid-material",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.enable_bold_font = 1
      vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
      vim.opt.termguicolors = true
      vim.opt.background = "dark"
      vim.cmd("colorscheme hybrid_reverse")

      -- Define a function to toggle between dark and light themes
      local function toggle_theme()
        if vim.opt.background:get() == "dark" then
          vim.opt.background = "light"
          vim.cmd("colorscheme hybrid_material") -- Use the light variant of the theme
        else
          vim.opt.background = "dark"
          vim.cmd("colorscheme hybrid_reverse") -- Use the dark variant of the theme
        end
      end

      -- Map a keybinding to toggle the theme (e.g., <Leader>tt)
      vim.keymap.set("n", "<Leader>tt", toggle_theme, { desc = "Toggle between dark and light themes" })
    end,
  },
}
