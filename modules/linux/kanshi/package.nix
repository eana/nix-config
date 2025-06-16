{ lib, pkgs }:

pkgs.kanshi.overrideAttrs (_: {
  # Add any package overrides here if needed
  # For example:
  # buildInputs = oldAttrs.buildInputs ++ [ pkgs.wayland ];

  meta = with lib; {
    description = "Dynamic display configuration tool for Wayland";
    homepage = "https://github.com/emersion/kanshi";
    license = licenses.mit;
    platforms = platforms.linux;
  };
})
