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
      mas # Mac App Store command-line interface
      wezterm # GPU-accelerated terminal emulator
    ];
  };
}
