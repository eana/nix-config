# openra-packages.nix
{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  appimage-run,
  icu,
  libunwind,
  zlib,
  copyDesktopItems,
  makeDesktopItem,
}:

let
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
    {
      variant,
      release,
      appimageSha256,
      iconSha256,
    }:
    let
      variantCfg = variants.${variant};
      icon = fetchurl {
        url = "https://raw.githubusercontent.com/OpenRA/OpenRA/refs/tags/${release}/mods/${variantCfg.modDir}/icon.png";
        sha256 = iconSha256;
      };
    in
    stdenv.mkDerivation {
      pname = "openra-${variant}";
      version = lib.removePrefix "release-" release;

      src = fetchurl {
        url = "https://github.com/OpenRA/OpenRA/releases/download/${release}/OpenRA-${variantCfg.appimageSuffix}-x86_64.AppImage";
        sha256 = appimageSha256;
      };

      nativeBuildInputs = [
        makeWrapper
        copyDesktopItems
      ];

      buildInputs = [
        appimage-run
        icu
        libunwind
        zlib
        stdenv.cc.cc.lib
      ];

      # Skip unpack phase since we're using the AppImage directly
      dontUnpack = true;

      desktopItems = [
        (makeDesktopItem {
          name = "openra-${variant}";
          exec = "openra-${variant}";
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
        })
      ];

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin $out/share/icons/hicolor/64x64/apps

        # Install AppImage directly
        install -Dm755 $src $out/bin/openra-${variant}.AppImage

        # Create wrapper
        makeWrapper ${appimage-run}/bin/appimage-run $out/bin/openra-${variant} \
          --prefix LD_LIBRARY_PATH : "${
            lib.makeLibraryPath [
              icu
              libunwind
              zlib
              stdenv.cc.cc.lib
            ]
          }" \
          --add-flags "$out/bin/openra-${variant}.AppImage"

        # Install icon
        install -Dm644 ${icon} $out/share/icons/hicolor/64x64/apps/openra-${variant}.png

        # Install desktop file
        copyDesktopItems

        runHook postInstall
      '';
    };
in
{
  inherit mkOpenRAPackage variants;
}
