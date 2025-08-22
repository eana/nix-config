{
  imports = [
    ./home-manager/default.nix
    ./nix/default.nix
  ];

  home.stateVersion = "24.05";

  programs = {
    zsh.enable = true;
  };
}
