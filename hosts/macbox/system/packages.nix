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

  fonts = {
    packages = with pkgs; [
      fira-code
      font-awesome_5
      helvetica-neue-lt-std
      meslo-lgs-nf
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.jetbrains-mono
      nerd-fonts.space-mono
      powerline-fonts
      powerline-symbols
      source-code-pro
    ];
  };
}
