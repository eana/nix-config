{ pkgs, ... }: {
  programs.nix-index-database.comma.enable = true;

  environment.systemPackages = with pkgs; [
    # keep-sorted start
    home-manager
    m-cli
    mkalias
    zsh-powerlevel10k
    # keep-sorted end
  ];
}
