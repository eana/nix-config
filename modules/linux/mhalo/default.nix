{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.module.mhalo;
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

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    wayland.windowManager.sway.config.keybindings = lib.mkIf (cfg.swayKeybinding != null) {
      "${cfg.swayKeybinding}" = "exec ${cfg.package}/bin/mhalo";
    };
  };
}
