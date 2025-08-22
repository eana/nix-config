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
      util-linux # Set of system utilities for Linux
      nix-tree # Visualize Nix dependencies
    ];

    sessionVariables = {
      LESS = "-iXFR";
    };
  };
}
