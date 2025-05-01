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

  mkOpenRAPackage =
    variant:
    let
      variantCfg = variants.${variant};
    in
    pkgs.runCommand "openra-${variant}"
      {
        buildInputs = [
          pkgs.makeWrapper
          pkgs.appimage-run
        ];
        nativeBuildInputs = with pkgs; [
          icu
          libunwind
          zlib
        ];
        src = pkgs.fetchurl {
          url = "https://github.com/OpenRA/OpenRA/releases/download/${cfg.release}/OpenRA-${variantCfg.appimageSuffix}-x86_64.AppImage";
          sha256 = cfg.variants.${variant}.appimageSha256;
        };
      }
      ''
        mkdir -p $out/bin
        cp $src $out/bin/openra-${variant}.AppImage
        chmod +x $out/bin/openra-${variant}.AppImage
        makeWrapper ${pkgs.appimage-run}/bin/appimage-run $out/bin/openra-${variant} \
          --prefix LD_LIBRARY_PATH : "${
            pkgs.lib.makeLibraryPath (
              with pkgs;
              [
                icu
                libunwind
                zlib
                stdenv.cc.cc.lib
              ]
            )
          }" \
          --add-flags "$out/bin/openra-${variant}.AppImage"
      '';

  mkDesktopItem =
    variant:
    let
      variantCfg = variants.${variant};
    in
    pkgs.makeDesktopItem {
      name = "openra-${variant}";
      exec = "${mkOpenRAPackage variant}/bin/openra-${variant}";
      icon = "openra-${variant}";
      comment = "Open Source reimplementation of ${variantCfg.name}";
      desktopName = "OpenRA ${variantCfg.name}";
      genericName = "Strategy Game";
      categories = [
        "Game"
        "StrategyGame"
      ];
      terminal = false;
      startupWMClass = "openra";
    };

  mkIcon =
    variant:
    pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/OpenRA/OpenRA/refs/tags/${cfg.release}/mods/${variants.${variant}.modDir}/icon.png";
      sha256 = cfg.variants.${variant}.iconSha256;
    };

  enabledVariants = lib.attrsets.filterAttrs (name: _: cfg.variants.${name}.enable or false) variants;

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
    home.packages = lib.lists.concatLists (
      lib.attrsets.mapAttrsToList (variant: _: [
        (mkOpenRAPackage variant)
        (pkgs.runCommand "openra-${variant}-desktop"
          {
            nativeBuildInputs = [ pkgs.copyDesktopItems ];
            desktopItems = [ (mkDesktopItem variant) ];
          }
          ''
            mkdir -p $out/share/icons/hicolor/64x64/apps
            cp ${mkIcon variant} $out/share/icons/hicolor/64x64/apps/openra-${variant}.png
            copyDesktopItems
          ''
        )
      ]) enabledVariants
    );
  };
}
