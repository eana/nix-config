{
  plugins = {
    cmp-treesitter.enable = true;
    treesitter.enable = true;
    treesitter-refactor = {
      enable = true;
      highlightCurrentScope = {
        enable = true;
        disable = [ "nix" ];
      };
      highlightDefinitions.enable = true;
      navigation.enable = true;
      smartRename.enable = true;
    };
  };
}
