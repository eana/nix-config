_:

{
  programs.nixvim.plugins.which-key = {
    enable = true;
    icons = {
      separator = "";
      group = "";
    };
    keyLabels = {
      "<leader>" = "SPC";
    };
    registrations = {
      "<leader>c" = "󰅙 Close Buffer";
      "<leader>t" = "󰙅 FileExplorer";
      "<leader>f" = " Telescope";
      "<leader>w" = " WhichKey?!";
      "<leader>ff" = " Find Files";
      "<leader>l" = " LSP";
      "<leader>lf" = "󰉡 Format Buffer";
    };
  };
}
