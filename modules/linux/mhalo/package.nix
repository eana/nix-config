{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  meson,
  ninja,
  pkg-config,
  makeWrapper,
  wrapQtAppsHook,
  qt6,
  pixman,
  wayland,
  wayland-protocols,
  tllist,
}:

stdenv.mkDerivation rec {
  pname = "mhalo";
  version = "git-3088f51";

  src = fetchFromGitHub {
    owner = "progandy";
    repo = "mhalo";
    rev = "3088f5152f66360828df0e7935b020f6500f540b";
    hash = "sha256-AKardcq/vkU+bMsWSdPXQlrQgl3eer0xJdPvQvy0IVo=";
  };

  nativeBuildInputs = [
    cmake
    meson
    ninja
    pkg-config
    makeWrapper
    wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
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

  dontWrapQtApps = true;

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

  postFixup = ''
    wrapQtApp $out/bin/mhalo \
      --prefix QT_PLUGIN_PATH : ${qt6.qtbase}/${qt6.qtbase.qtPluginPrefix}
  '';

  meta = with lib; {
    description = "A halo effect for your mouse pointer";
    homepage = "https://github.com/progandy/mhalo";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
