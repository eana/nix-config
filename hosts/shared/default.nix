{ ... }: {
  imports = [
    # keep-sorted start
    ./home-manager/default.nix
    ./nix/default.nix
    ./secrets.nix
    ./system/environment.nix
    ./system/packages.nix
    # keep-sorted end
  ];
}
