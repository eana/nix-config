{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

let
  cfg = config.module.openra;
  openra-pkg =
    pkgs.runCommand "openra"
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
          url = "https://github.com/OpenRA/OpenRA/releases/download/${cfg.release}/OpenRA-Red-Alert-x86_64.AppImage";
          sha256 = cfg.appimageSha256;
        };
      }
      ''
        mkdir -p $out/bin
        cp $src $out/bin/openra.AppImage
        chmod +x $out/bin/openra.AppImage
        makeWrapper ${pkgs.appimage-run}/bin/appimage-run $out/bin/openra \
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
          --add-flags "$out/bin/openra.AppImage"
      '';

  desktopItem = pkgs.makeDesktopItem {
    name = "openra";
    exec = "${openra-pkg}/bin/openra";
    icon = "openra";
    comment = "Open Source reimplementation of Red Alert";
    desktopName = "OpenRA Red Alert";
    genericName = "Strategy Game";
    categories = [
      "Game"
      "StrategyGame"
    ];
    terminal = false;
    startupWMClass = "openra";
  };

  openra-icon = pkgs.fetchurl {
    url = cfg.iconUrl;
    sha256 = cfg.iconSha256;
  };

in
{
  options.module.openra = {
    enable = mkEnableOption "Open Source real-time strategy game engine";
    release = mkOption {
      type = types.str;
      default = "release-20250330";
      description = "OpenRA release version";
    };
    appimageSha256 = mkOption {
      type = types.str;
      default = "sha256-PLccdCgYjIUm3YkWmT/Bb6F7pfKKNZaKgmfz258hhv4=";
      description = "SHA256 hash of the OpenRA AppImage";
    };
    iconSha256 = mkOption {
      type = types.str;
      default = "sha256-6IadsH5NGKXZ3gye3JYVTCDC/uPwy3BRXhuAp5+10qA=";
      description = "SHA256 hash of the OpenRA icon";
    };
    iconUrl = mkOption {
      type = types.str;
      default = "https://raw.githubusercontent.com/OpenRA/OpenRA/refs/tags/${cfg.release}/mods/ra/icon.png";
      description = "URL to fetch OpenRA icon from";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      openra-pkg
      (pkgs.runCommand "openra-desktop"
        {
          nativeBuildInputs = [ pkgs.copyDesktopItems ];
          desktopItems = [ desktopItem ];
        }
        ''
          mkdir -p $out/share/icons/hicolor/64x64/apps
          cp ${openra-icon} $out/share/icons/hicolor/64x64/apps/openra.png
          copyDesktopItems
        ''
      )
    ];
  };
}
