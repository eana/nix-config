{ lib, pkgs }:

pkgs.neovim.overrideAttrs (_: {
  # Add any package overrides here if needed
  # For example:
  # patches = [ ./some-patch.patch ];
  # buildInputs = oldAttrs.buildInputs ++ [ pkgs.someDependency ];

  meta = with lib; {
    description = "Vim-fork focused on extensibility and usability";
    homepage = "https://neovim.io/";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
})
