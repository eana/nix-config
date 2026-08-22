{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    ;

  defaultFontFamily = "MesloLGS NF";
  defaultFontSize = 11.0;

  tokyoNight = import ../colors/tokyo-night.nix;
  c = tokyoNight.withHash;
  defaultColors = {
    inherit (c) foreground background;
    color0 = c.black;
    color1 = c.red;
    color2 = c.green;
    color3 = c.yellow;
    color4 = c.blue;
    color5 = c.magenta;
    color6 = c.cyan;
    color7 = c.white;
    color8 = c.brightBlack;
    color9 = c.brightRed;
    color10 = c.brightGreen;
    color11 = c.brightYellow;
    color12 = c.brightBlue;
    color13 = c.brightMagenta;
    color14 = c.brightCyan;
    color15 = c.brightWhite;
  };
in
{
  options.module.kitty = {
    enable = mkEnableOption "Kitty terminal emulator";

    package = mkOption {
      type = types.package;
      default = pkgs.kitty;
      description = "The fast, feature-rich, GPU based terminal emulator";
    };

    font = {
      family = mkOption {
        type = types.str;
        default = defaultFontFamily;
        description = "Font family for Kitty terminal";
      };

      size = mkOption {
        type = types.float;
        default = defaultFontSize;
        description = "Font size for Kitty terminal";
      };

      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = "Package providing the font for Kitty";
      };
    };

    appearance = {
      opacity = mkOption {
        type = types.float;
        default = 1.0;
        description = "Window opacity (0.0 transparent to 1.0 opaque)";
      };

      colors = mkOption {
        type = types.attrs;
        default = defaultColors;
        description = "Kitty color scheme settings";
      };
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "Additional Kitty configuration settings";
    };

    keybindings = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Kitty keybindings mapping";
      example = lib.literalExpression ''
        {
          "ctrl+shift+t" = "new_tab";
          "ctrl+shift+n" = "new_window";
          "shift+enter" = "send_text all \\x1b[13;2u";
          "ctrl+enter" = "send_text all \\x1b[13;5u";
        }
      '';
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional configuration for Kitty";
    };
  };
}
