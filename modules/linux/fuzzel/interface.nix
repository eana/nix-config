{ lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption types;
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
}
