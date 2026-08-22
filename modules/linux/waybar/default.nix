{
  config,
  lib,
  ...
}:

let
  cfg = config.module.waybar;
  custom = config.custom or { };
  palette =
    if (custom.theme or "tokyo-night") == "gruvbox" then
      {
        barBackground = "rgba(40, 40, 40, 0.5)";
        foreground = "#ebdbb2";
        hoverBackground = "rgba(80, 73, 69, 0.5)";
        activeIndicator = "#fabd2f";
        urgentBackground = "#cc241d";
        idleBackground = "#ebdbb2";
        idleForeground = "#282828";
        modeBackground = "#504945";
        moduleBorder = "#7c6f64";
        focusedBackground = "#665c54";
        focusedIndicator = "#ebdbb2";
        focusBackground = "#282828";
        blinkBackground = "#928374";
        blinkForeground = "#282828";
        batteryCritical = "#cc241d";
        batteryWarning = "#d79921";
        batteryCharging = "#98971a";
        cpuMemoryBorder = "#98971a";
        trayBorder = "#cc241d";
        poweroffColor = "#ebdbb2";
        poweroffBorder = "#cc241d";
        separatorColor = "#ebdbb2";
      }
    else
      {
        barBackground = "rgba(19, 13, 13, 0.5)";
        foreground = "#ffffff";
        hoverBackground = "rgba(0, 0, 0, 0.2)";
        activeIndicator = "#ffffff";
        urgentBackground = "#eb4d4b";
        idleBackground = "#ecf0f1";
        idleForeground = "#2d3436";
        modeBackground = "#64727d";
        moduleBorder = "#752c4e";
        focusedBackground = "#64727d";
        focusedIndicator = "#ffffff";
        focusBackground = "#000000";
        blinkBackground = "#b3b3b3";
        blinkForeground = "#31363b";
        batteryCritical = "#f53c3c";
        batteryWarning = "#8d7831";
        batteryCharging = "#26a65b";
        cpuMemoryBorder = "#0c6d1a";
        trayBorder = "#991121";
        poweroffColor = "#ffffff";
        poweroffBorder = "#ff0000";
        separatorColor = "#ffffff";
      };

in
{
  imports = [ ./interface.nix ];

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        module.waybar.style = lib.mkDefault ''
          * {
            border: 0;
            border-radius: 4px;
            font-family: "Font Awesome 5 Free";
            min-height: 0;
          }

          #waybar {
            background-color: ${palette.barBackground};
            color: ${palette.foreground};
          }

          #window,
          #workspaces,
          #backlight,
          #custom-scratchpad-indicator,
          #clock,
          #battery,
          #cpu,
          #memory,
          #temperature,
          #network,
          #pulseaudio,
          #tray,
          #mode,
          #idle_inhibitor {
            padding-left: 4px;
            padding-right: 4px;
          }

          #workspaces button.focused,
          #backlight,
          #battery,
          #cpu,
          #memory,
          #temperature,
          #network,
          #pulseaudio,
          #tray {
            border-bottom: 2.5px solid;
          }

          /* If workspaces is leftmost module, omit left margin */
          .modules-left > widget:first-child > #workspaces {
            margin-left: 0;
          }

          /* If workspaces is rightmost module, omit right margin */
          .modules-right > widget:last-child > #workspaces {
            margin-right: 0;
          }

          /* ---Left--- */
          #workspaces button {
            padding: 0 0.4em;
            border-radius: 0;
            background-color: transparent;
            color: ${palette.foreground};
            /* Use box-shadow instead of border so text is not offset */
            box-shadow: inset 0 -3px transparent;
          }

          /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
          #workspaces button:hover {
            background: ${palette.hoverBackground};
            border-bottom: 2.5px solid;
            box-shadow: inset 0 -3px ${palette.activeIndicator};
          }

          #workspaces button.focused {
            background-color: ${palette.focusedBackground};
            box-shadow: inset 0 -3px ${palette.focusedIndicator};
          }

          #workspaces button.urgent {
            background-color: ${palette.urgentBackground};
          }

          #idle_inhibitor.activated {
            background-color: ${palette.idleBackground};
            color: ${palette.idleForeground};
          }
          /* ---------- */

          /* ---Center--- */
          #mode {
            background-color: ${palette.modeBackground};
            border-bottom: 3px solid ${palette.activeIndicator};
          }
          /* ---------- */

          /* ---Right--- */
          #language,
          #backlight,
          #clock,
          #pulseaudio,
          #network,
          #battery {
            border-bottom: 2px solid ${palette.moduleBorder};
          }

          label:focus {
            background-color: ${palette.focusBackground};
          }

          @keyframes blink {
            to {
              background-color: ${palette.blinkBackground};
              color: ${palette.blinkForeground};
            }
          }

          #battery.discharging.critical {
            background-color: ${palette.batteryCritical};
            color: ${palette.foreground};
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
          }

          #battery.discharging.warning {
            background-color: ${palette.batteryWarning};
            color: ${palette.foreground};
          }

          #battery.charging {
            background-color: ${palette.batteryCharging};
          }

          #cpu,
          #memory {
            border-bottom-color: ${palette.cpuMemoryBorder};
          }

          #cpu.warning {
            background-color: ${palette.batteryWarning};
            color: ${palette.foreground};
          }

          #cpu.critical {
            background-color: ${palette.batteryCritical};
            color: ${palette.foreground};
          }

          #tray {
            border-bottom: 2px solid ${palette.trayBorder};
            margin-right: 2px;
          }

          #custom-poweroff {
            color: ${palette.poweroffColor};
            border-bottom: 2px solid ${palette.poweroffBorder};
            margin-right: 2px;
          }

          /* ---------- */

          #custom-separator {
            color: ${palette.separatorColor};
            margin: 0 3px;
          }

          #window {
            margin-right: 8px;
          }

          #window #waybar.hidden {
            opacity: 0.2;
          }
        '';
      }
      {
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
      }
    ]
  );
}
