{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkMerge
    types
    ;

  cfgModule = config.module.niri;
  cfg = config.wayland.windowManager.niri;

  defaultSettings = {
    input = {
      workspace-auto-back-and-forth = [ ];
      keyboard = {
        xkb = {
          layout = "us,se";
          options = "ctrl:nocaps,grp:win_space_toggle";
        };
        repeat-delay = 500;
        repeat-rate = 33;
      };
      touchpad = {
        tap = [ ];
        dwt = [ ];
        natural-scroll = [ ];
      };
    };

    layout = {
      gaps = 5;
      focus-ring.width = 2;
      always-center-single-column = [ ];
      tab-indicator = {
        position = "bottom";
        hide-when-single-tab = [ ];
      };
    };

    environment = {
      DISPLAY = ":0";
    };

    binds = {
      "Mod+Return".spawn = "foot";
      "Ctrl+Alt+Delete".quit = [ ];
      "Mod+Shift+P".power-off-monitors = [ ];
      "Mod+Shift+Slash".show-hotkey-overlay = [ ];
      "Print".screenshot = [ ];
      "Ctrl+Print".screenshot-screen = [ ];
      "Alt+Print".screenshot-window = [ ];
      "Mod+Q".close-window = [ ];

      "Mod+H".focus-column-left = [ ];
      "Mod+J".focus-window-down = [ ];
      "Mod+K".focus-window-up = [ ];
      "Mod+L".focus-column-right = [ ];
      "Mod+Ctrl+H".move-column-left = [ ];
      "Mod+Ctrl+J".move-window-down = [ ];
      "Mod+Ctrl+K".move-window-up = [ ];
      "Mod+Ctrl+L".move-column-right = [ ];

      "Mod+Home".focus-column-first = [ ];
      "Mod+End".focus-column-last = [ ];
      "Mod+Ctrl+Home".move-column-to-first = [ ];
      "Mod+Ctrl+End".move-column-to-last = [ ];

      "Mod+Shift+H".focus-monitor-left = [ ];
      "Mod+Shift+J".focus-monitor-down = [ ];
      "Mod+Shift+K".focus-monitor-up = [ ];
      "Mod+Shift+L".focus-monitor-right = [ ];
      "Mod+Shift+Ctrl+H".move-column-to-monitor-left = [ ];
      "Mod+Shift+Ctrl+J".move-column-to-monitor-down = [ ];
      "Mod+Shift+Ctrl+K".move-column-to-monitor-up = [ ];
      "Mod+Shift+Ctrl+L".move-column-to-monitor-right = [ ];

      "Mod+U".focus-workspace-down = [ ];
      "Mod+I".focus-workspace-up = [ ];
      "Mod+Ctrl+U".move-column-to-workspace-down = [ ];
      "Mod+Ctrl+I".move-column-to-workspace-up = [ ];
      "Mod+Shift+U".move-workspace-down = [ ];
      "Mod+Shift+I".move-workspace-up = [ ];
      "Mod+O".toggle-overview = [ ];

      "Mod+1".focus-workspace = [ 1 ];
      "Mod+2".focus-workspace = [ 2 ];
      "Mod+3".focus-workspace = [ 3 ];
      "Mod+4".focus-workspace = [ 4 ];
      "Mod+5".focus-workspace = [ 5 ];
      "Mod+6".focus-workspace = [ 6 ];
      "Mod+7".focus-workspace = [ 7 ];
      "Mod+8".focus-workspace = [ 8 ];
      "Mod+9".focus-workspace = [ 9 ];
      "Mod+Ctrl+1".move-column-to-workspace = [ 1 ];
      "Mod+Ctrl+2".move-column-to-workspace = [ 2 ];
      "Mod+Ctrl+3".move-column-to-workspace = [ 3 ];
      "Mod+Ctrl+4".move-column-to-workspace = [ 4 ];
      "Mod+Ctrl+5".move-column-to-workspace = [ 5 ];
      "Mod+Ctrl+6".move-column-to-workspace = [ 6 ];
      "Mod+Ctrl+7".move-column-to-workspace = [ 7 ];
      "Mod+Ctrl+8".move-column-to-workspace = [ 8 ];
      "Mod+Ctrl+9".move-column-to-workspace = [ 9 ];

      "Mod+BracketLeft".consume-or-expel-window-left = [ ];
      "Mod+BracketRight".consume-or-expel-window-right = [ ];
      "Mod+Comma".consume-window-into-column = [ ];
      "Mod+Period".expel-window-from-column = [ ];

      "Mod+R".switch-preset-column-width = [ ];
      "Mod+Shift+R".switch-preset-window-height = [ ];
      "Mod+Ctrl+R".reset-window-height = [ ];
      "Mod+F".maximize-column = [ ];
      "Mod+Shift+F".fullscreen-window = [ ];
      "Mod+Ctrl+Shift+F".toggle-windowed-fullscreen = [ ];
      "Mod+Ctrl+F".expand-column-to-available-width = [ ];
      "Mod+C".center-column = [ ];
      "Mod+Shift+C".center-visible-columns = [ ];

      "Mod+Minus".set-column-width = [ "-10%" ];
      "Mod+Equal".set-column-width = [ "+10%" ];
      "Mod+Shift+Minus".set-window-height = [ "-10%" ];
      "Mod+Shift+Equal".set-window-height = [ "+10%" ];

      "Mod+V".toggle-window-floating = [ ];
      "Mod+Shift+V".switch-focus-between-floating-and-tiling = [ ];
      "Mod+W".toggle-column-tabbed-display = [ ];

      "Mod+Shift+Return".spawn = [
        "dms"
        "ipc"
        "call"
        "spotlight"
        "open"
      ];
      "Super+Alt+L".spawn = [
        "dms"
        "ipc"
        "call"
        "lock"
        "lock"
      ];

      XF86MonBrightnessUp = {
        _props.allow-when-locked = true;
        spawn = [
          "dms"
          "ipc"
          "call"
          "brightness"
          "increment"
          "5"
          ""
        ];
      };
      XF86MonBrightnessDown = {
        _props.allow-when-locked = true;
        spawn = [
          "dms"
          "ipc"
          "call"
          "brightness"
          "decrement"
          "5"
          ""
        ];
      };

      XF86AudioRaiseVolume = {
        _props.allow-when-locked = true;
        spawn = [
          "dms"
          "ipc"
          "call"
          "audio"
          "increment"
          "5"
        ];
      };
      XF86AudioLowerVolume = {
        _props.allow-when-locked = true;
        spawn = [
          "dms"
          "ipc"
          "call"
          "audio"
          "decrement"
          "5"
        ];
      };
      XF86AudioMute = {
        _props.allow-when-locked = true;
        spawn = [
          "dms"
          "ipc"
          "call"
          "audio"
          "mute"
        ];
      };
      XF86AudioMicMute = {
        _props.allow-when-locked = true;
        spawn = [
          "dms"
          "ipc"
          "call"
          "audio"
          "micmute"
        ];
      };

      XF86AudioPlay = {
        _props.allow-when-locked = true;
        spawn = [
          "dms"
          "ipc"
          "call"
          "mpris"
          "playPause"
        ];
      };
      XF86AudioNext = {
        _props.allow-when-locked = true;
        spawn = [
          "dms"
          "ipc"
          "call"
          "mpris"
          "next"
        ];
      };
      XF86AudioPrev = {
        _props.allow-when-locked = true;
        spawn = [
          "dms"
          "ipc"
          "call"
          "mpris"
          "previous"
        ];
      };
    };
  };

  defaultWindowRules = [
    {
      match._props.app-id = "foot";
      default-column-display = "tabbed";
    }
    {
      match._props.app-id = "brave-browser";
      default-column-display = "tabbed";
    }
    {
      match._props = {
        app-id = "krita";
        title = "^Krita";
      };
      open-fullscreen = true;
    }
    {
      match._props.app-id = "krita";
      exclude._props.title = "^Krita";
      open-floating = true;
      open-focused = true;
    }
  ];

  toKDL = lib.hm.generators.toKDL { };

  spawnAtStartupKDL =
    if cfg.spawnAtStartup == [ ] then
      ""
    else
      builtins.concatStringsSep "\n" (
        map (spawn-at-startup: toKDL { inherit spawn-at-startup; }) cfg.spawnAtStartup
      );

  windowRulesKDL =
    if cfg.windowRules == [ ] then
      ""
    else
      builtins.concatStringsSep "\n" (map (window-rule: toKDL { inherit window-rule; }) cfg.windowRules);

  extraConfigCombined = lib.concatStringsSep "\n" (
    lib.filter (s: s != "") [
      spawnAtStartupKDL
      windowRulesKDL
      cfg.extraConfig
    ]
  );

  configFile = pkgs.writeText "niri-config.kdl" (
    lib.concatStringsSep "\n" (
      (lib.optional (cfg.settings != { }) (toKDL cfg.settings))
      ++ (lib.optional (extraConfigCombined != "") extraConfigCombined)
    )
  );

  variables = builtins.concatStringsSep " " cfg.systemd.variables;
  extraCommands = builtins.concatStringsSep " " (map (f: "&& ${f}") cfg.systemd.extraCommands);
  systemdActivation = ''
    ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd ${variables} ${extraCommands}
  '';

  checkNiriConfig = pkgs.runCommandLocal "niri-config" { buildInputs = [ cfg.package ]; } ''
    niri validate --config ${configFile}
    cp ${configFile} $out
  '';

in
{
  options = {
    module.niri = {
      enable = mkEnableOption "Niri Wayland compositor (Home Manager)";

      package = mkOption {
        type = types.nullOr types.package;
        default = pkgs.niri;
        description = "The Niri package to add to the user's environment.";
      };

      portalPackage = mkOption {
        type = types.nullOr types.package;
        default = pkgs.xdg-desktop-portal-gnome;
        description = "Portal package to use alongside Niri.";
      };

      xwaylandEnable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to start xwayland-satellite for XWayland support.";
      };

      systemdEnable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable systemd integration via niri-session.target.";
      };

      systemdVariables = mkOption {
        type = types.listOf types.str;
        default = [
          "DISPLAY"
          "WAYLAND_DISPLAY"
          "XDG_CURRENT_DESKTOP"
          "NIXOS_OZONE_WL"
          "XCURSOR_THEME"
          "XCURSOR_SIZE"
        ];
        description = "Environment variables imported into the systemd user environment.";
      };

      systemdExtraCommands = mkOption {
        type = types.listOf types.str;
        default = [
          "systemctl --user stop niri-session.target"
          "systemctl --user start niri-session.target"
        ];
        description = "Extra commands run after D-Bus activation.";
      };

      settings = mkOption {
        type = types.attrsOf types.anything;
        default = defaultSettings;
        description = "Niri settings written to the generated KDL config.";
      };

      spawnAtStartup = mkOption {
        type =
          with types;
          listOf (oneOf [
            str
            (listOf str)
          ]);
        default = [ ];
        apply = lib.unique;
        description = "Additional commands to run when Niri starts.";
      };

      windowRules = mkOption {
        type = with types; listOf (attrsOf anything);
        default = defaultWindowRules;
        description = "Window rules forwarded to Niri's configuration.";
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Extra KDL configuration appended to the generated file.";
      };
    };

    wayland.windowManager.niri = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable configuration for Niri, a scrollable-tiling Wayland
          compositor.

          ::: {.note}
          This module configures Niri and adds it to your user's {env}`PATH`,
          but does not make certain system-level changes. NixOS users should
          enable the NixOS module with {option}`programs.niri.enable`, which
          makes system-level changes such as adding a desktop session entry.
          :::
        '';
      };

      package = lib.mkPackageOption pkgs "niri" {
        nullable = true;
        extraDescription = "Set this to null if you use the NixOS module to install Niri.";
      };

      portalPackage = lib.mkPackageOption pkgs "xdg-desktop-portal-gnome" {
        nullable = true;
      };

      xwayland.enable = mkEnableOption "XWayland" // {
        default = true;
      };

      systemd = {
        enable = mkEnableOption null // {
          default = true;
          description = ''
            Whether to enable {file}`niri-session.target` on
            niri startup. This links to {file}`graphical-session.target`}.
            Some important environment variables will be imported to systemd
            and D-Bus user environment before reaching the target, including
            - `DISPLAY`
            - `WAYLAND_DISPLAY`
            - `XDG_CURRENT_DESKTOP`
            - `NIXOS_OZONE_WL`
            - `XCURSOR_THEME`
            - `XCURSOR_SIZE`
          '';
        };

        variables = mkOption {
          type = types.listOf types.str;
          default = [
            "DISPLAY"
            "WAYLAND_DISPLAY"
            "XDG_CURRENT_DESKTOP"
            "NIXOS_OZONE_WL"
            "XCURSOR_THEME"
            "XCURSOR_SIZE"
          ];
          example = [ "-all" ];
          description = ''
            Environment variables to be imported in the systemd & D-Bus user
            environment.
          '';
        };

        extraCommands = mkOption {
          type = types.listOf types.str;
          default = [
            "systemctl --user stop niri-session.target"
            "systemctl --user start niri-session.target"
          ];
          description = "Extra commands to be run after D-Bus activation.";
        };
      };

      settings = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        example = lib.literalExpression ''
          {
            input = {
              keyboard = {
                xkb.options = "ctrl:nocaps";
                repeat-delay = 500;
                repeat-rate = 33;
              };
              touchpad = {
                tap = [ ];
                natural-scroll = [ ];
              };
            };

            spawn-at-startup = "waybar";

            binds = {
              "Mod+Space".spawn = "fuzzel";
              "Super+Alt+L".spawn = "swaylock";
              "Ctrl+Alt+Delete".quit = [ ];
            };
          }
        '';
        description = ''
          Configuration written to
          {file}`$XDG_CONFIG_HOME/niri/config.kdl`.

          See <https://github.com/YaLTeR/niri/wiki/Configuration:-Overview> for the full
          list of options.
        '';
      };

      spawnAtStartup = mkOption {
        type =
          with types;
          listOf (oneOf [
            str
            (listOf str)
          ]);
        default = [ ];
        apply = lib.unique;
        example = lib.literalExpression ''
          [
            "waybar"
            [ "fcitx5" "-d" ]
          ]
        '';
        description = "Processes to spawn at niri startup.";
      };

      windowRules = mkOption {
        type = with types; listOf (attrsOf anything);
        default = [ ];
        example = lib.literalExpression ''
          [
            {
              match._props = {
                app-id = "firefox$"
                title = "^Picture-in-Picture$"
              };
              open-floating = true
            }
          ]
        '';
        description = ''
          Window rules to adjust behavior for individual windows.
        '';
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        example = ''
          input {
              keyboard {
                  xkb {
                      options "ctrl:nocaps"
                  }
              }
              touchpad {
                  tap
                  natural-scroll
              }
          }

          binds {
              Mod+Shift+Slash { show-hotkey-overlay; }
              Mod+T hotkey-overlay-title="Open a Terminal: alacritty" { spawn "alacritty"; }
              Mod+D hotkey-overlay-title="Run an Application: fuzzel" { spawn "fuzzel"; }
              Super+Alt+L hotkey-overlay-title="Lock the Screen: swaylock" { spawn "swaylock"; }
          }
        '';
        description = ''
          Extra configuration lines to add to {file}`$XDG_CONFIG_HOME/niri/config.kdl`.
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf cfgModule.enable {
      wayland.windowManager.niri = {
        enable = true;
        inherit (cfgModule) package;
        inherit (cfgModule) portalPackage;
        xwayland.enable = cfgModule.xwaylandEnable;
        systemd = {
          enable = cfgModule.systemdEnable;
          variables = cfgModule.systemdVariables;
          extraCommands = cfgModule.systemdExtraCommands;
        };
        settings = lib.mkMerge [
          defaultSettings
          cfgModule.settings
        ];
        windowRules = defaultWindowRules ++ cfgModule.windowRules;
        inherit (cfgModule) spawnAtStartup;
        inherit (cfgModule) extraConfig;
      };
    })

    (mkIf cfg.enable {
      assertions = [
        (lib.hm.assertions.assertPlatform "wayland.windowManager.niri" pkgs lib.platforms.linux)
      ];

      home.packages = mkIf (cfg.package != null) (
        [ cfg.package ] ++ lib.optional cfg.xwayland.enable pkgs.xwayland-satellite
      );

      wayland.windowManager.niri = mkMerge [
        (mkIf cfg.systemd.enable {
          spawnAtStartup = [ systemdActivation ];
        })

        (mkIf cfg.xwayland.enable {
          spawnAtStartup = [ "xwayland-satellite" ];
        })

        (mkIf (cfg.spawnAtStartup != [ ]) {
          extraConfig = spawnAtStartupKDL;
        })

        (mkIf (cfg.windowRules != defaultWindowRules) {
          extraConfig = windowRulesKDL;
        })
      ];

      xdg.configFile."niri/config.kdl" = mkIf (cfg.settings != { } || cfg.extraConfig != "") {
        source = checkNiriConfig;
      };

      xdg.portal = {
        enable = cfg.portalPackage != null;
        extraPortals = mkIf (cfg.portalPackage != null) [ cfg.portalPackage ];
        configPackages = mkIf (cfg.package != null) (lib.mkDefault [ cfg.package ]);
      };

      systemd.user.targets.niri-session = mkIf cfg.systemd.enable {
        Unit = {
          Description = "niri compositor session";
          Documentation = [ "man:systemd.special(7)" ];
          BindsTo = [ "graphical-session.target" ];
          Wants = [ "graphical-session-pre.target" ];
          After = [ "graphical-session-pre.target" ];
        };
      };
    })
  ];
}
