{ lib, pkgs }:

pkgs.zsh.overrideAttrs (_: {
  # Add any package overrides here if needed
  # For example:
  # patches = [ ./some-patch.patch ];
  # buildInputs = oldAttrs.buildInputs ++ [ pkgs.someDependency ];

  meta = with lib; {
    description = "The Z shell";
    homepage = "https://www.zsh.org/";
    license = licenses.mit;
    platforms = platforms.unix;
  };
})
