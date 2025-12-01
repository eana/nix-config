{
  pkgs,
  ...
}:

{
  imports = [ ./common.nix ];

  # Install packages for user.
  # Search for packages here: https://search.nixos.org/packages
  home = {
    packages = with pkgs; [
      cmake # Build system
      mas # Mac App Store command-line interface

      # Networking
      iproute2mac # Utilities for controlling TCP/IP networking and traffic control in Linux
    ];
  };
}
