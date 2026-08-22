{ lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption types;

  mhaloPkg = pkgs.callPackage ./package.nix {
    inherit (pkgs.qt6) wrapQtAppsHook;
  };
in
{
  options.module.mhalo = {
    enable = mkEnableOption "mHalo mouse pointer effect";

    package = mkOption {
      type = types.package;
      default = mhaloPkg;
      description = "Custom mHalo package";
    };

    swayKeybinding = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Sway keybinding to launch mhalo";
    };
  };
}
