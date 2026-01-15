_:

{
  programs.nixvim.plugins.mini = {
    enable = true;
    mockDevIcons = true;
    modules = {
      icons = { };
      indentscope = {
        symbol = "│";
        draw = {
          delay = 0;
          animation.__raw = "require('mini.indentscope').gen_animation.none()";
        };
      };
      surround = {
        mappings = {
          add = "gsa";
          delete = "gsd";
          find = "gsf";
          find_left = "gsF";
          highlight = "gsh";
          replace = "gsr";
          update_n_lines = "gsn";
        };
      };
    };
  };
}
