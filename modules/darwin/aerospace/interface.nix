{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.aerospace;

  terminalPackage = config.module.kitty.package or pkgs.kitty;

  defaultKeybindings = {
    # Reload configuration; show a desktop notification as feedback.
    # Must be an array: the ; operator would put exec-and-forget into the
    # shell context, where it is unavailable (config-only command).
    "${cfg.modifier}-shift-r" = [
      "reload-config"
      "exec-and-forget osascript -e 'display notification \"Config reloaded\" with title \"Aerospace\"'"
    ];

    # Terminal. kitty inherits AeroSpace's cwd (launchd: /) unless
    # --directory is given; pass ~ so kitty starts in the home directory.
    "${cfg.modifier}-enter" = "exec-and-forget ${terminalPackage}/bin/kitty --directory ~";

    # Telegram. Launch the raw binary, not `open`: LaunchServices-launched
    # (open) processes are invisible to AeroSpace and open unmanaged.
    "${cfg.modifier}-alt-t" =
      "exec-and-forget ${pkgs.telegram-desktop}/Applications/Telegram.app/Contents/MacOS/Telegram";

    # Focus. Arrow keys need cmd+alt: Karabiner remaps Home/End to plain
    # cmd+left/right globally (hosts/macbox/home-manager/karabiner.nix), so
    # cmd+arrows would be swallowed and break Home/End in apps. cmd+alt+arrows
    # conflicts with nothing (Karabiner: plain cmd; kitty: opt or cmd).
    "${cfg.modifier}-alt-left" = "focus left";
    "${cfg.modifier}-alt-down" = "focus down";
    "${cfg.modifier}-alt-up" = "focus up";
    "${cfg.modifier}-alt-right" = "focus right";

    # Move windows
    "${cfg.modifier}-shift-left" = "move left";
    "${cfg.modifier}-shift-down" = "move down";
    "${cfg.modifier}-shift-up" = "move up";
    "${cfg.modifier}-shift-right" = "move right";

    # Workspaces
    "${cfg.modifier}-1" = "workspace 1";
    "${cfg.modifier}-2" = "workspace 2";
    "${cfg.modifier}-3" = "workspace 3";
    "${cfg.modifier}-4" = "workspace 4";
    "${cfg.modifier}-5" = "workspace 5";
    "${cfg.modifier}-6" = "workspace 6";
    "${cfg.modifier}-7" = "workspace 7";
    "${cfg.modifier}-shift-1" = "move-node-to-workspace 1";
    "${cfg.modifier}-shift-2" = "move-node-to-workspace 2";
    "${cfg.modifier}-shift-3" = "move-node-to-workspace 3";
    "${cfg.modifier}-shift-4" = "move-node-to-workspace 4";
    "${cfg.modifier}-shift-5" = "move-node-to-workspace 5";
    "${cfg.modifier}-shift-6" = "move-node-to-workspace 6";
    "${cfg.modifier}-shift-7" = "move-node-to-workspace 7";
    "${cfg.modifier}-ctrl-left" = "workspace --wrap-around prev";
    "${cfg.modifier}-ctrl-right" = "workspace --wrap-around next";

    # Toggle floating/tiling
    "${cfg.modifier}-shift-space" = "layout floating tiling";
  };

  # Keys that clash with macOS or common app shortcuts if bound to cmd
  # (AeroSpace consumes any combo it has a binding for, so it never reaches
  # the app). Keep these reachable on alt or cmd-shift instead.
  rescueKeybindings = {
    # Close focused window. cmd-q is the macOS quit reflex.
    "cmd-shift-q" = "close";

    # macOS owns cmd-tab (app switcher); AeroSpace cannot bind it.
    "alt-tab" = "workspace-back-and-forth";
    "alt-shift-tab" = "move-workspace-to-monitor --wrap-around next";

    # cmd-c/cmd-v are copy/paste.
    "alt-c" = "layout h_tiles";
    "alt-v" = "layout v_tiles";

    # cmd-f is find/search.
    "alt-f" = "fullscreen";

    # cmd-r is reload.
    "alt-r" = "mode resize";
  };

  effectiveKeybindings = defaultKeybindings // rescueKeybindings;
in
{
  options.module.aerospace = {
    enable = mkEnableOption "AeroSpace window manager";

    modifier = mkOption {
      type = types.str;
      default = "alt";
      description = "Modifier key for keybindings";
    };

    keybindings = mkOption {
      type = types.attrsOf (types.either types.str (types.listOf types.str));
      default = effectiveKeybindings;
      description = "AeroSpace keybindings configuration";
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "Additional AeroSpace configuration, merged into the generated config";
    };
  };
}
