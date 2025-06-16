{ lib, pkgs }:

pkgs.foot.overrideAttrs (_: {
  # Add any package overrides here if needed
  # For example:
  # patches = [ ./some-patch.patch ];
  # buildInputs = oldAttrs.buildInputs ++ [ pkgs.someDependency ];

  meta = with lib; {
    description = "A fast, lightweight and minimalistic Wayland terminal emulator";
    homepage = "https://codeberg.org/dnkl/foot";
    license = licenses.mit;
    platforms = platforms.linux;
  };
})
