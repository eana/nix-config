{
  nixosConfig,
  pkgs,
  ...
}:
let
  theme = {
    package = pkgs.yaru-theme;
    name = "Yaru-prussiangreen";
  };

  aws-export-profile = pkgs.stdenv.mkDerivation {
    name = "aws-export-profile";
    src = pkgs.fetchFromGitHub {
      owner = "cytopia";
      repo = "aws-export-profile";
      rev = "0.7"; # or a specific commit/tag
      sha256 = "sha256-hvQzKXHfeyN4qm6kEAG/xuIqmHhL8GKpvn8aE+gTMDE=";
    };
    installPhase = ''
      mkdir -p $out/bin
      cp aws-export-profile $out/bin/aws-export-profile.sh
      chmod +x $out/bin/aws-export-profile.sh
    '';
  };
in
{
  systemd.user = import ./base/systemd.nix { inherit pkgs; };

  programs = {
    foot = import ./base/programs/foot.nix;
    fuzzel = import ./base/programs/fuzzel.nix;
    git = import ./base/programs/git.nix;
    neovim = import ./base/programs/neovim.nix;
    swaylock = import ./base/programs/swaylock.nix;
    tmux = import ./base/programs/tmux.nix { inherit pkgs; };
    waybar = import ./base/programs/waybar.nix { inherit pkgs; };
    zsh = import ./base/programs/zsh.nix { inherit pkgs; };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  wayland.windowManager.sway = import ./base/programs/sway.nix { inherit pkgs; };

  services = {
    avizo = import ./base/services/avizo.nix;
    gpg-agent = import ./base/services/gpg-agent.nix { inherit pkgs; };
    gammastep = import ./base/services/gammastep.nix;
    kanshi = import ./base/services/kanshi.nix { inherit pkgs; };
    ollama = import ./base/services/ollama.nix;
  };

  dconf = {
    settings = {
      "org/gnome/desktop/interface" = {
        font-name = "SF Pro Text 11";
        monospace-font-name = "Source Code Pro 12";
        document-font-name = "Cantarell 12";
      };
    };
  };

  gtk = {
    enable = true;

    inherit theme;
    iconTheme = theme;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 0;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 0;
  };

  # Install packages for user.
  # Search for packages here: https://search.nixos.org/packages
  home = {
    packages = with pkgs; [
      # SwayWM and Wayland Tools
      wl-clipboard # Clipboard support for Wayland
      libnotify # Desktop notifications
      networkmanagerapplet # Network manager applet
      grim # Screenshot utility for Wayland
      mako # Notification daemon for Wayland
      slurp # Select a region in Wayland
      swaybg # Wallpaper tool for Sway
      swayidle # Idle management daemon for Sway
      imagemagick # Image manipulation tool

      # File Management
      gthumb # Image browser and viewer
      wget # Download utility
      axel # Download utility
      unzip # Unzip utility
      tree # Directory tree viewer
      fd # File search utility
      lsof # List open files
      nautilus # File manager

      # Media
      mpg123 # Audio player
      mpv # Video player
      freetube # YouTube client

      # Development Tools
      nil # Nix language server
      nixfmt-rfc-style # Nix code formatter
      nix-tree # Visualize Nix dependencies
      meld # Visual diff and merge tool
      gnumake # Build automation tool
      gcc # GNU Compiler Collection
      tree-sitter # Incremental parsing system
      fzf # Fuzzy finder
      go # Go programming language
      gotools # Tools for Go programming
      ripgrep # Search tool
      nix-prefetch-git # Prefetch Git repositories
      pre-commit # Framework for managing pre-commit hooks
      terraform # Infrastructure as code tool
      terraform-docs # Terraform documentation generator
      aws-export-profile # AWS profile exporter
      checkov # Static code analysis tool for Terraform

      # Version Control
      tig # Text-mode interface for Git
      git-absorb # Automatically fixup commits
      lazygit # Simple terminal UI for Git commands

      # File and Text Manipulation
      glow # Markdown renderer for the terminal
      jaq # JSON processor
      xh # Friendly and fast HTTP client
      jq # Command-line JSON processor

      # Language Servers and Linters
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

      # Programming Languages and Runtimes
      python3 # Python programming language
      lua # Lua programming language
      luajitPackages.luarocks # Package manager for Lua modules
      nodejs_22 # JavaScript runtime

      # Diagramming Tools
      d2 # Modern diagram scripting language

      # Containers
      podman # Tool for managing OCI containers

      # Fonts
      cantarell-fonts # Cantarell font family

      # Other
      neofetch # System information tool
      sops # Secrets management tool
      blueman # Bluetooth manager
      copyq # Clipboard manager
      earlyoom # Early OOM daemon
      google-chrome # Web browser
      brightnessctl # Utility to control brightness
      pavucontrol # PulseAudio volume control
      playerctl # Media player controller
      system-config-printer # Printer configuration tool
      telegram-desktop # Telegram client
      fuse-emulator # ZX Spectrum emulator
      oath-toolkit # OATH one-time password tool
      awscli2 # AWS command-line interface
      direnv # Environment switcher
    ];

    file = {
      ".config" = {
        source = ./assets/.config;
        recursive = true;
      };

      ".local" = {
        source = ./assets/.local;
        recursive = true;
      };

      ".p10k.zsh" = {
        source = ./assets/.p10k.zsh;
      };
    };

    sessionVariables = {
      LIBGL_ALWAYS_INDIRECT = 1;
      LESS = "-iXFR";
      DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
      KPT_FN_RUNTIME = "podman";
    };

    inherit (nixosConfig.system) stateVersion;
  };
}
