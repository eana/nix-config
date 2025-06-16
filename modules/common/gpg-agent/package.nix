{ lib, pkgs }:

pkgs.gnupg.overrideAttrs (_: {
  # Add any package overrides here if needed
  # For example:
  # buildInputs = oldAttrs.buildInputs ++ [ pkgs.scdaemon ];

  meta = with lib; {
    description = "GNU Privacy Guard with custom agent settings";
    homepage = "https://gnupg.org";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
  };
})
