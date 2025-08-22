{
  pkgs,
  ...
}:
{
  imports = [ ./common.nix ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    home-manager.enable = true;
  };

  # Install packages for user.
  # Search for packages here: https://search.nixos.org/packages
  home = {
    packages = with pkgs; [
      ncurses5 # Terminal handling library
      nix-tree # Visualize Nix dependencies
      util-linux # Set of system utilities for Linux
    ];

    sessionVariables = {
      LESS = "-iXFR";
    };
  };
}
