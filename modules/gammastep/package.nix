{ lib, pkgs }:

pkgs.gammastep.overrideAttrs (_: {
  # Add any package overrides here if needed
  # For example:
  # buildInputs = oldAttrs.buildInputs ++ [ pkgs.geoclue2 ];

  meta = with lib; {
    description = "Adjust screen color temperature based on time of day";
    homepage = "https://gitlab.com/chinstrap/gammastep";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
})
