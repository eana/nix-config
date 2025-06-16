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
      m-cli # Command-line utility for managing macOS
      wezterm # GPU-accelerated terminal emulator
    ];
  };
}
