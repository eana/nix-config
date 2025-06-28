{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      blueman
      curl
      dive
      docker-compose
      gparted
      jetbrains.idea-community-bin
      podman-tui
      vscode
      zsh-powerlevel10k
    ];
  };

  fonts = {
    enableDefaultPackages = true;
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
