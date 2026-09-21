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
      alt-tab-macos # Windows alt-tab on macOS
      cmake # Build system
      iproute2mac # Utilities for controlling TCP/IP networking and traffic control in Linux
      maccy # Lightweight clipboard manager
      mas # Mac App Store command-line interface
    ];
  };
}
