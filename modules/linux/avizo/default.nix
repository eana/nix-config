{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.avizo;

  defaultSettings = {
    default = {
      time = 1.0;
      y-offset = 0.5;
      fade-in = 0.1;
      fade-out = 0.2;
      padding = 10;
    };
  };

in
{
  options.module.avizo = {
    enable = mkEnableOption "Avizo notification daemon";

    package = mkOption {
      type = types.package;
      default = pkgs.avizo;
      description = "Neat notification daemon for Wayland";
    };

    settings = mkOption {
      type = types.attrs;
      default = defaultSettings;
      description = "Avizo configuration settings";
    };
  };

  config = lib.mkIf cfg.enable {
    services.avizo = {
      enable = true;
      inherit (cfg) settings;
    };

    home.packages = [ cfg.package ];
  };
}
