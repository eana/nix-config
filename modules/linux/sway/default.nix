{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.sway;
  swayPkg = import ./package.nix { inherit lib pkgs; };

  backgroundsDir = ../../../assets/.local/share/backgrounds;
  mimeAppsFile = ../../../assets/.config/mimeapps.list;

  defaultBackground = "~/.local/share/backgrounds/hannah-grace-dSqWwzrLJaQ-unsplash.jpg";
  defaultModifier = "Mod4";

  # Helper function to generate swaylock config
  mkSwaylockConfig =
    settings:
    pkgs.writeText "swaylock-config" (
      lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: value: if value != null then "${name}=${toString value}" else "") settings
      )
    );

  defaultSwaylockConfig = {
    color = "000000";
    indicator-radius = 55;
    indicator-thickness = 7;
    image = null;
  };

  swaylockConfigFile = mkSwaylockConfig cfg.swaylock.settings;

  # Base keybindings
  baseKeybindings = {
    "${defaultModifier}+Shift+r" = "reload";
    "${defaultModifier}+Return" = "exec ${pkgs.foot}/bin/foot";
    "${defaultModifier}+q" = "kill";
    "${defaultModifier}+d" =
      "exec ${pkgs.fuzzel}/bin/fuzzel --width 60 | xargs ${pkgs.sway}/bin/swaymsg exec --";
    "${defaultModifier}+n" = "exec ${pkgs.foot}/bin/foot -e nmtui-connect";
    "${defaultModifier}+w" = "exec ${pkgs.google-chrome}/bin/google-chrome";
    "${defaultModifier}+e" = "exec ${pkgs.nautilus}/bin/nautilus";
    "${defaultModifier}+h" = "exec ${pkgs.copyq}/bin/copyq show";
    "${defaultModifier}+p" =
      "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp -p)\" -t ppm - | ${pkgs.imagemagick}/bin/magick convert - -format '%[pixel:p{0,0}]' txt:- | ${pkgs.wl-clipboard-rs}/bin/wl-copy && ${pkgs.libnotify}/bin/notify-send --expire-time 15000 \"Color picked and saved to clipboard\"";
    "Print" =
      "exec ${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard-rs}/bin/wl-copy && ${pkgs.libnotify}/bin/notify-send --expire-time 15000 \"Screenshot of whole screen saved to clipboard\"";
    "${defaultModifier}+Print" =
      "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard-rs}/bin/wl-copy && ${pkgs.libnotify}/bin/notify-send --expire-time 15000 \"Screenshot of selected region saved to clipboard\"";
    "${defaultModifier}+t" =
      "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" -t png - | ${pkgs.tesseract}/bin/tesseract - - | ${pkgs.wl-clipboard-rs}/bin/wl-copy && ${pkgs.libnotify}/bin/notify-send --expire-time 15000 \"Screenshot of selected region and saved the ocr-ed text to clipboard\"";
    "${defaultModifier}+Shift+Print" =
      "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.sway}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq -r '.. | select(.focused?) | .rect | \"(.x),(.y) (.width)x(.height)\"')\" - | ${pkgs.wl-clipboard-rs}/bin/wl-copy && ${pkgs.libnotify}/bin/notify-send --expire-time 15000 \"Screenshot of active window saved to clipboard\"";
    "Ctrl+Print" =
      "exec ${pkgs.grim}/bin/grim ~/Pictures/screenshots/screenshot-\"$(date +%s)\".png && ${pkgs.libnotify}/bin/notify-send --expire-time 15000 \"Screenshot of whole screen saved to folder\"";
    "${defaultModifier}+Ctrl+Print" =
      "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" ~/Pictures/screenshots/screenshot-\"$(date +%s)\".png && ${pkgs.libnotify}/bin/notify-send --expire-time 15000 \"Screenshot of selected region saved to folder\"";
    "${defaultModifier}+Ctrl+Shift+Print" =
      "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.sway}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq -r '.. | select(.focused?) | .rect | \"(.x),(.y) (.width)x(.height)\"')\" ~/Pictures/screenshot-\"$(date +%s)\".png && ${pkgs.libnotify}/bin/notify-send -t 30000 \"Screenshot of active window saved to folder\"";
    "${defaultModifier}+Left" = "focus left";
    "${defaultModifier}+Down" = "focus down";
    "${defaultModifier}+Up" = "focus up";
    "${defaultModifier}+Right" = "focus right";
    "${defaultModifier}+Shift+Left" = "move left";
    "${defaultModifier}+Shift+Down" = "move down";
    "${defaultModifier}+Shift+Up" = "move up";
    "${defaultModifier}+Shift+Right" = "move right";
    "${defaultModifier}+1" = "workspace 1";
    "${defaultModifier}+2" = "workspace 2";
    "${defaultModifier}+3" = "workspace 3";
    "${defaultModifier}+4" = "workspace 4";
    "${defaultModifier}+5" = "workspace 5";
    "${defaultModifier}+6" = "workspace 6";
    "${defaultModifier}+7" = "workspace 7";
    "${defaultModifier}+Shift+1" = "move container to workspace 1";
    "${defaultModifier}+Shift+2" = "move container to workspace 2";
    "${defaultModifier}+Shift+3" = "move container to workspace 3";
    "${defaultModifier}+Shift+4" = "move container to workspace 4";
    "${defaultModifier}+Shift+5" = "move container to workspace 5";
    "${defaultModifier}+Shift+6" = "move container to workspace 6";
    "${defaultModifier}+Shift+7" = "move container to workspace 7";
    "${defaultModifier}+Ctrl+Right" = "workspace next";
    "${defaultModifier}+Ctrl+Left" = "workspace prev";
    "XF86AudioRaiseVolume" = "exec volumectl -u up";
    "XF86AudioLowerVolume" = "exec volumectl -u down";
    "XF86AudioMute" = "exec volumectl toggle-mute";
    "XF86AudioMicMute" = "exec volumectl -m toggle-mute";
    "XF86MonBrightnessUp" = "exec lightctl up";
    "XF86MonBrightnessDown" = "exec lightctl down";
    "XF86KbdBrightnessUp" =
      "exec ${pkgs.brightnessctl}/bin/brightnessctl --device dell::kbd_backlight set +5%";
    "XF86KbdBrightnessDown" =
      "exec ${pkgs.brightnessctl}/bin/brightnessctl --device dell::kbd_backlight set 5%-";
    "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
    "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
    "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
    "${defaultModifier}+c" = "splith; exec ${pkgs.libnotify}/bin/notify-send 'Split horizontaly'";
    "${defaultModifier}+v" = "splitv; exec ${pkgs.libnotify}/bin/notify-send 'Split verticaly'";
    "${defaultModifier}+F3" = "layout stacking";
    "${defaultModifier}+F2" = "layout tabbed";
    "${defaultModifier}+F1" = "layout toggle split";
    "${defaultModifier}+f" = "fullscreen";
    "${defaultModifier}+space" = "floating toggle";
    "${defaultModifier}+Shift+space" = "focus mode_toggle";
    "${defaultModifier}+m" = "focus parent";
    "${defaultModifier}+minus" = "move scratchpad";
    "${defaultModifier}+Shift+minus" = "scratchpad show";
    "${defaultModifier}+Ctrl+d" = "exec ${pkgs.sway}/bin/swaymsg output eDP-1 disable";
    "${defaultModifier}+Ctrl+e" = "exec ${pkgs.sway}/bin/swaymsg output eDP-1 enable";
  };

  # Final keybindings with swaylock commands
  keybindings = baseKeybindings // {
    "${defaultModifier}+0" = "exec ${pkgs.swaylock}/bin/swaylock";
    "${defaultModifier}+l" = "exec ${pkgs.swaylock}/bin/swaylock";
  };

  defaultStartupCommands = [
    {
      command = "systemctl --user restart avizo";
      always = true;
    }
    {
      command = "${pkgs.brightnessctl}/bin/brightnessctl --device intel_backlight set 20%";
      always = true;
    }
    {
      command = "${pkgs.swaybg}/bin/swaybg --image ${cfg.background} --mode fill";
      always = true;
    }
  ];

  defaultExtraConfig = ''
    # Borders
    default_border pixel 2
    hide_edge_borders none
    smart_borders on
    smart_gaps on
    gaps inner 2

    floating_modifier ${defaultModifier} normal

    ### Window rules ###
    for_window [window_role="pop-up"] floating enable
    for_window [window_role="bubble"] floating enable
    for_window [window_role="dialog"] floating enable
    for_window [window_type="dialog"] floating enable
    for_window [app_id="lximage-qt"] floating enable
    for_window [app_id="google-chrome"] inhibit_idle fullscreen
    for_window [app_id="org.gnome.Calculator"] floating enable
    for_window [app_id="gnome-power-statistics"] floating enable
    for_window [shell=".*"] inhibit_idle fullscreen
    for_window [class="Fuse"] floating enable
    for_window [class="Rofi"] floating enable

    ### Input configuration ###
    input "type:keyboard" {
      repeat_delay 300
      repeat_rate 40
      xkb_layout "us,se"
      xkb_options "grp:alt_shift_toggle"
      xkb_numlock enabled
    }

    input "1739:31251:DLL06E5:01_06CB:7A13_Touchpad" {
      dwt enabled
      tap enabled
      natural_scroll disabled
      middle_emulation enabled
    }

    input "1133:49257:Logitech_USB_Laser_Mouse" {
      accel_profile flat
      pointer_accel -0.1
    }

    ### Key bindings ###
    mode "resize" {
      bindsym --to-code Left resize shrink width 10px
      bindsym --to-code Down resize grow height 10px
      bindsym --to-code Up resize shrink height 10px
      bindsym --to-code Right resize grow width 10px
      bindsym --to-code Return mode "default"
      bindsym --to-code Escape mode "default"
    }

    bindsym --to-code ${defaultModifier}+r mode "resize"
    bindsym --to-code ${defaultModifier}+Shift+s sticky toggle

    bindsym --to-code ${defaultModifier}+Delete exec ${pkgs.sway}/bin/swaynag \
      --background #1b1414 \
      --border #285577 \
      --button-background #31363b \
      --text #ffffff \
      --font "Helvetica Neue LT Std 11" \
      --message 'You pressed the exit shortcut. What do you want?' \
      --button 'Poweroff' 'systemctl poweroff' \
      --button 'Reboot' 'systemctl reboot' \
      --button 'Sleep' 'systemctl suspend' \
      --button 'Logout' '${pkgs.sway}/bin/swaymsg exit'

    set $mode_system System (l) lock, (e) exit, (s) suspend, (r) reboot, (Shift+s) Shutdown
    mode "$mode_system" {
      bindsym b exec ${pkgs.sway}/bin/swaymsg exit
      bindsym l exec $locker, mode "default"
      bindsym e exec ${pkgs.sway}/bin/swaymsg exit, mode "default"
      bindsym s exec systemctl suspend, mode "default"
      bindsym r exec systemctl reboot, mode "default"
      bindsym Shift+s exec systemctl poweroff -i, mode "default"
      bindsym Return mode "default"
      bindsym Escape mode "default"
    }

    bindsym ${defaultModifier}+Shift+e mode "$mode_system"

    ### Disable laptop's screen when the lid is closed
    bindswitch lid:on output eDP-1 disable
    bindswitch lid:off output eDP-1 enable

    include /etc/sway/config.d/*

    ### Autostart ###
    exec killall ${pkgs.earlyoom}/bin/earlyoom
    exec sh -c "${pkgs.earlyoom}/bin/earlyoom -r 0 -m 2,1 --prefer '^Web Content$' --avoid '^(sway|waybar|pacman|packagekitd|gnome-shell|gnome-session-c|gnome-session-b|lighdm|sddm|sddm-helper|gdm|gdm-wayland-ses|gdm-session-wor|gdm-x-session|Xorg|Xwayland|systemd|systemd-logind|dbus-daemon|dbus-broker|cinnamon|cinnamon-sessio|kwin_x11|kwin_wayland|plasmashell|ksmserver|plasma_session|startplasma-way|xfce4-session|mate-session|marco|lxqt-session|openbox)'"
    exec sleep 5
    exec ${pkgs.mako}/bin/mako
    exec ${pkgs.swayidle}/bin/swayidle -w \
      timeout 300 '${pkgs.swaylock}/bin/swaylock' \
      timeout 900 '${pkgs.sway}/bin/swaymsg "output * dpms off"' \
      resume '${pkgs.sway}/bin/swaymsg "output * dpms on"' \
      before-sleep '${pkgs.swaylock}/bin/swaylock'

    # Gtk applications settings
    client.background           n/a         #ffffff     n/a         n/a         n/a
    client.focused              #99644c     #773e28     #ffffff     #99644c     #773e28
    client.focused_inactive     #333333     #5f676a     #ffffff     #484e50     #5f676a
    client.unfocused            #333333     #222222     #888888     #292d2e     #222222
    client.urgent               #2f343a     #900000     #ffffff     #900000     #900000
    client.placeholder          #000000     #0c0c0c     #ffffff     #000000     #0c0c0c

    # Start polkit agent
    exec --no-startup-id /usr/libexec/polkit-gnome-authentication-agent-1
  '';

in
{
  options.module.sway = {
    enable = mkEnableOption "Sway window manager";

    package = mkOption {
      type = types.package;
      default = swayPkg;
      description = "Customized Sway package";
    };

    background = mkOption {
      type = types.str;
      default = defaultBackground;
      description = "Path to background image";
    };

    modifier = mkOption {
      type = types.str;
      default = defaultModifier;
      description = "Modifier key for keybindings";
    };

    keybindings = mkOption {
      type = types.attrsOf types.str;
      default = keybindings;
      description = "Sway keybindings configuration";
    };

    startup = mkOption {
      type = types.listOf types.attrs;
      default = defaultStartupCommands;
      description = "Startup commands for Sway";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = defaultExtraConfig;
      description = "Additional Sway configuration";
    };

    swaylock = {
      enable = mkEnableOption "Swaylock screen locker";

      settings = mkOption {
        type = types.submodule {
          options = {
            color = mkOption {
              type = types.str;
              default = defaultSwaylockConfig.color;
              description = "Background color for swaylock";
            };

            indicator-radius = mkOption {
              type = types.int;
              default = defaultSwaylockConfig.indicator-radius;
              description = "Radius of the indicator circle";
            };

            indicator-thickness = mkOption {
              type = types.int;
              default = defaultSwaylockConfig.indicator-thickness;
              description = "Thickness of the indicator circle";
            };

            image = mkOption {
              type = types.nullOr types.str;
              default = defaultSwaylockConfig.image;
              description = "Path to background image for swaylock";
            };
          };
        };
        default = defaultSwaylockConfig;
        description = "Swaylock configuration options";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."mimeapps.list".source = mimeAppsFile;
    home = {
      file.".local/share/backgrounds".source = backgroundsDir;
      file.".config/swaylock/config".source = swaylockConfigFile;

      packages = with pkgs; [
        swaylock
        swayidle
        swaybg
        foot
        fuzzel
        grim
        slurp
        wl-clipboard-rs
        imagemagick
        tesseract
        jq
        libnotify
        brightnessctl
        playerctl
        earlyoom
        mako
        copyq
        google-chrome
        nautilus
      ];
    };

    wayland.windowManager.sway = {
      enable = true;
      systemd.enable = true;
      wrapperFeatures.gtk = true;

      config = {
        inherit (cfg) modifier;
        inherit (cfg) keybindings;
        inherit (cfg) startup;
        bars = [ ];
        modes = { };
        fonts = {
          names = [ "Helvetica Neue LT Std" ];
          size = 12.0;
        };
      };

      inherit (cfg) extraConfig;
    };
  };
}
