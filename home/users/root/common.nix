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
    nh = {
      enable = true;
      flake = "/etc/nixos";
      clean = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  # Install packages for user.
  # Search for packages here: https://search.nixos.org/packages
  home = {
    packages = with pkgs; [
      # File Management
      axel # Download utility
      tree # Directory tree viewer
      unzip # Unzip utility

      # Development Tools
      fzf # Fuzzy finder

      # Version Control
      lazygit # Simple terminal UI for Git commands
      tig # Text-mode interface for Git

      # Diagramming Tools
      d2 # Modern diagram scripting language

      # Nix Tools
      cachix # Binary cache client for Nix

      # Other
      neofetch # System information tool
    ];

    sessionVariables = {
      LESS = "-iXFR";
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
