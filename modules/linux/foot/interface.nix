{ lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption types;

  defaultFontFamily = "MesloLGS NF";
  defaultFontSize = 10;
  defaultDpiAware = true;
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
      default = { };
      description = "Foot configuration settings";
    };
  };
}
