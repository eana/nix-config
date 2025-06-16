{ lib, pkgs }:

pkgs.sway.overrideAttrs (_: {
  # Add any package overrides here if needed
  # For example:
  # patches = [ ./some-patch.patch ];
  # buildInputs = oldAttrs.buildInputs ++ [ pkgs.someDependency ];

  meta = with lib; {
    description = "i3-compatible Wayland compositor";
    homepage = "https://swaywm.org/";
    license = licenses.mit;
    platforms = platforms.linux;
  };
})
