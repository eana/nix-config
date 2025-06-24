{ lib, pkgs }:

pkgs.wezterm.overrideAttrs (_: {
  # Add any package overrides here if needed
  # For example:
  # patches = [ ./some-patch.patch ];
  # buildInputs = oldAttrs.buildInputs ++ [ pkgs.someDependency ];

  meta = with lib; {
    description = "A GPU-accelerated cross-platform terminal emulator and multiplexer";
    homepage = "https://wezfurlong.org/wezterm/";
    license = licenses.mit;
    platforms = platforms.all;
  };
})
