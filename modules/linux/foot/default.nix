{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.foot;

  defaultFontFamily = "MesloLGS NF";
  defaultFontSize = 9;
  defaultDpiAware = true;

  mkFontString = family: size: "${family}:size=${toString size}";

  defaultSettings = {
    main = {
      term = "xterm-256color";
      font = mkFontString cfg.font.family cfg.font.size;
      dpi-aware = if cfg.dpiAware then "yes" else "no";
    };
    colors = {
      foreground = "c0caf5";
      background = "1a1b26";
      regular0 = "81807f"; # black
      regular1 = "f7768e"; # red
      regular2 = "9ece6a"; # green
      regular3 = "e0af68"; # yellow
      regular4 = "7aa2f7"; # blue
      regular5 = "bb9af7"; # magenta
      regular6 = "7dcfff"; # cyan
      regular7 = "a9b1d6"; # white
      bright0 = "414868"; # bright black
      bright1 = "f7768e"; # bright red
      bright2 = "9ece6a"; # bright green
      bright3 = "e0af68"; # bright yellow
      bright4 = "7aa2f7"; # bright blue
      bright5 = "bb9af7"; # bright magenta
      bright6 = "7dcfff"; # bright cyan
      bright7 = "c0caf5"; # bright white
      dim0 = "ff9e64";
      dim1 = "db4b4b";
    };
    mouse = {
      hide-when-typing = "yes";
    };
  };

in
{
  options.module.foot = {
    enable = mkEnableOption "Foot terminal emulator";

    package = mkOption {
      type = types.package;
      default = pkgs.foot;
      description = "Fast, lightweight and minimalistic Wayland terminal emulator";
    };

    font = {
      family = mkOption {
        type = types.str;
        default = defaultFontFamily;
        description = "Font family for Foot terminal";
      };

      size = mkOption {
        type = types.ints.positive;
        default = defaultFontSize;
        description = "Font size for Foot terminal";
      };
    };

    dpiAware = mkOption {
      type = types.bool;
      default = defaultDpiAware;
      description = "Whether Foot should be DPI-aware";
    };

    settings = mkOption {
      type = types.attrs;
      default = defaultSettings;
      description = "Foot configuration settings";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.foot = {
      enable = true;
      inherit (cfg) package;
      settings = lib.recursiveUpdate defaultSettings cfg.settings // {
        main =
          (defaultSettings.main or { })
          // (cfg.settings.main or { })
          // {
            font = mkFontString cfg.font.family cfg.font.size;
            dpi-aware = if cfg.dpiAware then "yes" else "no";
          };
      };
    };

    home.packages = [ cfg.package ];
  };
}
