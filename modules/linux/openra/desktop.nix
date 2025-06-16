{
  lib,
  pkgs,
  variant,
  variantCfg,
  cfg,
}:

let
  icon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/OpenRA/OpenRA/refs/tags/${cfg.release}/mods/${variantCfg.modDir}/icon.png";
    sha256 = cfg.variants.${variant}.iconSha256;
  };
in
{
  desktopItem = pkgs.makeDesktopItem {
    name = "openra-${variant}";
    exec = "${
      pkgs.callPackage ./package.nix {
        inherit
          lib
          pkgs
          variant
          variantCfg
          cfg
          ;
      }
    }/bin/openra-${variant}";
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

  inherit icon;
}
