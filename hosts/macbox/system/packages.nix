{ pkgs, ... }:

{
  programs.nix-index-database.comma.enable = true;

  environment.systemPackages = with pkgs; [
    home-manager
    m-cli
    mkalias
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
