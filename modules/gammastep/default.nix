{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.gammastep;
  gammastepPkg = import ./package.nix { inherit lib pkgs; };

  defaultSettings = {
    general = {
      fade = 1;
      gamma = 0.8;
    };
  };

in
{
  options.module.gammastep = {
    enable = mkEnableOption "Gammastep screen temperature adjustment";

    package = mkOption {
      type = types.package;
      default = gammastepPkg;
      description = "Customized Gammastep package";
    };

    tray = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable the system tray icon";
    };

    provider = mkOption {
      type = types.str;
      default = "manual";
      description = "Location provider (manual, geoclue2, etc.)";
    };

    latitude = mkOption {
      type = types.float;
      default = 59.3;
      description = "Manual latitude coordinate";
    };

    longitude = mkOption {
      type = types.float;
      default = 18.0;
      description = "Manual longitude coordinate";
    };

    temperature = {
      day = mkOption {
        type = types.int;
        default = 5700;
        description = "Daytime color temperature in Kelvin";
      };
      night = mkOption {
        type = types.int;
        default = 3600;
        description = "Nighttime color temperature in Kelvin";
      };
    };

    settings = mkOption {
      type = types.attrs;
      default = defaultSettings;
      description = "Additional Gammastep configuration settings";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gammastep = {
      enable = true;
      inherit (cfg)
        tray
        provider
        latitude
        longitude
        temperature
        settings
        ;
    };

    home.packages = [ cfg.package ];
  };
}
