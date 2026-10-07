_:

{
  programs.nixvim.plugins.render-markdown = {
    enable = true;

    settings = {
      heading = {
        border = true;
        position = "inline";
      };
      code.border = "thick";
      bullet.icons = [
        "•"
        "◦"
        "▪"
      ];
    };
  };
}
