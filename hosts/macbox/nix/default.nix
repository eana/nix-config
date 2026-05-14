{ ... }:

{
  imports = [ ../../../modules/common/nix-cache.nix ];

  nix = {
    settings = {
      trusted-users = [
        "root"
        "jonas"
      ];

      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    gc = {
      automatic = true;
      interval.Hour = 3;
      options = "--delete-older-than 14d";
    };
  };

  nixpkgs = {
    hostPlatform = "x86_64-darwin";
    config = {
      allowUnfree = true;
      # TEMPORARY: Disable package tests globally to unblock macbox builds.
      # TODO: Remove once the build issue is resolved.
      doCheckByDefault = false;
    };
  };
}
