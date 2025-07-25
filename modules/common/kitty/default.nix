{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.kitty;

  defaultFontFamily = "MesloLGS NF";
  defaultFontSize = 15.0;
  defaultOpacity = 1.0;

  defaultSettings = {
    scrollback_lines = 10000;
    enable_audio_bell = false;
    confirm_os_window_close = 0;
    background_opacity = toString defaultOpacity;
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

    opacity = mkOption {
      type = types.float;
      default = defaultOpacity;
      description = "Window opacity (0.0 transparent to 1.0 opaque)";
    };

    settings = mkOption {
      type = types.attrs;
      default = defaultSettings;
      description = "Kitty configuration settings";
    };

    colors = mkOption {
      type = types.attrs;
      default = defaultColors;
      description = "Kitty color settings";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional configuration for Kitty";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      inherit (cfg) package;
      font =
        {
          name = cfg.font.family;
          inherit (cfg.font) size;
        }
        // lib.optionalAttrs (cfg.font.package != null) {
          inherit (cfg.font) package;
        };
      settings = lib.recursiveUpdate defaultSettings (
        cfg.settings
        // {
          background_opacity = toString cfg.opacity;
        }
      );
      extraConfig = ''
        foreground ${cfg.colors.foreground}
        background ${cfg.colors.background}
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${name} ${value}") cfg.colors)}

        ${cfg.extraConfig}
      '';
    };
  };
}
