local not_vscode = not vim.g.vscode

return {
  -- nvim-treesitter
  {
    "nvim-treesitter/nvim-treesitter",

    version = false,
    build = ":TSUpdate",

    cmd = { "TSInstall", "TSUpdate", "TSBufEnable", "TSBufDisable", "TSBufToggle", "TSModuleInfo" },
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "<C-space>", desc = "Increment selection" },
      { "<bs>", desc = "Decrement selection", mode = "x" },
    },
    opts = {
      highlight = {
        enable = not_vscode,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,

        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      context_commentstring = { enable = true, enable_autocmd = false },
      ensure_installed = {
        "bash",
        "comment",
        "diff",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "hcl",
        "html",
        "javascript",
        "json",
        "json5",
        "jsonc",
        "lua",
        "luadoc",
        "make",
        "markdown",
        "markdown_inline",
        "nix",
        "python",
        "query",
        "regex",
        "sql",
        "terraform",
        "toml",
        "vim",
        "vimdoc",
        "yaml",
      },
      auto_install = true,
    },
    main = "nvim-treesitter.configs",
    config = true,
  },
}
