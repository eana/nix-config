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
  };

  # Install packages for user.
  # Search for packages here: https://search.nixos.org/packages
  home = {
    packages = with pkgs; [
      # File Management
      aria2 # Download utility
      tree # Directory tree viewer
      unzip # Unzip utility

      # Development Tools
      fzf # Fuzzy finder

      # Version Control
      lazygit # Simple terminal UI for Git commands
      tig # Text-mode interface for Git

      # Programming Languages and Runtimes
      python3 # Python programming language

      # Diagramming Tools
      d2 # Modern diagram scripting language

      # Other
      neofetch # System information tool
    ];

    sessionVariables = {
      LESS = "-iXFR";
      TERM = "xterm-256color";
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
