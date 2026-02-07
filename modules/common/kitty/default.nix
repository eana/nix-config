{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  cfg = config.module.kitty;

  defaultFontFamily = "MesloLGS NF";
  defaultFontSize = 11.0;

  defaultSettings = {
    scrollback_lines = 10000;
    enable_audio_bell = false;
    confirm_os_window_close = 0;
    update_check_interval = 0;
  };

  defaultColors = {
    foreground = "#c0caf5";
    background = "#1a1b26";
    color0 = "#81807f";
    color1 = "#f7768e";
    color2 = "#9ece6a";
    color3 = "#e0af68";
    color4 = "#7aa2f7";
    color5 = "#bb9af7";
    color6 = "#7dcfff";
    color7 = "#a9b1d6";
    color8 = "#414868";
    color9 = "#f7768e";
    color10 = "#9ece6a";
    color11 = "#e0af68";
    color12 = "#7aa2f7";
    color13 = "#bb9af7";
    color14 = "#7dcfff";
    color15 = "#c0caf5";
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

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      inherit (cfg) package;

      font = {
        name = cfg.font.family;
        inherit (cfg.font) size;
      }
      // lib.optionalAttrs (cfg.font.package != null) {
        inherit (cfg.font) package;
      };

      settings = lib.recursiveUpdate defaultSettings (
        cfg.settings
        // {
          background_opacity = toString cfg.appearance.opacity;
        }
      );

      extraConfig = ''
        # Color scheme
        foreground ${cfg.appearance.colors.foreground}
        background ${cfg.appearance.colors.background}
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: value: "${name} ${value}") cfg.appearance.colors
        )}

        # Keybindings
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (key: action: "map ${key} ${action}") cfg.keybindings
        )}

        ${cfg.extraConfig}
      '';
    };
  };
}
