{
  pkgs,
  sshSecretsPath ? null,
  atuinSecretsPath ? null,
  ...
}:
{
  imports = [ ../shared.nix ];

  # Install packages for user.
  # Search for packages here: https://search.nixos.org/packages
  home.packages = with pkgs; [
    # File Management
    fd # File search utility
    lsof # List open files
    wget # Download utility
    zip # Zip utility

    # Networking
    inetutils # Collection of common network programs (ftp, telnet, etc.)
    net-tools # Network tools (ifconfig, netstat, etc.)

    # Media
    mpg123 # Audio player

    # Development Tools
    pre-commit # Framework for managing pre-commit hooks
    ripgrep # Search tool

    # Version Control
    git-absorb # Automatically fixup commits

    # File and Text Manipulation
    jaq # JSON processor
    jq # Command-line JSON processor
    xh # Friendly and fast HTTP client

    # Diagramming Tools
    d2 # Modern diagram scripting language

    # Security & Encryption
    age # Simple, modern and secure encryption tool

    # Messaging apps
    telegram-desktop # Telegram client
  ];

  home.sessionVariables = {
    BUILDKIT_PROGRESS = "plain";
    TERM = "xterm-256color";
  };

  custom.theme = "gruvbox";

  module = {
    atuin = {
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

    kitty = {
      enable = true;
      keybindings = {
        "shift+enter" = "send_text all \\x1b[13;2u";
        "ctrl+enter" = "send_text all \\x1b[13;5u";
      };
    };

    opencode = {
      enable = true;
      playwright.enable = true;
      garmin.enable = true;
      # To get the full list of skills:
      # nix eval --json --file modules/common/opencode/skills-catalog.nix | jaq .
      skills.enabled = [ "social" ];
      package = pkgs.opencode;
    };

    podman = {
      enable = true;
    };

    ssh-client = {
      enable = true;

      # Add hosts here that do not contain sensitive information.
      # hosts = {
      #   "xxx" = {
      #     hostname = "xxx";
      #     user = "xxx";
      #     port = 1111;
      #     identityFile = "~/.ssh/id_ed25519";
      #   };
      # };

      secretsFile = sshSecretsPath;

      globalOptions = {
        KexAlgorithms = "sntrup761x25519-sha512@openssh.com,curve25519-sha256";
      };
    };
  };
}
