{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.foot;

  tokyoNight = import ../../common/colors/tokyo-night.nix;
  c = tokyoNight.hex;

  defaultFontFamily = "MesloLGS NF";
  defaultFontSize = 10;
  defaultDpiAware = true;

  mkFontString = family: size: "${family}:size=${toString size}";

  defaultSettings = {
    main = {
      term = "xterm-256color";
      font = mkFontString cfg.font.family cfg.font.size;
      dpi-aware = if cfg.dpiAware then "yes" else "no";
    };
    colors-dark = {
      inherit (c)
        foreground
        background
        dim0
        dim1
        ;
      regular0 = c.black; # black
      regular1 = c.red; # red
      regular2 = c.green; # green
      regular3 = c.yellow; # yellow
      regular4 = c.blue; # blue
      regular5 = c.magenta; # magenta
      regular6 = c.cyan; # cyan
      regular7 = c.white; # white
      bright0 = c.brightBlack; # bright black
      bright1 = c.brightRed; # bright red
      bright2 = c.brightGreen; # bright green
      bright3 = c.brightYellow; # bright yellow
      bright4 = c.brightBlue; # bright blue
      bright5 = c.brightMagenta; # bright magenta
      bright6 = c.brightCyan; # bright cyan
      bright7 = c.brightWhite; # bright white
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
  };
}
