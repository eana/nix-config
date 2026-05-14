{ pkgs, ... }:

{
  imports = [ ../../../modules/common/nix-cache.nix ];

  nix = {
    # home-manager on non-NixOS requires an explicit nix.package.
    package = pkgs.nix;
    settings = {
      trusted-users = [
        "root"
      ];

      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    # TEMPORARY: Disable package tests globally to unblock macbox builds.
    # TODO: Remove once the build issue is resolved.
    doCheckByDefault = false;
  };
}
