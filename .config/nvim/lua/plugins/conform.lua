local M = {}

return {
  "stevearc/conform.nvim",
  dependencies = { "mason.nvim" },
  lazy = true,
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cF",
      function()
        require("conform").format({ formatters = { "injected" } })
      end,
      mode = { "n", "v" },
      desc = "Format Injected Langs",
    },
  },
  opts = function()
    local opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        sh = { "shfmt" },
        vue = { "prettier" },
        ts = { "prettier" },
        terraform = { "terraform_fmt" },
        tf = { "terraform_fmt" },
        python = { "black" },
        d2 = { "d2" },
        nix = { "nixfmt" },
        go = { "gofmt", "goimports" },
        ["terraform-vars"] = { "terraform_fmt" },
        ["javascript"] = { "prettier" },
        ["typescript"] = { "prettier" },
        ["css"] = { "prettier" },
        ["scss"] = { "prettier" },
        ["less"] = { "prettier" },
        ["html"] = { "prettier" },
        ["json"] = { "prettier" },
        ["jsonc"] = { "prettier" },
        ["yaml"] = { "prettier" },
        ["markdown"] = { "prettier" },
        ["markdown.mdx"] = { "prettier" },
      },
      -- The options you set here will be merged with the builtin formatters.
      -- You can also define any custom formatters here.
      formatters = {
        injected = { options = { ignore_errors = true } },
        -- Example of using shfmt with extra args
        shfmt = {
          prepend_args = { "-i", "2", "-ci" },
        },
        stylua = {
          prepend_args = { "--indent-type", "Spaces", "--indent-width", "2", "--line-endings", "Unix" },
        },
      },
    }
    return opts
  end,
  config = M.setup,
}
