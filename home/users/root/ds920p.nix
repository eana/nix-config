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
      dnsutils # DNS utilities like dig, nslookup, etc.
      file # File type identification utility
      iftop # Display bandwidth usage on an interface
      inetutils # Collection of common network programs
      iotop # Display I/O usage by processes
      iperf # Network bandwidth measurement tool
      iputils # Network utilities like ping, traceroute, etc.
      lsof # List open files
      ncurses5 # Terminal handling library
      nethogs # Display bandwidth usage per process
      nix-tree # Visualize Nix dependencies
      procps # Utilities for monitoring system processes
      sysstat # Performance monitoring tools
      util-linux # Set of system utilities for Linux
      zmap # Network scanner
    ];

    sessionVariables = {
      LESS = "-iXFR";
    };
  };
}
