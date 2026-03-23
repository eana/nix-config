{
  imports = [
    # keep-sorted start
    ./home-manager/default.nix
    ./nix/default.nix
    # keep-sorted end
  ];

  home.stateVersion = "26.05";

  programs = {
    zsh.enable = true;
  };
}
