{
  pkgs,
  sshSecretsPath ? null,
  atuinSecretsPath ? null,
  ...
}:
{
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    nh = {
      enable = true;
      flake = "/etc/nixos";
      clean = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  services.ssh-agent.enable = true;

  # Install packages for user.
  # Search for packages here: https://search.nixos.org/packages
  home = {
    packages = with pkgs; [
      # File Management
      axel # Download utility
      fd # File search utility
      lsof # List open files
      tree # Directory tree viewer
      unzip # Unzip utility
      wget # Download utility
      zip # Zip utility

      # Networking
      inetutils # Collection of common network programs (ftp, telnet, etc.)
      net-tools # Network tools (ifconfig, netstat, etc.)

      # Media
      mpg123 # Audio player

      # Development Tools
      fzf # Fuzzy finder
      pre-commit # Framework for managing pre-commit hooks
      ripgrep # Search tool

      # Version Control
      git-absorb # Automatically fixup commits
      lazygit # Simple terminal UI for Git commands
      tig # Text-mode interface for Git

      # File and Text Manipulation
      jaq # JSON processor
      jq # Command-line JSON processor
      xh # Friendly and fast HTTP client

      # Diagramming Tools
      d2 # Modern diagram scripting language

      # Nix Tools
      cachix # Binary cache client for Nix

      # Other
      neofetch # System information tool
      age # Simple, modern and secure encryption tool
      sops # Secrets management tool
    ];

    sessionVariables = {
      LESS = "-iXFR";
      BUILDKIT_PROGRESS = "plain";
      TERM = "xterm-256color";
    };

    stateVersion = "24.05";
  };

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

    git.enable = true;
    gpg-agent.enable = true;
    kitty.enable = true;
    neovim.enable = true;

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

    tmux.enable = true;
    zsh.enable = true;
  };
}
