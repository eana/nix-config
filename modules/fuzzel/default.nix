{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.fuzzel;
  fuzzelPkg = import ./package.nix { inherit lib pkgs; };

in
{
  options.module.fuzzel = {
    enable = mkEnableOption "Fuzzel application launcher";

    package = mkOption {
      type = types.package;
      default = fuzzelPkg;
      description = "Customized Fuzzel package";
    };

    settings = mkOption {
      type = types.attrs;
      default = {
        main = {
          font = "Helvetica Neue LT Std:size=9";
          dpi-aware = "yes";
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
