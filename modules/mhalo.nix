{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.mhalo;

  src = pkgs.fetchFromGitHub {
    owner = "progandy";
    repo = "mhalo";
    rev = "3088f5152f66360828df0e7935b020f6500f540b";
    hash = "sha256-AKardcq/vkU+bMsWSdPXQlrQgl3eer0xJdPvQvy0IVo=";
  };

  mhaloPackage = pkgs.stdenv.mkDerivation {
    pname = "mhalo";
    version = "git-${lib.substring 0 7 src.rev}";

    inherit src;

    nativeBuildInputs = with pkgs; [
      cmake
      meson
      ninja
      pkg-config
      makeWrapper
      qt6.wrapQtAppsHook
    ];

    buildInputs = with pkgs; [
      qt6.full
      qt6.qtwayland
      pixman
      wayland
      wayland-protocols
      tllist
    ];

    mesonFlags = [
      "--buildtype=release"
      "--prefix=${placeholder "out"}"
      "-Doptimization=3"
    ];

    preConfigure = ''
      mkdir -p build
    '';

    configurePhase = ''
      meson setup build $mesonFlags
    '';

    buildPhase = ''
      ninja -C build
    '';

    installPhase = ''
      ninja -C build install
    '';

    dontWrapQtApps = true;
    postFixup = ''
      wrapQtApp $out/bin/mhalo
    '';

    meta = with lib; {
      description = "A halo effect for your mouse pointer";
      homepage = "https://github.com/progandy/mhalo";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
    };
  };

in
{
  options.module.mhalo = {
    enable = mkEnableOption "mHalo mouse pointer effect";
    package = mkOption {
      type = types.package;
      default = mhaloPackage;
      description = "The mHalo package to use";
    };
    swayKeybinding = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Sway keybinding to launch mHalo (e.g., "Mod4+Shift+h").
        Set to null to skip adding keybinding.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    wayland.windowManager.sway.config.keybindings = lib.mkIf (cfg.swayKeybinding != null) {
      "${cfg.swayKeybinding}" = "exec ${cfg.package}/bin/mhalo";
    };
  };
}
