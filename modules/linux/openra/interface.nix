{ lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    ;
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
            enable = mkEnableOption "this OpenRA variant";
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
}
