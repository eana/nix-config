{ lib, pkgs }:

pkgs.kitty.overrideAttrs (_: {
  # Add any package overrides here if needed
  # For example:
  # patches = [ ./some-patch.patch ];
  # buildInputs = oldAttrs.buildInputs ++ [ pkgs.someDependency ];

  meta = with lib; {
    description = "A fast, feature-rich, GPU based terminal emulator";
    homepage = "https://sw.kovidgoyal.net/kitty/";
    license = lib.licenses.gpl3;
    platforms = platforms.unix;
  };
})
