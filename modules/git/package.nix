{ lib, pkgs }:

pkgs.git.overrideAttrs (_: {
  # Add any package overrides here if needed
  # Example:
  # patches = [ ./some-patch.patch ];
  # buildInputs = oldAttrs.buildInputs ++ [ pkgs.git-lfs pkgs.git-email ];

  meta = with lib; {
    description = "Distributed version control system";
    homepage = "https://git-scm.com/";
    license = licenses.gpl2;
    platforms = platforms.all;
  };
})
