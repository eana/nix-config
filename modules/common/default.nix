{ inputs, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim

    ./atuin/default.nix
    ./git/default.nix
    ./gpg-agent/default.nix
    ./kitty/default.nix
    ./neovim/default.nix
    ./nixvim/default.nix
    ./ollama/default.nix
    ./ssh-client/default.nix
    ./tmux/default.nix
    ./zsh/default.nix
  ];
}
