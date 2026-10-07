_:

{
  programs.nixvim.plugins.render-markdown = {
    enable = true;

    settings = {
      enabled = false;
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
