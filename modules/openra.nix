{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

{
  options = {
    module.openra = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Open Source real-time strategy game engine";
      };
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
        default = "https://raw.githubusercontent.com/OpenRA/OpenRA/refs/tags/${config.module.openra.release}/mods/ra/icon.png";
        description = "URL to fetch OpenRA icon from";
      };
    };
  };

  config = mkIf config.module.openra.enable {
    home.packages = with pkgs; [
      (runCommand "openra"
        {
          buildInputs = [
            makeWrapper
            appimage-run
          ];
          nativeBuildInputs = [
            icu
            libunwind
            zlib
          ];
          src = fetchurl {
            url = "https://github.com/OpenRA/OpenRA/releases/download/${config.module.openra.release}/OpenRA-Red-Alert-x86_64.AppImage";
            sha256 = config.module.openra.appimageSha256;
          };
        }
        ''
          mkdir -p $out/bin
          cp $src $out/bin/openra.AppImage
          chmod +x $out/bin/openra.AppImage

          makeWrapper ${appimage-run}/bin/appimage-run $out/bin/openra \
            --prefix LD_LIBRARY_PATH : "${
              makeLibraryPath [
                icu
                libunwind
                zlib
                stdenv.cc.cc.lib
              ]
            }" \
            --add-flags "$out/bin/openra.AppImage"

          # Desktop entry
          mkdir -p $out/share/applications
          cat > $out/share/applications/openra.desktop <<EOF
          [Desktop Entry]
          Version=1.0
          Name=OpenRA Red Alert
          Comment=Open Source reimplementation of Red Alert
          Exec=$out/bin/openra
          Icon=openra
          Terminal=false
          Type=Application
          Categories=Game;StrategyGame;
          EOF

          # Install icon
          mkdir -p $out/share/icons/hicolor/64x64/apps
          cp ${
            fetchurl {
              url = config.module.openra.iconUrl;
              sha256 = config.module.openra.iconSha256;
            }
          } $out/share/icons/hicolor/64x64/apps/openra.png
        ''
      )
    ];
  };
}
