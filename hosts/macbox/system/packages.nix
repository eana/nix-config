{ pkgs, ... }:

{
  programs.nix-index-database.comma.enable = true;

  environment.systemPackages = with pkgs; [
    # keep-sorted start
    home-manager
    m-cli
    mkalias
    zsh-powerlevel10k
    # keep-sorted end
  ];

  fonts = {
    packages = with pkgs; [
      # keep-sorted start
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
      # keep-sorted end
    ];
  };
}
