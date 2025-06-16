{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

let
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
    variant: variantCfg:
    let
      desktop = pkgs.callPackage ./desktop.nix {
        inherit
          lib
          pkgs
          variant
          variantCfg
          cfg
          ;
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

  mkVariant = variant: variantCfg: [
    (pkgs.callPackage ./package.nix {
      inherit
        lib
        pkgs
        variant
        variantCfg
        cfg
        ;
    })
    (mkDesktopPackage variant variantCfg)
  ];

in
{
  options.module.openra = {
    enable = mkEnableOption "Open Source real-time strategy game engine";

    release = mkOption {
      type = types.str;
      default = "release-20250330";
      description = "OpenRA release version";
    };

    variants = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            enable = mkEnableOption "Enable this OpenRA variant";
            appimageSha256 = mkOption {
              type = types.str;
              description = "SHA256 hash of the OpenRA AppImage for this variant";
            };
            iconSha256 = mkOption {
              type = types.str;
              description = "SHA256 hash of the OpenRA icon for this variant";
            };
          };
        }
      );
      default = { };
      description = "Configuration for each OpenRA variant";
    };
  };

  config = mkIf cfg.enable {
    home.packages = concatLists (mapAttrsToList mkVariant enabledVariants);
  };
}
