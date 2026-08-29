{
  pkgs,
  atuinSecretsPath ? null,
  ...
}:
{
  imports = [ ./common.nix ];

  programs.home-manager.enable = true;

  module.atuin = {
    enable = true;
    sync = {
      enable = true;
      address = "https://atuin.eana.win";
      credentialsFile = atuinSecretsPath;
    };
    settings = {
      sync_frequency = "10m";
      search_mode = "fuzzy";
    };
  };

  # Install packages for user.
  # Search for packages here: https://search.nixos.org/packages
  home.packages = with pkgs; [
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
}
