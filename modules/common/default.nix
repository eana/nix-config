{
  inputs,
  nixvimInput ? inputs.nixvim,
  ...
}:
{
  imports = [
    nixvimInput.homeModules.nixvim

    # keep-sorted start
    ./atuin/default.nix
    ./git/default.nix
    ./gpg-agent/default.nix
    ./kitty/default.nix
    ./neovim/default.nix
    ./nixvim/default.nix
    ./ollama/default.nix
    ./opencode/default.nix
    ./podman/default.nix
    ./ssh-client/default.nix
    ./tmux/default.nix
    ./zsh/default.nix
    # keep-sorted end
  ];
}
