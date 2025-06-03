{ lib, pkgs }:

pkgs.tmux.overrideAttrs (_: {
  # Add any package overrides here if needed
  # For example:
  # patches = [ ./some-patch.patch ];
  # buildInputs = oldAttrs.buildInputs ++ [ pkgs.someDependency ];

  meta = with lib; {
    description = "Terminal multiplexer";
    homepage = "https://tmux.github.io/";
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
})
