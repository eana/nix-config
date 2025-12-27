_:

{
  programs.nixvim = {
    extraConfigLua = ''
      vim.api.nvim_create_autocmd("User", {
        pattern = "PersistenceSavePre",
        callback = function()
          pcall(vim.cmd, "Neotree close")
        end,
      })
    '';

    plugins.persistence = {
      enable = true;

      options = [
        "buffers"
        "curdir"
        "tabpages"
        "winsize"
        "help"
        "globals"
        "skiprtp"
        "folds"
      ];
    };
  };
}
