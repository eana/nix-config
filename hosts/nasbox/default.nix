{
  imports = [
    # keep-sorted start
    ./home-manager/default.nix
    ./nix/default.nix
    # keep-sorted end
  ];

  home.stateVersion = "24.05";

  programs = {
    zsh.enable = true;
  };
}
