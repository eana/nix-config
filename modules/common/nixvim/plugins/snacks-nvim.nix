_:

{
  programs.nixvim = {
    plugins.snacks = {
      enable = true;

      settings = {
        bigfile.enabled = true;
        bufdelete.enabled = true;

        explorer = {
          enabled = true;
          replace_netrw = true;
        };

        picker = {
          enabled = true;
          ui_select = true;

          sources = {
            explorer = {
              hidden = true;
              ignored = true;
              layout.layout.width = 45;
            };
            files.hidden = true;
            grep.hidden = true;
          };
        };

        quickfile.enabled = true;
        rename.enabled = true;
      };
    };
  };
}
