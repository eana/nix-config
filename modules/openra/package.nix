{
  lib,
  pkgs,
  variant,
  variantCfg,
  cfg,
}:

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
        lib.makeLibraryPath (
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
  ''
