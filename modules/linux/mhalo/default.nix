{
  config,
  lib,
  ...
}:

let
  cfg = config.module.mhalo;
in
{
  imports = [ ./interface.nix ];

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    wayland.windowManager.sway.config.keybindings = lib.mkIf (cfg.swayKeybinding != null) {
      "${cfg.swayKeybinding}" = "exec ${cfg.package}/bin/mhalo";
    };
  };
}
