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

  fonts.enableDefaultPackages = true;
}
