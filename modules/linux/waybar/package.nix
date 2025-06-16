{ lib, pkgs }:

pkgs.waybar.overrideAttrs (_: {
  # Add any package overrides here if needed
  # For example:
  # patches = [ ./some-patch.patch ];
  # buildInputs = oldAttrs.buildInputs ++ [ pkgs.someDependency ];

  meta = with lib; {
    description = "Highly customizable Wayland bar for Sway and Wlroots based compositors";
    homepage = "https://github.com/Alexays/Waybar";
    license = licenses.mit;
    platforms = platforms.linux;
  };
})
