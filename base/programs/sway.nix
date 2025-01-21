{ pkgs }:
let
  background =
    "~/.local/share/backgrounds/hannah-grace-dSqWwzrLJaQ-unsplash.jpg";

  copyq = "${pkgs.copyq}/bin/copyq";
  earlyoom = "${pkgs.earlyoom}/bin/earlyoom";
  foot = "${pkgs.foot}/bin/foot";
  fuzzel = "${pkgs.fuzzel}/bin/fuzzel";
  google-chrome = "${pkgs.google-chrome}/bin/google-chrome";
  grim = "${pkgs.grim}/bin/grim";
  light = "${pkgs.brightnessctl}/bin/brightnessctl";
  mako = "${pkgs.mako}/bin/mako";
  nautilus = "${pkgs.nautilus}/bin/nautilus";
  notify-send = "${pkgs.libnotify}/bin/notify-send --expire-time 15000";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  slurp = "${pkgs.slurp}/bin/slurp";
  swaybg = "${pkgs.swaybg}/bin/swaybg";
  swayidle = "${pkgs.swayidle}/bin/swayidle";
  swaylock = "${pkgs.swaylock}/bin/swaylock --color 000000";
  swaymsg = "${pkgs.sway}/bin/swaymsg";
  swaynag = "${pkgs.sway}/bin/swaynag";
  waybar = "${pkgs.waybar}/bin/waybar";
  wl-paste = "${pkgs.wl-clipboard-rs}/bin/wl-paste";

  modifier = "Mod4"; # Mod1=<Alt>, Mod4=<Super>
  menu = "${fuzzel} --width 60 | xargs ${swaymsg} exec --";
  gnomeschema = "org.gnome.desktop.interface"; # For gtk applications settings
in {
  enable = true;
  wrapperFeatures.gtk = true;
  systemd.enable = true;

  config = {
    inherit modifier;
    bars = [ ];
    modes = { };

    keybindings = {
      "${modifier}+Shift+r" = "reload"; # Reload the configuration file
      "${modifier}+Return" = "exec ${foot}"; # Start a terminal
      "${modifier}+q" = "kill"; # Kill focused window
      "${modifier}+d" = "exec ${menu}"; # Start your launcher
      "${modifier}+n" = "exec ${foot} -e nmtui-connect"; # Launch wifi choice
      "${modifier}+w" = "exec ${google-chrome}"; # Start browser
      "${modifier}+e" = "exec ${nautilus}"; # Start file manager
      "${modifier}+0" = "exec ${swaylock}"; # Lock screen
      "${modifier}+l" = "exec ${swaylock}"; # Lock screen
      "${modifier}+h" = "exec ${copyq} show"; # Start CopyQ

      # Maybe these should be moved back to extraConfig
      # Color picker
      "${modifier}+p" = ''
        exec ${swaynag} -t mtype -m "$(${grim} -g "$(${slurp} -p)" -t ppm - | convert - -format '%[pixel:p{0,0}]' txt:-)" && ${notify-send} "Color picked"'';

      # Take a screenshot to clipboard (whole screen)
      "Print" = ''
        exec ${grim} - | ${wl-paste} && ${notify-send} "Screenshot of whole screen saved to clipboard"'';

      # Take a screenshot of selected region to clipboard
      "${modifier}+Print" = ''
        exec ${grim} -g "$(${slurp})" - | ${wl-paste} && ${notify-send} "Screenshot of selected region saved to clipboard"'';

      # Take a screenshot of selected region and saved the ocr-ed text to clipboard
      "${modifier}+t" = ''
        exec ${grim} -g "$(${slurp})" -t png - | tesseract - - | ${wl-paste} && ${notify-send} "Screenshot of selected region and saved the ocr-ed text to clipboard"'';

      # Take a screenshot of focused window to clipboard
      "${modifier}+Shift+Print" = ''
        exec ${grim} -g "$(${swaymsg} -t get_tree | jq -r '.. | select(.focused?) | .rect | "(.x),(.y) (.width)x(.height)"')" - | ${wl-paste} && ${notify-send} "Screenshot of active window saved to clipboard"'';

      # Take a screenshot (whole screen)
      "Ctrl+Print" = ''
        exec ${grim} ~/Pictures/screenshots/screenshot-"$(date +%s)".png && ${notify-send} "Screenshot of whole screen saved to folder"'';

      # Take a screenshot of selected region
      "${modifier}+Ctrl+Print" = ''
        exec ${grim} -g "$(${slurp})" ~/Pictures/screenshots/screenshot-"$(date +%s)".png && ${notify-send} "Screenshot of selected region saved to folder"'';

      # Take a screenshot of focused window
      "${modifier}+Ctrl+Shift+Print" = ''
        exec ${grim} -g "$(${swaymsg} -t get_tree | jq -r '.. | select(.focused?) | .rect | "(.x),(.y) (.width)x(.height)"')" ~/Pictures/screenshot-"$(date +%s)".png && notify-send -t 30000 "Screenshot of active window saved to folder"'';

      # Move your focus around
      "${modifier}+Left" = "focus left";
      "${modifier}+Down" = "focus down";
      "${modifier}+Up" = "focus up";
      "${modifier}+Right" = "focus right";

      # Move the focused window with the same, but add Shift
      "${modifier}+Shift+Left" = "move left";
      "${modifier}+Shift+Down" = "move down";
      "${modifier}+Shift+Up" = "move up";
      "${modifier}+Shift+Right" = "move right";

      # Switch to workspace
      "${modifier}+1" = "workspace 1";
      "${modifier}+2" = "workspace 2";
      "${modifier}+3" = "workspace 3";
      "${modifier}+4" = "workspace 4";
      "${modifier}+5" = "workspace 5";
      "${modifier}+6" = "workspace 6";
      "${modifier}+7" = "workspace 7";

      # Move focused container to workspace
      "${modifier}+Shift+1" = "move container to workspace 1";
      "${modifier}+Shift+2" = "move container to workspace 2";
      "${modifier}+Shift+3" = "move container to workspace 3";
      "${modifier}+Shift+4" = "move container to workspace 4";
      "${modifier}+Shift+5" = "move container to workspace 5";
      "${modifier}+Shift+6" = "move container to workspace 6";
      "${modifier}+Shift+7" = "move container to workspace 7";

      # Switch to the next/previous workspace
      "${modifier}+Ctrl+Right" = "workspace next";
      "${modifier}+Ctrl+Left" = "workspace prev";

      # Media keys Volume Settings
      "XF86AudioRaiseVolume" = "exec volumectl -u up";
      "XF86AudioLowerVolume" = "exec volumectl -u down";

      # Media keys like Brightness|Mute|Play|Stop
      "XF86AudioMute" = "exec volumectl toggle-mute";
      "XF86AudioMicMute" = "exec volumectl -m toggle-mute";

      "XF86MonBrightnessUp" = "exec lightctl up";
      "XF86MonBrightnessDown" = "exec lightctl down";

      "XF86KbdBrightnessUp" =
        "exec ${light} --device dell::kbd_backlight set +5%";
      "XF86KbdBrightnessDown" =
        "exec ${light} --device dell::kbd_backlight set 5%-";

      # Same playback bindings for Keyboard media keys
      "XF86AudioPlay" = "exec ${playerctl} play-pause";
      "XF86AudioNext" = "exec ${playerctl} next";
      "XF86AudioPrev" = "exec ${playerctl} previous";

      # Layout stuff:
      "${modifier}+c" = "splith; exec ${notify-send} 'Split horizontaly'";
      "${modifier}+v" = "splitv; exec ${notify-send} 'Split verticaly'";

      # Switch the current container between different layout styles
      "${modifier}+F3" = "layout stacking";
      "${modifier}+F2" = "layout tabbed";
      "${modifier}+F1" = "layout toggle split";

      # Make the current focus fullscreen
      "${modifier}+f" = "fullscreen";

      # Toggle the current focus between tiling and floating mode
      "${modifier}+space" = "floating toggle";

      # Swap focus between the tiling area and the floating area
      "${modifier}+Shift+space" = "focus mode_toggle";

      # Move focus to the parent container
      "${modifier}+m" = "focus parent";

      # Sway has a "scratchpad", which is a bag of holding for windows.
      # You can send windows there and get them back later.

      # Move the currently focused window to the scratchpad
      "${modifier}+minus" = "move scratchpad";

      # Show the next scratchpad window or hide the focused scratchpad window.
      # If there are multiple scratchpad windows, this command cycles through them.
      "${modifier}+Shift+minus" = "scratchpad show";

      ### Disable/Enable the laptop's screen when needed
      ## The following configuration works
      "${modifier}+Ctrl+d" = "exec ${swaymsg} output eDP-1 disable";
      "${modifier}+Ctrl+e" = "exec ${swaymsg} output eDP-1 enable";

    };

    startup = [
      {
        command = "systemctl --user restart avizo";
        always = true;
      }
      {
        command = "${light} --device intel_backlight set 20%";
        always = true;
      }
      {
        command = "${swaybg} --image ${background} --mode fill";
        always = true;
      }
    ];

    # swaymsg -t get_inputs
    input = {
      # Keyboard layout
      "type:keyboard" = {
        repeat_delay = "300";
        repeat_rate = "40";
        xkb_layout = "us,se";
        xkb_options = "grp:alt_shift_toggle";
        xkb_numlock = "enabled";
      };

      # Touchpad configuration
      "1739:31251:DLL06E5:01_06CB:7A13_Touchpad" = {
        dwt = "enabled";
        tap = "enabled";
        natural_scroll = "disabled";
        middle_emulation = "enabled";
      };

      "1133:49257:Logitech_USB_Laser_Mouse" = {
        # disable mouse acceleration (enabled by default; to set it manually, use "adaptive" instead of "flat")
        accel_profile = "flat";
        # set mouse sensitivity (between -1 and 1)
        pointer_accel = "-0.1";
      };
    };
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
    ### Settings ###
    set $mod Mod4

    # Font
    font pango: SF Pro Text 10

    # Borders
    default_border pixel 2
    # default_floating_border pixel 2
    hide_edge_borders none
    smart_borders on
    smart_gaps on
    gaps inner 2

    # Drag floating windows by holding down $mod and left mouse button.
    # Resize them with right mouse button + $mod.
    # Despite the name, also works for non-floating windows.
    # Change normal to inverse to use left mouse button for resizing and right
    # mouse button for dragging.
    floating_modifier $mod normal

    ### Window rules ###

    # Link some programs to workspaces (${swaymsg} -t get_tree)
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
    bindsym --to-code $mod+Delete exec ${swaynag} --type mtype --message \
      'You pressed the exit shortcut. What do you want?' \
      --button 'Poweroff' 'systemctl poweroff' \
      --button 'Reboot' 'systemctl reboot' \
      --button 'Sleep' 'systemctl suspend' \
      --button 'Logout' '${swaymsg} exit'

    # Shutdown/Logout menu
    set $mode_system System (l) lock, (e) exit, (s) suspend, (r) reboot, (Shift+s) Shutdown
    mode "$mode_system" {
      bindsym b exec ${swaymsg} exit
      bindsym l exec $locker, mode "default"
      bindsym e exec ${swaymsg} exit, mode "default"
      bindsym s exec systemctl suspend, mode "default"
      bindsym r exec systemctl reboot, mode "default"
      bindsym Shift+s exec systemctl poweroff -i, mode "default"

      # back to normal: Enter or Escape
      bindsym Return mode "default"
      bindsym Escape mode "default"
    }

    bindsym $mod+Shift+e mode "$mode_system"

    ### Disable laptop's screen when the lid is closed
    # ${swaymsg} -t get_outputs
    bindswitch lid:on output eDP-1 disable
    bindswitch lid:off output eDP-1 enable

    ### Status bar ###

    bar {
      swaybar_command ${waybar}
    }

    include /etc/sway/config.d/*

    ### Autostart ### (to fix time - timedatectl set-ntp true)

    exec killall ${earlyoom}
    exec sh -c "${earlyoom} -r 0 -m 2,1 --prefer '^Web Content$' --avoid '^(sway|waybar|pacman|packagekitd|gnome-shell|gnome-session-c|gnome-session-b|lighdm|sddm|sddm-helper|gdm|gdm-wayland-ses|gdm-session-wor|gdm-x-session|Xorg|Xwayland|systemd|systemd-logind|dbus-daemon|dbus-broker|cinnamon|cinnamon-sessio|kwin_x11|kwin_wayland|plasmashell|ksmserver|plasma_session|startplasma-way|xfce4-session|mate-session|marco|lxqt-session|openbox)'"
    exec sleep 5
    exec ${mako}
    exec ${swayidle} -w \
      timeout 300 '${swaylock} --daemonize' \
      timeout 900 '${swaymsg} "output * dpms off"' \
      resume '${swaymsg} "output * dpms on"' \
      before-sleep '${swaylock}'

    # Gtk applications settings
    exec_always {
      gsettings set ${gnomeschema} gtk-theme 'Yaru-dark'
      gsettings set ${gnomeschema} icon-theme 'Yaru'
      gsettings set ${gnomeschema} cursor-theme 'xcursor-breeze'
      gsettings set ${gnomeschema} font-name 'SF Pro Text Regular 10'
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
  '';
}
