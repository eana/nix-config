{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.waybar;
  waybarPkg = import ./package.nix { inherit lib pkgs; };

  gnome-calendar = "${pkgs.gnome-calendar}/bin/gnome-calendar";
  gnome-power-statistics = "${pkgs.gnome-power-manager}/bin/gnome-power-statistics";
  jq = "${pkgs.jq}/bin/jq";
  nm-connection-editor = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
  swaymsg = "${pkgs.sway}/bin/swaymsg";
  swaynag = "${pkgs.sway}/bin/swaynag";
  system-config-printer = "${pkgs.system-config-printer}/bin/system-config-printer";

in
{
  options.module.waybar = {
    enable = mkEnableOption "Waybar status bar";

    package = mkOption {
      type = types.package;
      default = waybarPkg;
      description = "Customized Waybar package";
    };

    systemdIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable systemd integration for Waybar";
    };

    settings = mkOption {
      type = types.attrs;
      default = {
        mainBar = {
          layer = "top";
          position = "bottom";
          height = 30;
          modules-left = [
            "sway/workspaces"
            "custom/separator"
            "custom/scratchpad-indicator"
            "custom/separator"
            "idle_inhibitor"
          ];
          modules-center = [ "sway/mode" ];
          modules-right = [
            "sway/language"
            "custom/separator"
            "custom/printer"
            "custom/separator"
            "pulseaudio"
            "backlight"
            "custom/separator"
            "battery"
            "custom/separator"
            "cpu"
            "memory"
            "custom/separator"
            "network#wireguard"
            "network#ovpn"
            "network#proton"
            "network#wifi"
            "network#ethernet"
            "network#disconnected"
            "custom/separator"
            "tray"
            "custom/separator"
            "clock"
            "custom/separator"
            "custom/poweroff"
          ];

          "sway/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
            format = "{name}: {icon}";
            format-icons = {
              "1" = "";
              "2" = "";
              "3" = "";
              "4" = "";
              "5" = "";
              "6" = "";
              "7" = "";
              "urgent" = "";
              "focused" = "";
              "default" = "";
            };
          };

          "custom/scratchpad-indicator" = {
            interval = 3;
            exec = ''
              ${swaymsg} -t get_tree | ${jq} 'select(.name == "root") | .nodes[] | select(.name == "__i3") | .nodes[] | select(.name == "__i3_scratch") | .floating_nodes | length'
            '';
            format = "{} ";
            on-click-right = "${swaymsg} 'scratchpad show'";
            on-click = "${swaymsg} 'move scratchpad'";
          };

          "custom/separator" = {
            interval = "once";
            format = "|";
            tooltip = false;
          };

          "idle_inhibitor" = {
            format = "{icon}";
            format-icons = {
              activated = "";
              deactivated = "";
            };
          };

          "sway/window" = {
            max-length = 50;
          };

          "sway/language" = {
            format = "  {short}";
            tooltip = false;
          };

          "custom/printer" = {
            tooltip-format = "{}";
            interval = 60;
            format = "";
            on-click = "${system-config-printer}";
          };

          "pulseaudio" = {
            format = "{icon} {volume}% {format_source}";
            format-bluetooth = "{icon} {volume}% {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = "🔇 {format_source}";
            format-source = "  {volume}%";
            format-source-muted = " ";
            format-icons = {
              "headphone" = "";
              "hands-free" = "";
              "headset" = "";
              "phone" = "";
              "portable" = "";
              "car" = "";
              "default" = [
                ""
                ""
              ];
            };
            scroll-step = 1;
            on-click = "${pavucontrol}";
          };

          "backlight" = {
            device = "intel_backlight";
            format = "{percent}% {icon}";
            format-icons = [
              ""
              ""
            ];
          };

          "battery" = {
            states = {
              warning = 25;
              critical = 10;
            };
            format = "{icon} {capacity}%";
            format-charging = " {icon} {capacity}%";
            format-full = " {icon} {capacity}%";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
            format-time = "{H}h{M}m";
            interval = 30;
            on-click = "${gnome-power-statistics}";
          };

          "cpu" = {
            interval = 5;
            format = " {usage}% ({load})";
            states = {
              warning = 70;
              critical = 90;
            };
          };

          "memory" = {
            interval = 30;
            format = " {used:0.1f}G/{total:0.1f}G";
          };

          "network#disconnected" = {
            tooltip-format = "No connection!";
            format-ethernet = "";
            format-wifi = "";
            format-linked = "";
            format-disconnected = "";
            on-click = "${nm-connection-editor}";
          };

          "network#ethernet" = {
            interface = "e*";
            format-ethernet = "";
            format-wifi = "";
            format-linked = "";
            format-disconnected = "";
            tooltip-format = "{ifname}: {ipaddr}/{cidr}";
            on-click = "${nm-connection-editor}";
          };

          "network#wifi" = {
            interface = "wl*";
            format-ethernet = "";
            format-wifi = "  ({signalStrength}%)";
            format-linked = "";
            format-disconnected = "";
            tooltip-format = "{essid}: {ifname}: {ipaddr}/{cidr}";
            on-click = "${nm-connection-editor}";
          };

          "network#wireguard" = {
            interface = "wg*";
            format = "🔒";
            format-disconnected = "";
            tooltip-format = "{ifname}: {ipaddr}/{cidr}";
            on-click = "${nm-connection-editor}";
          };

          "network#ovpn" = {
            interface = "tun*";
            format = "🔒";
            format-disconnected = "";
            tooltip-format = "{ifname}: {ipaddr}/{cidr}";
            on-click = "${nm-connection-editor}";
          };

          "network#proton" = {
            interface = "proton*";
            format = "🔒";
            format-disconnected = "";
            tooltip-format = "{ifname}: {ipaddr}/{cidr}";
            on-click = "${nm-connection-editor}";
          };

          "clock" = {
            interval = 1;
            format = " {:%H:%M %d-%m-%Y}";
            tooltip-format = ''
              <big>{:%Y %B}</big>
              <tt><big>{calendar}</big></tt>'';
            on-click = "${gnome-calendar}";
          };

          "tray" = {
            icon-size = 20;
            spacing = 5;
          };

          "custom/poweroff" = {
            tooltip = false;
            format = "";
            on-click = "${swaynag} -t warning -m 'Power Menu Options' -b 'Poweroff' 'systemctl poweroff' -b 'Reboot' 'systemctl reboot' -b 'Suspend' 'systemctl suspend' -b 'Logout' '${swaymsg} exit'";
          };
        };
      };
      description = "Waybar configuration settings";
    };

    style = mkOption {
      type = types.lines;
      default = ''
        * {
          border: 0;
          border-radius: 4px;
          font-family: "Font Awesome 5 Free";
          font-size: 16px;
          min-height: 0;
        }

        #waybar {
          background-color: rgba(19, 13, 13, 0.5);
          color: #ffffff;
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

        /* If workspaces is the leftmost module, omit left margin */
        .modules-left > widget:first-child > #workspaces {
          margin-left: 0;
        }

        /* If workspaces is the rightmost module, omit right margin */
        .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
        }

        /* ---Left--- */
        #workspaces button {
          padding: 0 0.4em;
          border-radius: 0;
          background-color: transparent;
          color: #ffffff;
          /* Use box-shadow instead of border so the text isn't offset */
          box-shadow: inset 0 -3px transparent;
        }

        /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
        #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
          border-bottom: 2.5px solid;
          box-shadow: inset 0 -3px #ffffff;
        }

        #workspaces button.focused {
          background-color: #64727d;
          box-shadow: inset 0 -3px #ffffff;
        }

        #workspaces button.urgent {
          background-color: #eb4d4b;
        }

        #idle_inhibitor.activated {
          background-color: #ecf0f1;
          color: #2d3436;
        }
        /* ---------- */

        /* ---Center--- */
        #mode {
          background-color: #64727d;
          border-bottom: 3px solid #ffffff;
        }
        /* ---------- */

        /* ---Right--- */
        #language,
        #backlight,
        #clock,
        #pulseaudio,
        #network,
        #battery {
          border-bottom: 2px solid #752c4e;
        }

        label:focus {
          background-color: #000000;
        }

        @keyframes blink {
          to {
            background-color: #b3b3b3;
            color: #31363b;
          }
        }

        #battery.discharging.critical {
          background-color: #f53c3c;
          color: #ffffff;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }

        #battery.discharging.warning {
          background-color: #8d7831;
          color: #ffffff;
        }

        #battery.charging {
          background-color: #26a65b;
        }

        #cpu,
        #memory {
          border-bottom-color: #0c6d1a;
        }

        #cpu.warning {
          background-color: #8d7831;
          color: #ffffff;
        }

        #cpu.critical {
          background-color: #f53c3c;
          color: #ffffff;
        }

        #tray {
          border-bottom: 2px solid #991121;
          margin-right: 2px;
        }

        #custom-poweroff {
          color: white;
          border-bottom: 2px solid red;
          margin-right: 2px;
        }

        /* ---------- */

        #custom-separator {
          color: white;
          margin: 0 3px;
        }

        #window {
          margin-right: 8px;
        }

        #window #waybar.hidden {
          opacity: 0.2;
        }
      '';
      description = "CSS style for Waybar";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      inherit (cfg) package;
      inherit (cfg) settings;
      inherit (cfg) style;
    };

    systemd.user.services.waybar = lib.mkIf (cfg.systemdIntegration && config.module.waybar.enable) {
      description = "Waybar status bar";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/waybar";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
