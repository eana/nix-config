return {
  {
    "LazyVim/LazyVim",
    version = "13.6.0",
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
    end,
  },
}
