return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    animate = { enabled = false },
    dashboard = { enabled = false },
    dim = { enabled = false },
    explorer = { enabled = false },
    scroll = { enabled = false },
    zen = { enabled = false },
    terminal = {
      win = {
        relative = "editor",
        position = "float",
        width = 0.8,
        height = 0.8,
        border = "rounded",
      },
    },
  },
  keys = {
    {
      "<leader>\\",
      function()
        Snacks.terminal.toggle(nil, { cwd = vim.fn.getcwd() })
      end,
      mode = { "n", "t" },
      desc = "Toggle Terminal",
    },
  },
}
