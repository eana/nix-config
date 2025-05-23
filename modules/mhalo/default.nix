{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.mhalo;

  mhaloPackage = pkgs.callPackage ./package.nix {
    inherit (pkgs) qt6;
    inherit (pkgs.qt6) wrapQtAppsHook;
  };

in
{
  options.module.mhalo = {
    enable = mkEnableOption "mHalo mouse pointer effect";
    package = mkOption {
      type = types.package;
      default = mhaloPackage;
      description = "The mHalo package to use";
    };
    swayKeybinding = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Sway keybinding to launch mhalo (e.g., "Mod4+Shift+h").
        Set to null to skip adding keybinding.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    wayland.windowManager.sway.config.keybindings = lib.mkIf (cfg.swayKeybinding != null) {
      "${cfg.swayKeybinding}" = "exec ${cfg.package}/bin/mhalo";
    };
  };
}
