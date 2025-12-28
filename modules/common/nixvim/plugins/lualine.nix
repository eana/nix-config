_:

{
  programs.nixvim.plugins.lualine = {
    enable = true;
    settings = {
      options = {
        section_separators = {
          left = "";
          right = "";
        };
        component_separators = {
          left = "";
          right = "";
        };
        theme = "material";
      };

      # One status line for all windows
      globalstatus = true;

      sections = {
        lualine_a = [ "mode" ];
        lualine_b = [
          "branch"
          "diff"
          "diagnostics"
        ];
        lualine_c = [
          {
            __unkeyed = "filename";
            path = 1;
          }
        ];
        lualine_x = [
          "encoding"
          "fileformat"
          {
            __unkeyed = "filetype";
            colored = false;
          }
        ];
        lualine_y = [ "progress" ];
        lualine_z = [ "location" ];
      };
    };
  };
}
