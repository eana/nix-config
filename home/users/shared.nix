{ pkgs, ... }:
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

      # Nix Tools
      cachix # Binary cache client for Nix

      # System Information
      fastfetch # System information tool
    ];

    sessionVariables = {
      LESS = "-iXFR";
    };

    stateVersion = "26.05";
  };

  module = {
    git = {
      enable = true;
      ghq.options.root = "~/repos";
    };

    gpg-agent.enable = true;

    nixvim = {
      enable = true;
      wrapColumn = 120;
    };

    tmux.enable = true;
    zsh.enable = true;
  };
}
