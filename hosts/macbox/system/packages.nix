{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    home-manager
    jetbrains.idea-community-bin
    m-cli
    mkalias
    vscode
    zsh-powerlevel10k
  ];
}
