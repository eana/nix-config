{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.module.sway;

  backgroundsDir = ../../../assets/.local/share/backgrounds;
  mimeAppsFile = ../../../assets/.config/mimeapps.list;

  # Helper function to generate swaylock config
  mkSwaylockConfig =
    settings:
    pkgs.writeText "swaylock-config" (
      lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: value: if value != null then "${name}=${toString value}" else "") settings
      )
    );

  swaylockConfigFile = mkSwaylockConfig cfg.swaylock.settings;

in
{
  imports = [ ./interface.nix ];

  config = lib.mkIf cfg.enable {
    xdg.configFile."mimeapps.list".source = mimeAppsFile;
    home = {
      file.".local/share/backgrounds".source = backgroundsDir;
      file.".config/swaylock/config".source = swaylockConfigFile;

      packages = with pkgs; [
        swaylock
        swayidle
        swaybg
        grim
        slurp
        wl-clipboard
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
        rofi
        rofi-rbw-wayland
      ];
    };

    wayland.windowManager.sway = {
      enable = true;
      systemd.enable = true;
      wrapperFeatures.gtk = true;
      # Fontconfig cannot write cache to /homeless-shelter in the Nix sandbox,
      # causing spurious errors during `sway --validate`. The config itself is
      # valid; suppress the check to eliminate the noise.
      checkConfig = false;

      config = {
        inherit (cfg) modifier;
        inherit (cfg) keybindings;
        inherit (cfg) startup;
        bars = [ ];
        modes = { };
        fonts = {
          names = [ "Helvetica Neue LT Std" ];
        };
      };

      inherit (cfg) extraConfig;
    };
  };
}
