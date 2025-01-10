return {
  "mzlogin/vim-markdown-toc",
  cmd = { "GenTocGFM", "GenTocRedcarpet", "GenTocGitLab", "UpdateToc" },
  ft = "markdown",
  init = function()
    vim.g.vmt_auto_update_on_save = 1
  end,
}
