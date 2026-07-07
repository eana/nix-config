{ inputs, ... }:

{
  imports = [
    # keep-sorted start
    ../shared/default.nix
    ../shared/system/darwin.nix
    ./home-manager/default.nix
    ./nix/default.nix
    ./system/defaults.nix
    ./system/environment.nix
    ./system/homebrew.nix
    ./system/packages.nix
    # keep-sorted end
  ];

  system = {
    primaryUser = "jonas";
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
    stateVersion = 6;
  };
}
