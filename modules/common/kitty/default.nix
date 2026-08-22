{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  cfg = config.module.kitty;

  defaultSettings = {
    scrollback_lines = 10000;
    enable_audio_bell = false;
    confirm_os_window_close = 0;
    update_check_interval = 0;
  };

in
{
  imports = [ ./interface.nix ];

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      inherit (cfg) package;

      font = {
        name = cfg.font.family;
        inherit (cfg.font) size;
      }
      // lib.optionalAttrs (cfg.font.package != null) {
        inherit (cfg.font) package;
      };

      settings = lib.recursiveUpdate defaultSettings (
        cfg.settings
        // {
          background_opacity = toString cfg.appearance.opacity;
        }
      );

      extraConfig = ''
        # Color scheme
        foreground ${cfg.appearance.colors.foreground}
        background ${cfg.appearance.colors.background}
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: value: "${name} ${value}") cfg.appearance.colors
        )}

        # Keybindings
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (key: action: "map ${key} ${action}") cfg.keybindings
        )}

        ${cfg.extraConfig}
      '';
    };
  };
}
