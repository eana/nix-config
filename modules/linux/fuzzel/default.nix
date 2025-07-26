{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.fuzzel;

in
{
  options.module.fuzzel = {
    enable = mkEnableOption "Fuzzel application launcher";

    package = mkOption {
      type = types.package;
      default = pkgs.fuzzel;
      description = "Customized Fuzzel package";
    };

    settings = mkOption {
      type = types.attrs;
      default = {
        main = {
          dpi-aware = "auto";
        };
      };
      description = "Fuzzel configuration settings";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.fuzzel = {
      enable = true;
      inherit (cfg) package settings;
    };
  };
}
