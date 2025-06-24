{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.wezterm;
  weztermPkg = import ./package.nix { inherit lib pkgs; };

  defaultFontFamily = "MesloLGS NF";
  defaultFontSize = 16;
  defaultColorScheme = "Oxocarbon Dark (Gogh)";

  baseConfig = ''
    local wezterm = require("wezterm")
    local act = wezterm.action

    local config = {}
    local mouse_bindings = {}
    local launch_menu = {}

    if wezterm.config_builder then
      config = wezterm.config_builder()
    end

    config.color_scheme = "${cfg.colorScheme}"
    config.font = wezterm.font("${cfg.font.family}")
    config.font_size = ${toString cfg.font.size}
    config.launch_menu = launch_menu

    config.hide_tab_bar_if_only_one_tab = true

    config.default_cursor_style = "BlinkingBar"
    config.disable_default_key_bindings = true
    config.audible_bell = "Disabled"

    config.foreground_text_hsb = {
      hue = 1.0,
      saturation = 1.2,
      brightness = 1.5,
    }

    ${cfg.extraConfig}

    return config
  '';

in
{
  options.module.wezterm = {
    enable = mkEnableOption "Wezterm terminal emulator";

    package = mkOption {
      type = types.package;
      default = weztermPkg;
      description = "Customized Wezterm package";
    };

    colorScheme = mkOption {
      type = types.str;
      default = defaultColorScheme;
      description = "Color scheme for Wezterm";
    };

    font = {
      family = mkOption {
        type = types.str;
        default = defaultFontFamily;
        description = "Font family for Wezterm terminal";
      };

      size = mkOption {
        type = types.ints.positive;
        default = defaultFontSize;
        description = "Font size for Wezterm terminal";
      };
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra configuration in Lua to append to the config file";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.wezterm = {
      enable = true;
      inherit (cfg) package;
      extraConfig = baseConfig;
    };
  };
}
