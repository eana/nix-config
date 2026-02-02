{ pkgs, ... }:

{
  programs = {
    # keep-sorted start
    dms-shell.enable = false;
    niri.enable = true;
    nix-index-database.comma.enable = true;
    ssh.startAgent = true;
    sway.enable = true;
    ydotool.enable = true;
    zsh.enable = true;
    # keep-sorted end
  };

  environment = {
    systemPackages = with pkgs; [
      # keep-sorted start
      blueman
      curl
      dive
      docker-compose
      gparted
      podman-tui
      zsh-powerlevel10k
      # keep-sorted end
    ];
  };

  fonts = {
    enableDefaultPackages = true;
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
