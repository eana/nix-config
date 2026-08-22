{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    concatLists
    filterAttrs
    mapAttrsToList
    mkIf
    ;

  cfg = config.module.openra;

  variants = {
    red-alert = {
      name = "Red Alert";
      appimageSuffix = "Red-Alert";
      modDir = "ra";
    };
    dune = {
      name = "Dune 2000";
      appimageSuffix = "Dune-2000";
      modDir = "d2k";
    };
    tiberian-dawn = {
      name = "Tiberian Dawn";
      appimageSuffix = "Tiberian-Dawn";
      modDir = "cnc";
    };
  };

  enabledVariants = filterAttrs (name: _: cfg.variants.${name}.enable or false) variants;

  mkDesktopPackage =
    variant: variantCfg: pkg:
    let
      desktop = pkgs.callPackage ./desktop.nix {
        inherit
          pkgs
          variant
          variantCfg
          cfg
          ;
        package = pkg;
      };
    in
    pkgs.runCommand "openra-${variant}-desktop"
      {
        nativeBuildInputs = [ pkgs.copyDesktopItems ];
        desktopItems = [ desktop.desktopItem ];
      }
      ''
        mkdir -p $out/share/icons/hicolor/64x64/apps
        cp ${desktop.icon} $out/share/icons/hicolor/64x64/apps/openra-${variant}.png
        copyDesktopItems
      '';

  mkVariant =
    variant: variantCfg:
    let
      pkg = pkgs.callPackage ./package.nix {
        inherit
          lib
          pkgs
          variant
          variantCfg
          cfg
          ;
      };
    in
    [
      pkg
      (mkDesktopPackage variant variantCfg pkg)
    ];

in
{
  imports = [ ./interface.nix ];

  config = mkIf cfg.enable {
    home.packages = concatLists (mapAttrsToList mkVariant enabledVariants);
  };
}
