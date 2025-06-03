{ lib, pkgs }:

pkgs.fuzzel.overrideAttrs (_: {
  # Add any package overrides here if needed
  # Example:
  # patches = [ ./some-patch.patch ];
  # buildInputs = oldAttrs.buildInputs ++ [ pkgs.someExtraDependency ];

  meta = with lib; {
    description = "A Wayland-native application launcher";
    homepage = "https://codeberg.org/dnkl/fuzzel";
    license = licenses.mit;
    platforms = platforms.linux;
  };
})
