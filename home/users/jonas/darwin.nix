{
  pkgs,
  ...
}:

{
  imports = [ ./common.nix ];

  module.aerospace.enable = true;
  module.aerospace.modifier = "cmd";

  # Install packages for user.
  # Search for packages here: https://search.nixos.org/packages
  home = {
    packages = with pkgs; [
      cmake # Build system
      mas # Mac App Store command-line interface

      maccy # Lightweight clipboard manager

      # Networking
      iproute2mac # Utilities for controlling TCP/IP networking and traffic control in Linux
    ];
  };
}
