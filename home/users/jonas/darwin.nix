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
    ];
  };
  module.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 1;
    };
  };
}
