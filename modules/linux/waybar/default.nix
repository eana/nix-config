{
  config,
  lib,
  ...
}:

let
  cfg = config.module.waybar;

in
{
  imports = [ ./interface.nix ];

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      inherit (cfg) package;
      inherit (cfg) settings;
      inherit (cfg) style;
      systemd = lib.mkIf cfg.systemdIntegration.enable {
        enable = true;
        inherit (cfg.systemdIntegration) targets;
      };
    };
  };
}
