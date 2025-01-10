{ config, lib, pkgs, ... }:

{
  systemd.user.startServices = "sd-switch";

  programs = {
    gpg.enable = true;

    foot = {
      enable = true;
      settings = {
        main = {
          term = "xterm-256color";

          font = "MesloLGS NF:size=8";
          dpi-aware = "yes";
        };

        mouse = { hide-when-typing = "yes"; };
      };
    };

    zsh = {
      enable = true;
      enableCompletion = true;

      oh-my-zsh = {
        enable = true;
        extraConfig = ''
          # ZSH_TMUX_AUTOSTART=true

          ### Fix slowness of pastes with zsh-syntax-highlighting.zsh
          pasteinit() {
            OLD_SELF_INSERT=''${''${(s.:.)widgets[self-insert]}[2,3]}
            zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
          }

          pastefinish() {
            zle -N self-insert $OLD_SELF_INSERT
          }
          zstyle :bracketed-paste-magic paste-init pasteinit
          zstyle :bracketed-paste-magic paste-finish pastefinish
          ### Fix slowness of pastes
        '';
      };

      history = {
        size = 10000;
        save = 10000;
        share = true;
        extended = true;
      };

      # Enable autosuggestions
      autosuggestion.enable = true;

      # Enable syntax highlighting
      syntaxHighlighting.enable = true;

      initExtraFirst = ''
        # zmodload zsh/zprof
        skip_global_compinit=1
      '';

      completionInit = ''
        autoload -Uz compinit
        for dump in ~/.zcompdump(N.mh+24); do
          compinit
        done
        compinit -C
      '';

      initExtra = ''
        # Fix ctrl + left/right arrow keys
        bindkey "\e[1;5C" forward-word
        bindkey "\e[1;5D" backward-word
        # Bind esc + backspace to delete the word before the cursor
        bindkey '\e^?' backward-kill-word

        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

        # zprof
      '';

      plugins = [{
        name = "zsh-fzf-history-search";
        src = pkgs.fetchFromGitHub {
          owner = "joshskidmore";
          repo = "zsh-fzf-history-search";
          rev = "d5a9730b5b4cb0b39959f7f1044f9c52743832ba";
          sha256 = "1dm1asa4ff5r42nadmj0s6hgyk1ljrckw7val8fz2n0892b8h2mm";
        };
      }];

      shellAliases = {
        gapp = "gcloud auth application-default login";
        gauth = "gcloud auth login";
        ide = "idea-community . > /dev/null 2>&1";
        k = "kubectl";
        sudo = "/run/wrappers/bin/sudo";
      };
    };

    neovim = {
      enable = true;
      vimAlias = true;
      withNodeJs = true;
      defaultEditor = true;
    };

    fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "monospace:size=7";
          dpi-aware = "yes";
        };
      };
    };

    swaylock = {
      enable = true;
      settings = {
        ignore-empty-password = true;
        clock = true;
        timestr = "%H.%M.%S";
        datestr = "%A, %m %Y";
        image = "~/.config/swaylock/lockscreen.jpg";
        inside-color = "#00000000";
        ring-color = "#00000000";
        indicator-thickness = 4;
        line-uses-ring = true;
      };
    };

    waybar = {
      enable = true;
      settings = {
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
            "pulseaudio"
            "backlight"
            "battery"
            "custom/separator"
            "cpu"
            "memory"
            "custom/separator"
            "network#wireguard"
            "network#ovpn"
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
              ~/.config/waybar/modules/scratchpad_indicator
            '';
            format = "{} ";
            on-click-right = "swaymsg 'scratchpad show'";
            on-click = "swaymsg 'move scratchpad'";
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

          "sway/window" = { max-length = 50; };

          "sway/language" = {
            format = "  {short}";
            tooltip = false;
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
              "default" = [ "" "" ];
            };
            scroll-step = 1;
            on-click = "pavucontrol";
          };

          "backlight" = {
            device = "intel_backlight";
            format = "{percent}% {icon}";
            format-icons = [ "" "" ];
          };

          "battery" = {
            states = {
              warning = 25;
              critical = 10;
            };
            format = "{icon} {capacity}%";
            format-charging = " {icon} {capacity}%";
            format-full = " {icon} {capacity}%";
            format-icons = [ "" "" "" "" "" ];
            format-time = "{H}h{M}m";
            interval = 30;
            on-click = "gnome-power-statistics";
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
            on-click = "nm-connection-editor";
          };

          "network#ethernet" = {
            interface = "e*";
            format-ethernet = "";
            format-wifi = "";
            format-linked = "";
            format-disconnected = "";
            tooltip-format = "{ifname}: {ipaddr}/{cidr}";
            on-click = "nm-connection-editor";
          };

          "network#wifi" = {
            interface = "wl*";
            format-ethernet = "";
            format-wifi = "  ({signalStrength}%)";
            format-linked = "";
            format-disconnected = "";
            tooltip-format = "{essid}: {ifname}: {ipaddr}/{cidr}";
            on-click = "nm-connection-editor";
          };

          "network#wireguard" = {
            interface = "compxtreme*";
            format = "🔒";
            format-disconnected = "";
            tooltip-format = "{ifname}: {ipaddr}/{cidr}";
            on-click = "nm-connection-editor";
          };

          "network#ovpn" = {
            interface = "tun*";
            format = "🔒";
            format-disconnected = "";
            tooltip-format = "{ifname}: {ipaddr}/{cidr}";
            on-click = "nm-connection-editor";
          };

          "clock" = {
            interval = 1;
            format = " {:%H:%M %d-%m-%Y}";
            tooltip-format = ''
              <big>{:%Y %B}</big>
              <tt><big>{calendar}</big></tt>'';
            on-click = "/usr/bin/gnome-calendar";
          };

          "tray" = {
            icon-size = 20;
            spacing = 5;
          };

          "custom/poweroff" = {
            tooltip = false;
            format = "";
            on-click =
              "swaynag -t warning -m 'Power Menu Options' -b 'Poweroff' 'systemctl poweroff' -b 'Reboot' 'systemctl reboot' -b 'Suspend' 'systemctl suspend' -b 'Logout' 'swaymsg exit'";
          };

        };
      };

      style = ''
        * {
          border: none;
          border-radius: 4px;
          font-family: "Font Awesome 6 Free";
          font-size: 14px;
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
    };

  };

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;

    config = {
      bars = [ ];
      modes = { };
      keybindings = { };
      # Mod1=<Alt>, Mod4=<Super>
      modifier = "Mod4";
    };

    swaynag = {
      enable = true;
      settings = {
        mtype = {
          background = "#1b1414";
          border = "#285577";
          button-background = "#31363b";
          text = "#ffffff";
          font = "SF Pro Text Regular 10";
          edge = "top";
          message-padding = "8";
          button-padding = "6";
          button-gap = "10";
          button-margin-right = "4";
          button-dismiss-gap = "6";
          details-border-size = "2";
          button-border-size = "0";
          border-bottom-size = "0";
        };
      };
    };

    extraConfig = ''
      ### Variables ###

      # Logo key
      set $mod Mod4

      # Workspace names
      set $ws1 1
      set $ws2 2
      set $ws3 3
      set $ws4 4
      set $ws5 5
      set $ws6 6
      set $ws7 7

      # Locker
      set $locker swaylock -c 000000

      # Terminal emulator
      set $term foot

      # Application launcher
      set $menu fuzzel -w 60 | xargs swaymsg exec --

      # File manager
      set $filer nautilus

      # Browser
      set $browser google-chrome-stable

      # For gtk applications settings
      set $gnomeschema org.gnome.desktop.interface

      ### Settings ###

      # Monitors

      # Set the screen brightness to 20%
      exec --no-startup-id /usr/bin/light -s sysfs/backlight/gmux_backlight -S 20

      # Font
      font pango: SF Pro Text 10

      # Borders
      default_border pixel 2
      # default_floating_border pixel 2
      hide_edge_borders none
      smart_borders on
      smart_gaps on
      gaps inner 2

      # Default wallpaper
      exec --no-startup-id "swaybg -i ~/.local/share/backgrounds/hannah-grace-dSqWwzrLJaQ-unsplash.jpg -m fill"

      # Keyboard layout
      input type:keyboard {
        repeat_delay 300
        repeat_rate 40
        xkb_layout us,se
        xkb_options grp:alt_shift_toggle
        xkb_numlock enabled
      }

      # Touchpad configuration (swaymsg -t get_inputs)
      input "1452:628:bcm5974" {
        dwt enabled
        tap enabled
        natural_scroll disabled
        middle_emulation enabled
      }

      input "1133:49257:Logitech_USB_Laser_Mouse" {
        accel_profile "flat" # disable mouse acceleration (enabled by default; to set it manually, use "adaptive" instead of "flat")
        pointer_accel -0.1 # set mouse sensitivity (between -1 and 1)
      }

      # Drag floating windows by holding down $mod and left mouse button.
      # Resize them with right mouse button + $mod.
      # Despite the name, also works for non-floating windows.
      # Change normal to inverse to use left mouse button for resizing and right
      # mouse button for dragging.
      floating_modifier $mod normal

      ### Window rules ###

      # Link some programs to workspaces (swaymsg -t get_tree)
      # Examples:
      # assign [app_id=$browser] workspace 1
      # assign [app_id=$term] workspace 2
      # assign [app_id="FreeTube"] workspace 3
      # assign [app_id="org.telegram.desktop"] workspace 7

      for_window [window_role="pop-up"] floating enable
      for_window [window_role="bubble"] floating enable
      for_window [window_role="dialog"] floating enable
      for_window [window_type="dialog"] floating enable
      for_window [app_id="lximage-qt"] floating enable

      for_window [app_id="google-chrome"] inhibit_idle fullscreen
      for_window [app_id="org.gnome.Calculator"] floating enable
      for_window [app_id="gnome-power-statistics"] floating enable

      # Disable swayidle while an app is in fullscreen
      for_window [shell=".*"] inhibit_idle fullscreen

      # for_window [class="feh"] floating enable
      # for_window [title="alsamixer"] floating enable border pixel 1
      # for_window [class="calamares"] floating enable border normal
      # for_window [class="Clipgrab"] floating enable
      # for_window [title="File Transfer*"] floating enable
      # for_window [class="fpakman"] floating enable
      # for_window [class="Galculator"] floating enable border pixel 1
      # for_window [class="GParted"] floating enable border normal
      # for_window [title="i3_help"] floating enable sticky enable border normal
      # for_window [class="Lightdm-settings"] floating enable
      # for_window [class="Lxappearance"] floating enable sticky enable border normal
      # for_window [class="Manjaro-hello"] floating enable
      # for_window [class="Manjaro Settings Manager"] floating enable border normal
      # for_window [title="MuseScore: Play Panel"] floating enable
      # for_window [class="Nitrogen"] floating enable sticky enable border normal
      # for_window [class="Oblogout"] fullscreen enable
      # for_window [class="octopi"] floating enable
      # for_window [title="About Pale Moon"] floating enable
      # for_window [class="Pamac-manager"] floating enable
      # for_window [class="Pavucontrol"] floating enable
      # for_window [class="qt5ct"] floating enable sticky enable border normal
      # for_window [class="Qtconfig-qt4"] floating enable sticky enable border normal
      # for_window [class="Simple-scan"] floating enable border normal
      # for_window [class="(?i)System-config-printer.py"] floating enable border normal
      # for_window [class="Skype"] floating enable border normal
      # for_window [class="Timeset-gui"] floating enable border normal
      # for_window [class="(?i)virtualbox"] floating enable border normal
      # for_window [class="Xfburn"] floating enable


      ### Key bindings ###

      # Reload the configuration file
      bindsym --to-code $mod+Shift+r reload

      # Start a terminal
      bindsym --to-code $mod+Return exec $term

      # Kill focused window
      bindsym --to-code $mod+q kill

      # Start your launcher
      bindsym --to-code $mod+d exec $menu

      # Launch wifi choice
      bindsym --to-code $mod+n exec $term -e nmtui-connect

      # Start browser
      bindsym --to-code $mod+w exec $browser

      # Start file manager
      bindsym --to-code $mod+e exec $filer

      # Lock screen
      bindsym --to-code $mod+0 exec $locker
      bindsym --to-code $mod+l exec $locker

      # Start CopyQ
      bindsym --to-code $mod+h exec "copyq show"

      # Color picker
      bindsym --to-code $mod+p exec swaynag -t mtype -m "$(grim -g "$(slurp -p)" -t ppm - | convert - -format '%[pixel:p{0,0}]' txt:-)" && notify-send "Color picked"

      # Take a screenshot to clipboard (whole screen)
      bindsym --to-code Print exec grim - | wl-copy && notify-send "Screenshot of whole screen saved to clipboard"

      # Take a screenshot of selected region to clipboard
      bindsym --to-code $mod+Print exec grim -g "$(slurp)" - | wl-copy && notify-send "Screenshot of selected region saved to clipboard"

      # Take a screenshot of selected region and saved the ocr-ed text to clipboard
      bindsym --to-code $mod+t exec grim -g "$(slurp)" -t png - | tesseract - - | wl-copy && notify-send "Screenshot of selected region and saved the ocr-ed text to clipboard"

      # Take a screenshot of focused window to clipboard
      bindsym --to-code $mod+Shift+Print exec grim -g "$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')" - | wl-copy && notify-send "Screenshot of active window saved to clipboard"

      # Take a screenshot (whole screen)
      bindsym --to-code Ctrl+Print exec grim ~/Pictures/screenshots/screenshot-"$(date +%s)".png && notify-send "Screenshot of whole screen saved to folder"

      # Take a screenshot of selected region
      bindsym --to-code $mod+Ctrl+Print exec grim -g "$(slurp)" ~/Pictures/screenshots/screenshot-"$(date +%s)".png && notify-send "Screenshot of selected region saved to folder"

      # Take a screenshot of focused window
      bindsym --to-code $mod+Ctrl+Shift+Print exec grim -g "$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')" ~/Pictures/screenshot-"$(date +%s)".png && notify-send "Screenshot of active window saved to folder"

      # Move your focus around
      bindsym --to-code $mod+Left focus left
      bindsym --to-code $mod+Down focus down
      bindsym --to-code $mod+Up focus up
      bindsym --to-code $mod+Right focus right

      # Move the focused window with the same, but add Shift
      bindsym --to-code $mod+Shift+Left move left
      bindsym --to-code $mod+Shift+Down move down
      bindsym --to-code $mod+Shift+Up move up
      bindsym --to-code $mod+Shift+Right move right

      # Switch to workspace
      bindsym --to-code $mod+1 workspace $ws1
      bindsym --to-code $mod+2 workspace $ws2
      bindsym --to-code $mod+3 workspace $ws3
      bindsym --to-code $mod+4 workspace $ws4
      bindsym --to-code $mod+5 workspace $ws5
      bindsym --to-code $mod+6 workspace $ws6
      bindsym --to-code $mod+7 workspace $ws7

      # Move focused container to workspace
      bindsym --to-code $mod+Shift+1 move container to workspace $ws1
      bindsym --to-code $mod+Shift+2 move container to workspace $ws2
      bindsym --to-code $mod+Shift+3 move container to workspace $ws3
      bindsym --to-code $mod+Shift+4 move container to workspace $ws4
      bindsym --to-code $mod+Shift+5 move container to workspace $ws5
      bindsym --to-code $mod+Shift+6 move container to workspace $ws6
      bindsym --to-code $mod+Shift+7 move container to workspace $ws7

      # Switch to the next/previous workspace
      bindsym $mod+Ctrl+Right workspace next
      bindsym $mod+Ctrl+Left workspace prev

      # Media keys Volume Settings
      bindsym XF86AudioRaiseVolume exec pamixer -i 5 # to increase 5%
      bindsym XF86AudioLowerVolume exec pamixer -d 5 # to decrease 5%
      bindsym XF86AudioMute exec amixer sset Master toggle
      # Media keys like Brightness|Mute|Play|Stop
      bindsym XF86AudioMicMute exec pactl set-source-mute @DEFAULT_SOURCE@ toggle
      bindsym XF86MonBrightnessUp exec light -s sysfs/backlight/gmux_backlight  -A 5
      bindsym XF86MonBrightnessDown exec light -s sysfs/backlight/gmux_backlight -U 5
      bindsym XF86KbdBrightnessUp exec light -s sysfs/leds/smc::kbd_backlight -A 5
      bindsym XF86KbdBrightnessDown exec light -s sysfs/leds/smc::kbd_backlight -U 5
      # Same playback bindings for Keyboard media keys
      bindsym XF86AudioPlay exec playerctl play-pause
      bindsym XF86AudioNext exec playerctl next
      bindsym XF86AudioPrev exec playerctl previous#

      # Layout stuff:

      # You can "split" the current object of your focus with
      # $mod+c or $mod+v, for horizontal and vertical splits
      # respectively.
      bindsym --to-code --to-code $mod+c splith; exec notify-send "Split horizontaly"
      bindsym --to-code --to-code $mod+v splitv; exec notify-send "Split verticaly"

      # Switch the current container between different layout styles
      bindsym --to-code $mod+F3 layout stacking
      bindsym --to-code $mod+F2 layout tabbed
      bindsym --to-code $mod+F1 layout toggle split

      # Make the current focus fullscreen
      bindsym --to-code $mod+f fullscreen

      # Toggle the current focus between tiling and floating mode
      bindsym --to-code $mod+space floating toggle

      # Swap focus between the tiling area and the floating area
      bindsym --to-code $mod+Shift+space focus mode_toggle

      # Move focus to the parent container
      bindsym --to-code $mod+m focus parent

      # Scratchpad:

      # Sway has a "scratchpad", which is a bag of holding for windows.
      # You can send windows there and get them back later.

      # Move the currently focused window to the scratchpad
      bindsym --to-code $mod+minus move scratchpad

      # Show the next scratchpad window or hide the focused scratchpad window.
      # If there are multiple scratchpad windows, this command cycles through them.
      bindsym --to-code $mod+Shift+minus scratchpad show

      # Resizing containers:

      mode "resize" {
        # left will shrink the containers width
        # right will grow the containers width
        # up will shrink the containers height
        # down will grow the containers height
        bindsym --to-code Left resize shrink width 10px
        bindsym --to-code Down resize grow height 10px
        bindsym --to-code Up resize shrink height 10px
        bindsym --to-code Right resize grow width 10px

        # Return to default mode
        bindsym --to-code Return mode "default"
        bindsym --to-code Escape mode "default"
      }

      bindsym --to-code $mod+r mode "resize"

      # Sticky window
      bindsym --to-code $mod+Shift+s sticky toggle

      # Exit sway (logs you out of your Wayland session)
      bindsym --to-code $mod+Delete exec swaynag -t mtype -m \
        'You pressed the exit shortcut. What do you want?' \
        -b 'Poweroff' 'systemctl poweroff' \
        -b 'Reboot' 'systemctl reboot' \
        -b 'Sleep' 'systemctl suspend' \
        -b 'Logout' 'swaymsg exit'

      # Shutdown/Logout menu
      set $mode_system System (l) lock, (e) exit, (s) suspend, (r) reboot, (Shift+s) Shutdown
      mode "$mode_system" {
        bindsym b exec swaymsg exit
        bindsym l exec $locker, mode "default"
        bindsym e exec swaymsg exit, mode "default"
        bindsym s exec systemctl suspend, mode "default"
        bindsym r exec systemctl reboot, mode "default"
        bindsym Shift+s exec systemctl poweroff -i, mode "default"

        # back to normal: Enter or Escape
        bindsym Return mode "default"
        bindsym Escape mode "default"
      }

      bindsym $mod+Shift+e mode "$mode_system"

      ### Disable laptop's screen when the lid is closed
      # swaymsg -t get_outputs
      bindswitch lid:on output eDP-1 disable
      bindswitch lid:off output eDP-1 enable

      ### Status bar ###

      bar {
        swaybar_command waybar
      }

      include /etc/sway/config.d/*

      ### Autostart ### (to fix time - timedatectl set-ntp true)

      exec killall /usr/bin/earlyoom
      exec sh -c "/usr/bin/earlyoom -r 0 -m 2,1 --prefer '^Web Content$' --avoid '^(sway|waybar|pacman|packagekitd|gnome-shell|gnome-session-c|gnome-session-b|lighdm|sddm|sddm-helper|gdm|gdm-wayland-ses|gdm-session-wor|gdm-x-session|Xorg|Xwayland|systemd|systemd-logind|dbus-daemon|dbus-broker|cinnamon|cinnamon-sessio|kwin_x11|kwin_wayland|plasmashell|ksmserver|plasma_session|startplasma-way|xfce4-session|mate-session|marco|lxqt-session|openbox)'"
      exec sleep 5
      exec --no-startup-id blueman-applet
      exec_always killall pulseaudio
      exec_always sh -c "pulseaudio --daemonize"
      exec --no-startup-id /usr/bin/gammastep-indicator
      exec --no-startup-id /usr/bin/copyq
      exec mako
      exec ~/.config/sway/modules/critical_battery_beeper/critical_battery_beeper.py
      exec swayidle -w \
        timeout 300 'swaylock -f -c 000000' \
        timeout 600 'swaymsg "output * dpms off"' \
        resume 'swaymsg "output * dpms on"' \
        before-sleep 'swaylock  -c 000000'

      # Gtk applications settings
      exec_always {
        gsettings set $gnomeschema gtk-theme 'Yaru-dark'
        gsettings set $gnomeschema icon-theme 'Yaru'
        gsettings set $gnomeschema cursor-theme 'xcursor-breeze'
        gsettings set $gnomeschema font-name 'SF Pro Text Regular 10'
      }

      # Theme colors                                                  #f4692e
      #       class               border      background  text        indicator   child_border
      client.background           n/a         #ffffff     n/a         n/a         n/a
      client.focused              #99644c     #773e28     #ffffff     #99644c     #773e28
      client.focused_inactive     #333333     #5f676a     #ffffff     #484e50     #5f676a
      client.unfocused            #333333     #222222     #888888     #292d2e     #222222
      client.urgent               #2f343a     #900000     #ffffff     #900000     #900000
      client.placeholder          #000000     #0c0c0c     #ffffff     #000000     #0c0c0c

      # Start polkit agent
      exec --no-startup-id /usr/libexec/polkit-gnome-authentication-agent-1

      # Restart kanshi
      exec --no-startup-id "systemctl --user restart kanshi.service"
      bindsym --to-code $mod+k exec systemctl --user restart kanshi.service
    '';
  };

  # GPG agent.
  services.gpg-agent = {
    enable = true;
    # Use GPG for SSH.
    # enableSshSupport = true;

    defaultCacheTtl = 86400;
    maxCacheTtl = 86400;
    pinentryPackage = pkgs.pinentry-tty;
  };

  services.gammastep = {
    enable = true;
    tray = true;

    provider = "manual";
    latitude = 59.3;
    longitude = 18.0;

    temperature.day = 5700;
    temperature.night = 3600;

    settings = {
      general = {
        fade = 1;
        gamma = 0.8;
        adjustment-method = "wayland";
      };
    };
  };

  # Install packages for user.
  # Search for packages here: https://search.nixos.org/packages
  home = {
    packages = with pkgs; [
      # SwayWM
      wl-clipboard # Clipboard support for Wayland
      fuzzel # Fuzzy search for mako
      swaylock # Screen locker
      swaybg # Wallpaper utility
      grim # Screenshot utility
      slurp # Select a region for screenshots
      light # Screen brightness control
      pavucontrol # PulseAudio volume control
      waybar # Status bar for Sway
      networkmanagerapplet # Network manager applet
      mako # Notification daemon
      earlyoom # Early OOM killer
      gammastep # Screen temperature control
      kanshi # Dynamic display configuration

      # File management
      gthumb # Image browser and viewer
      nautilus # File manager
      copyq # Clipboard manager
      wget # Download utility
      axel # Download utility
      unzip # Unzip utility
      tree # Directory tree viewer
      fd # File search utility
      lsof # List open files

      # Media
      mpg123 # Audio player
      mpv # Video player

      # Development tools
      nil # Nix language server
      nixfmt-classic # Nix code formatter
      nix-tree # Visualize Nix dependencies
      gnumake # Build automation tool
      gcc # GNU Compiler Collection
      tree-sitter # Incremental parsing system
      fzf # Fuzzy finder
      go # Go programming language
      gotools # Tools for Go programming
      tig # Text-mode interface for Git
      nix-prefetch-git # Prefetch Git repositories
      pre-commit # Framework for managing pre-commit hooks

      # Cloud and Kubernetes tools
      tenv # OpenTofu, Terraform, Terragrunt and Atmos version manager written in Go

      # Version Control
      git # Git version control system
      tig # Text-mode interface for Git
      git-absorb # Automatically fixup commits
      lazygit # Simple terminal UI for Git commands

      # File and text manipulation
      glow # Markdown renderer for the terminal
      jaq # JSON processor
      xh # Friendly and fast HTTP client
      jq # Command-line JSON processor

      # Language servers and linters
      bash-language-server # Language server for Bash
      black # Python code formatter
      jsonnet-language-server # Language server for Jsonnet
      lua-language-server # Language server for Lua
      nodePackages.jsonlint # JSON linter
      nodePackages.prettier # Code formatter
      shellcheck # Shell script analysis tool
      shfmt # Shell script formatter
      stylua # An opinionated code formatter for Lua
      terraform-ls # Language server for Terraform
      tflint # Linter for Terraform
      yaml-language-server # Language server for YAML
      yamlfmt # YAML formatter

      # Programming languages and runtimes
      python3 # Python programming language
      lua # Lua programming language
      luajitPackages.luarocks # Package manager for Lua modules
      nodejs_22 # JavaScript runtime

      # Diagramming tools
      d2 # Modern diagram scripting language

      # Containers
      podman
    ];

    file = {
      ".config" = {
        source = ./.config;
        recursive = true;
      };

      "Yaru-dark-gdm" = {
        source = ./Yaru-dark-gdm;
        recursive = true;
      };

      ".local" = {
        source = ./.local;
        recursive = true;
      };

      "gtk-3.0" = {
        source = ./gtk-3.0;
        recursive = true;
      };

      ".p10k.zsh" = { source = ./.p10k.zsh; };
    };

    sessionVariables = {
      LIBGL_ALWAYS_INDIRECT = 1;
      LESS = "-iXFR";
      DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
      KPT_FN_RUNTIME = "podman";
    };

    stateVersion = "24.05";
  };
}
