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
        terraform = { "terraform_fmt" },
        tf = { "terraform_fmt" },
        python = { "black" },
        d2 = { "d2" },
        nix = { "nixfmt" },
        go = { "gofmt", "goimports" },
        ["terraform-vars"] = { "terraform_fmt" },
        ["javascript"] = { "prettierd" },
        ["typescript"] = { "prettierd" },
        ["json"] = { "prettierd" },
        ["json5"] = { "prettierd" },
        ["jsonc"] = { "prettierd" },
        ["yaml"] = { "prettierd" },
        ["markdown"] = { "prettierd" },
        ["markdown.mdx"] = { "prettierd" },
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
