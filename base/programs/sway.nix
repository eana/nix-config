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
in {
  enable = true;
  wrapperFeatures.gtk = true;
  systemd.enable = true;

  config = {
    bars = [ ];
    modes = { };
    keybindings = { };
    # Mod1=<Alt>, Mod4=<Super>
    modifier = "Mod4";

    startup = [{
      command = "systemctl --user restart avizo";
      always = true;
    }];
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
    set $locker ${swaylock}

    # Terminal emulator
    set $term ${foot}

    # Application launcher
    set $menu ${fuzzel} --width 60 | xargs ${swaymsg} exec --

    # File manager
    set $filer ${nautilus}

    # Browser
    set $browser ${google-chrome}

    # For gtk applications settings
    set $gnomeschema org.gnome.desktop.interface

    ### Settings ###

    # Monitors

    # Set the screen brightness to 20%
    exec --no-startup-id ${light} --device intel_backlight set 20%

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
    exec --no-startup-id "${swaybg} --image ${background} --mode fill"

    # Keyboard layout
    input type:keyboard {
      repeat_delay 300
      repeat_rate 40
      xkb_layout us,se
      xkb_options grp:alt_shift_toggle
      xkb_numlock enabled
    }

    # Touchpad configuration (swaymsg -t get_inputs)
    input "1739:31251:DLL06E5:01_06CB:7A13_Touchpad" {
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
    bindsym --to-code $mod+h exec "${copyq} show"

    # Color picker
    bindsym --to-code $mod+p exec ${swaynag} -t mtype -m "$(${grim} -g "$(${slurp} -p)" -t ppm - | convert - -format '%[pixel:p{0,0}]' txt:-)" && ${notify-send} "Color picked"

    # Take a screenshot to clipboard (whole screen)
    bindsym --to-code Print exec ${grim} - | ${wl-paste} && ${notify-send} "Screenshot of whole screen saved to clipboard"

    # Take a screenshot of selected region to clipboard
    bindsym --to-code $mod+Print exec ${grim} -g "$(${slurp})" - | ${wl-paste} && ${notify-send} "Screenshot of selected region saved to clipboard"

    # Take a screenshot of selected region and saved the ocr-ed text to clipboard
    bindsym --to-code $mod+t exec ${grim} -g "$(${slurp})" -t png - | tesseract - - | ${wl-paste} && ${notify-send} "Screenshot of selected region and saved the ocr-ed text to clipboard"

    # Take a screenshot of focused window to clipboard
    bindsym --to-code $mod+Shift+Print exec ${grim} -g "$(${swaymsg} -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')" - | ${wl-paste} && ${notify-send} "Screenshot of active window saved to clipboard"

    # Take a screenshot (whole screen)
    bindsym --to-code Ctrl+Print exec ${grim} ~/Pictures/screenshots/screenshot-"$(date +%s)".png && ${notify-send} "Screenshot of whole screen saved to folder"

    # Take a screenshot of selected region
    bindsym --to-code $mod+Ctrl+Print exec ${grim} -g "$(${slurp})" ~/Pictures/screenshots/screenshot-"$(date +%s)".png && ${notify-send} "Screenshot of selected region saved to folder"

    # Take a screenshot of focused window
    bindsym --to-code $mod+Ctrl+Shift+Print exec ${grim} -g "$(${swaymsg} -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')" ~/Pictures/screenshot-"$(date +%s)".png && notify-send -t 30000 "Screenshot of active window saved to folder"

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
    bindsym XF86AudioRaiseVolume exec volumectl -u up
    bindsym XF86AudioLowerVolume exec volumectl -u down

    # Media keys like Brightness|Mute|Play|Stop
    bindsym XF86AudioMute exec volumectl toggle-mute
    bindsym XF86AudioMicMute exec volumectl -m toggle-mute

    bindsym XF86MonBrightnessUp exec lightctl up
    bindsym XF86MonBrightnessDown exec lightctl down

    bindsym XF86KbdBrightnessUp exec ${light} --device dell::kbd_backlight set +5%
    bindsym XF86KbdBrightnessDown exec ${light} --device dell::kbd_backlight set 5%-

    # Same playback bindings for Keyboard media keys
    bindsym XF86AudioPlay exec ${playerctl} play-pause
    bindsym XF86AudioNext exec ${playerctl} next
    bindsym XF86AudioPrev exec ${playerctl} previous

    # Layout stuff:

    # You can "split" the current object of your focus with
    # $mod+c or $mod+v, for horizontal and vertical splits
    # respectively.
    bindsym --to-code --to-code $mod+c splith; exec ${notify-send} "Split horizontaly"
    bindsym --to-code --to-code $mod+v splitv; exec ${notify-send} "Split verticaly"

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

    ### Disable/Enable the laptop's screen when needed
    ## The following configuration works
    bindsym $mod+Ctrl+d exec ${swaymsg} output eDP-1 disable
    bindsym $mod+Ctrl+e exec ${swaymsg} output eDP-1 enable

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
  '';
}
