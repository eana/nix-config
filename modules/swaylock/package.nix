{ lib, pkgs }:

pkgs.swaylock.overrideAttrs (_: {
  # Add any package overrides here if needed
  # For example:
  # patches = [ ./some-patch.patch ];
  # buildInputs = oldAttrs.buildInputs ++ [ pkgs.someDependency ];

  meta = with lib; {
    description = "Screen locking utility for Wayland";
    homepage = "https://github.com/swaywm/swaylock";
    license = licenses.mit;
    platforms = platforms.linux;
  };
})
