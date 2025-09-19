return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  ---@module 'bufferline'
  ---@type bufferline.userconfig
  opts = {
    options = {
      mode = "buffers",
      diagnostics = "nvim_lsp",
      offsets = {
        -- possibly dapui_stacks, bapui_breakpoints, dapui_scopes, dapui_console, dap-repl
        {
          filetype = "neo-tree",
          text = "neo-tree",
          text_align = "left",
          separator = true,
        },
        {
          filetype = "dapui_watches",
          text_align = "left",
          separator = true,
        },
      },
    },
  },
  init = function()
    vim.opt.termguicolors = true
  end,
}
