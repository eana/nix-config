{
  pkgs,
  ...
}:
{
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
  };

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

      # Media
      mpg123 # Audio player
      mpv # Video player

      # Development Tools
      fzf # Fuzzy finder
      nixfmt-rfc-style # Nix code formatter
      pre-commit # Framework for managing pre-commit hooks
      ripgrep # Search tool

      # Version Control
      git-absorb # Automatically fixup commits
      lazygit # Simple terminal UI for Git commands
      tig # Text-mode interface for Git

      # File and Text Manipulation
      glow # Markdown renderer for the terminal
      jaq # JSON processor
      jq # Command-line JSON processor
      xh # Friendly and fast HTTP client

      # Programming Languages and Runtimes
      lua # Lua programming language
      luajitPackages.luarocks # Package manager for Lua modules
      luajitPackages.tiktoken_core # Tokenizer for Lua
      nodejs_22 # JavaScript runtime
      python3 # Python programming language

      # Diagramming Tools
      d2 # Modern diagram scripting language

      # Other
      firefox # Web browser
      google-chrome # Web browser
      neofetch # System information tool
      sops # Secrets management tool
      telegram-desktop # Telegram client
    ];

    sessionVariables = {
      LESS = "-iXFR";
      BUILDKIT_PROGRESS = "plain";
    };

    stateVersion = "24.05";
  };

  module = {
    git.enable = true;
    gpg-agent.enable = true;
    neovim.enable = true;
    tmux.enable = true;
    zsh.enable = true;
  };
}
