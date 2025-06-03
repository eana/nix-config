{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.swaylock;
  swaylockPkg = import ./package.nix { inherit lib pkgs; };

  lockscreenImage = ../../assets/.config/swaylock/lockscreen.jpg;

  defaultSettings = {
    color = "000000";
    indicator-radius = 55;
    indicator-thickness = 7;
  };

in
{
  options.module.swaylock = {
    enable = mkEnableOption "swaylock screen locker";

    imagePath = mkOption {
      type = types.nullOr types.path;
      default = lockscreenImage;
      description = "Path to the lockscreen image (set to null to disable)";
    };

    package = mkOption {
      type = types.package;
      default = swaylockPkg;
      description = "Customized swaylock package";
    };

    settings = mkOption {
      type = types.attrs;
      default = defaultSettings;
      description = "Configuration settings for swaylock";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        programs.swaylock = {
          enable = true;
          inherit (cfg) package;
          settings =
            cfg.settings
            // (lib.optionalAttrs (cfg.imagePath != null) {
              image = "${cfg.imagePath}";
            });
        };
      }

      (lib.mkIf (cfg.imagePath != null) {
        home.file.".config/swaylock/lockscreen.jpg".source = cfg.imagePath;
      })
    ]
  );
}
