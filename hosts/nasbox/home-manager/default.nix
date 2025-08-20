{ pkgs, ... }:

{
  imports = [
    ../../../modules/common/default.nix
  ];

  home = {
    username = "root";
    homeDirectory = "/root";
    stateVersion = "24.05";

    packages = with pkgs; [
      nix-tree # Visualize Nix dependencies
    ];
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    home-manager.enable = true;
  };

  module = {
    git.enable = true;
    gpg-agent.enable = true;
    neovim.enable = true;
    tmux.enable = true;
    zsh.enable = true;
  };
}
