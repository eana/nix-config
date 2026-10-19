{
  config,
  lib,
  pkgs,
  ...
}:
let
  atuinCredentialsFile = "${config.home.homeDirectory}/.local/share/atuin/atuin-credentials";
  atuinEncryptedCredentialsFile = ../../../secrets/atuin.age;
in
{
  imports = [ ./common.nix ];

  programs.home-manager.enable = true;

  module = {
    atuin = {
      enable = true;
      sync = {
        enable = true;
        address = "https://atuin.eana.win";
        credentialsFile = atuinCredentialsFile;
      };
      settings = {
        sync_frequency = "10m";
        search_mode = "fuzzy";
      };
    };

    git.identities.default = {
      sshKey = "~/.ssh/id_ed25519_git";
      pathPatterns = [ "~/repos/**" ];
    };
  };

  # HACK: DSM does not provide systemd --user for root, so agenix and atuin-login
  # user units never start. Decrypt credentials and run atuin login in activation.
  # TODO: Remove this fallback once DSM provides a working root systemd --user
  # session and restore the agenix + systemd.user.services.atuin-login flow.
  home.activation.atuinLogin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -euo pipefail

    CRED_FILE="${atuinCredentialsFile}"
    ATUIN="${pkgs.atuin}/bin/atuin"

    mkdir -p "$(dirname "$CRED_FILE")"

    ${pkgs.gnused}/bin/sed -i '/atuin\.eana\.win/d' /etc/hosts
    ${pkgs.coreutils}/bin/printf "192.168.0.145 atuin.eana.win\n" >> /etc/hosts

    ${pkgs.age}/bin/age --decrypt \
      -i "${config.home.homeDirectory}/.ssh/id_ed25519" \
      -o "$CRED_FILE" \
      ${atuinEncryptedCredentialsFile}
    chmod 0400 "$CRED_FILE"

    if "$ATUIN" status &>/dev/null; then
      echo "Atuin: already logged in."
    else
      USERNAME=$(${pkgs.gnugrep}/bin/grep "^username:" "$CRED_FILE" | ${pkgs.coreutils}/bin/cut -d: -f2- | ${pkgs.coreutils}/bin/tr -d '[:space:]')
      PASSWORD=$(${pkgs.gnugrep}/bin/grep "^password:" "$CRED_FILE" | ${pkgs.coreutils}/bin/cut -d: -f2- | ${pkgs.coreutils}/bin/tr -d '[:space:]')
      KEY=$(${pkgs.gnugrep}/bin/grep "^key:" "$CRED_FILE" | ${pkgs.coreutils}/bin/cut -d: -f2-)

      "$ATUIN" login --username "$USERNAME" --password "$PASSWORD" --key "$KEY"
      echo "Atuin: login successful."
    fi
  '';

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
