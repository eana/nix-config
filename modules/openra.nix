# openra.nix
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

let
  cfg = config.module.openra;
  openraPackages = pkgs.callPackage ./openra-packages.nix { };
  enabledVariants = lib.attrsets.filterAttrs (
    name: _: cfg.variants.${name}.enable or false
  ) openraPackages.variants;
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
    home.packages = lib.attrsets.mapAttrsToList (
      variant: _:
      let
        variantCfg = cfg.variants.${variant};
      in
      openraPackages.mkOpenRAPackage {
        inherit variant;
        inherit (cfg) release;
        inherit (variantCfg) appimageSha256 iconSha256;
      }
    ) enabledVariants;
  };
}
