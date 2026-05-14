{ ... }:

{
  imports = [ ../../../modules/common/nix-cache.nix ];

  nix.settings = {
    trusted-users = [
      "root"
    ];

    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    # TEMPORARY: Disable package tests globally to unblock macbox builds.
    # TODO: Remove once the build issue is resolved.
    doCheckByDefault = false;
  };
}
