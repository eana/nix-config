return {
  "stevearc/conform.nvim",
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
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      sh = { "shfmt" },
      terraform = { "terraform_fmt" },
      tf = { "terraform_fmt" },
      python = { "black" },
      nix = { "nixfmt" },
      go = { "gofmt", "goimports" },
      nu = { "topiary_nu" },
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
      shfmt = {
        prepend_args = { "-i", "2", "-ci" },
      },
      stylua = {
        prepend_args = { "--indent-type", "Spaces", "--indent-width", "2", "--line-endings", "Unix" },
      },
      topiary_nu = {
        command = "topiary",
        args = { "format", "--language", "nu" },
      },
    },
  },
}
