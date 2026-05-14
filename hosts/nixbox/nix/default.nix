{ ... }:

{
  imports = [ ../../../modules/common/nix-cache.nix ];

  nix = {
    settings = {
      trusted-users = [
        "root"
        "jonas"
        "@wheel"
      ];

      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    gc = {
      automatic = true;
      dates = "12:12";
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    # TEMPORARY: Disable package tests globally to unblock macbox builds.
    # TODO: Remove once the build issue is resolved.
    doCheckByDefault = false;
  };
}
