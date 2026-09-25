{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf recursiveUpdate;

  cfg = config.module.aerospace;

  tomlFormat = pkgs.formats.toml { };

  baseSettings = {
    "config-version" = 2;

    # Brew handles auto-start via AeroSpace's own launchd agent.
    "start-at-login" = true;

    # Match sway (tiles layout, no outer gaps)
    "default-root-container-layout" = "tiles";
    "default-root-container-orientation" = "auto";
    gaps = {
      inner.horizontal = 2;
      inner.vertical = 2;
    };

    # Keep 1-7 alive, mirroring sway's workspace count
    "persistent-workspaces" = [
      "1"
      "2"
      "3"
      "4"
      "5"
      "6"
      "7"
    ];

    # Float macOS system dialogs like sway's floating rules do
    "on-window-detected" = [
      {
        "if" = {
          "app-id" = "^com\\.apple\\.(SystemSettings|systempreferences)$";
        };
        run = "layout floating";
      }
      {
        "if" = {
          "app-id" = "^com\\.apple\\.calculator$";
        };
        run = "layout floating";
      }
    ];

    mode = {
      main.binding = cfg.keybindings;
      resize.binding = {
        h = "resize smart -50";
        j = "resize smart +50";
        k = "resize smart -50";
        l = "resize smart +50";
        left = "resize width -50";
        down = "resize height +50";
        up = "resize height -50";
        right = "resize width +50";
        enter = "mode main";
        esc = "mode main";
      };
    };
  };

  settings = recursiveUpdate baseSettings cfg.settings;
in
{
  imports = [ ./interface.nix ];

  config = mkIf cfg.enable {
    home.file.".aerospace.toml".source = tomlFormat.generate "aerospace.toml" settings;
  };
}
