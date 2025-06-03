{ lib, pkgs }:

pkgs.avizo.overrideAttrs (_: {
  # Add any package overrides here if needed
  # For example:
  # patches = [ ./custom-fix.patch ];
  # buildInputs = oldAttrs.buildInputs ++ [ pkgs.glib ];

  meta = with lib; {
    description = "Lightweight notification daemon for Wayland";
    homepage = "https://github.com/misterdanb/avizo";
    license = licenses.mit;
    platforms = platforms.linux;
  };
})
