return {
  "mfussenegger/nvim-lint",
  opts = {
    linters_by_ft = {
      sh = { "shellcheck" },
    },
    linters = {
      shellcheck = {
        append_fname = true,
      },
    },
  },
}
