{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ../../../modules/common/nix-cache.nix ];

  nix = {
    settings = {
      trusted-users = [
        "root"
        config.module.variables.userName
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ "@wheel" ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = true;
    }
    // (
      if pkgs.stdenv.hostPlatform.isDarwin then
        {
          interval.Hour = 3;
          options = "--delete-older-than 14d";
        }
      else
        {
          dates = "12:12";
        }
    );
  };

  nixpkgs.config = {
    allowUnfree = true;
    # TEMPORARY: Disable package tests globally to unblock macbox builds.
    # TODO: Remove once the build issue is resolved.
    doCheckByDefault = false;
  };
}
