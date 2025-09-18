return {
  "ibhagwan/fzf-lua",
  config = function()
    require("fzf-lua").setup({
      files = {
        fd_opts = [[--color=never --type f --hidden --follow --exclude .git]],
      },
      grep = {
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden",
      },
    })
  end,
}
