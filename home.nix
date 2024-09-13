{ config, lib, pkgs, ... }:
let toml = pkgs.formats.toml { };
in {
  systemd.user.startServices = "sd-switch";

  programs = { gpg.enable = true; };

  # GPG agent.
  services.gpg-agent = {
    enable = true;
    # Use GPG for SSH.
    # enableSshSupport = true;

    defaultCacheTtl = 86400;
    maxCacheTtl = 86400;
    pinentryPackage = pkgs.pinentry-tty;
  };

  # Install packages for user.
  # Search for packages here: https://search.nixos.org/packages
  home = {
    packages = with pkgs; [
      # SwayWM
      wl-clipboard # Clipboard support for Wayland
      fuzzel # Fuzzy search for mako
      swaylock # Screen locker
      swaybg # Wallpaper utility
      grim # Screenshot utility
      slurp # Select a region for screenshots
      light # Screen brightness control
      pavucontrol # PulseAudio volume control
      waybar # Status bar for Sway
      networkmanagerapplet # Network manager applet
      mako # Notification daemon
      earlyoom # Early OOM killer
      gammastep # Screen temperature control
      kanshi # Dynamic display configuration

      # File management
      gthumb # Image browser and viewer
      nautilus # File manager
      copyq # Clipboard manager
      wget # Download utility
      axel # Download utility
      unzip # Unzip utility
      tree # Directory tree viewer
      fd # File search utility
      lsof # List open files

      # Media
      mpg123 # Audio player
      mpv # Video player

      # Development tools
      nil # Nix language server
      nixfmt-rfc-style # Nix code formatter
      nix-tree # Visualize Nix dependencies
      gnumake # Build automation tool
      gcc # GNU Compiler Collection
      tree-sitter # Incremental parsing system
      fzf # Fuzzy finder
      go # Go programming language
      gotools # Tools for Go programming
      tig # Text-mode interface for Git
      nix-prefetch-git # Prefetch Git repositories
      pre-commit # Framework for managing pre-commit hooks

      # Cloud and Kubernetes tools
      tenv # OpenTofu, Terraform, Terragrunt and Atmos version manager written in Go

      # Version Control
      gitMinimal # Git version control system
      git-absorb # Automatically fixup commits
      lazygit # Simple terminal UI for Git commands

      # File and text manipulation
      glow # Markdown renderer for the terminal
      jaq # JSON processor
      xh # Friendly and fast HTTP client
      jq # Command-line JSON processor

      # Language servers and linters
      bash-language-server # Language server for Bash
      black # Python code formatter
      jsonnet-language-server # Language server for Jsonnet
      lua-language-server # Language server for Lua
      nodePackages.jsonlint # JSON linter
      nodePackages.prettier # Code formatter
      shellcheck # Shell script analysis tool
      shfmt # Shell script formatter
      stylua # An opinionated code formatter for Lua
      terraform-ls # Language server for Terraform
      tflint # Linter for Terraform
      yaml-language-server # Language server for YAML
      yamlfmt # YAML formatter

      # Programming languages and runtimes
      python3 # Python programming language
      lua # Lua programming language
      luajitPackages.luarocks # Package manager for Lua modules
      nodejs_22 # JavaScript runtime

      # Diagramming tools
      d2 # Modern diagram scripting language
    ];

    stateVersion = "24.05";
  };
}
