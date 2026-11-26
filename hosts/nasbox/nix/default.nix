{ pkgs, ... }:

{
  imports = [ ../../../modules/shared/nix-cache.nix ];

  nix = {
    # home-manager on non-NixOS requires an explicit nix.package.
    package = pkgs.nix;
    settings = {
      trusted-users = [
        "root"
      ];
    };
    extraOptions = builtins.readFile ../../../dev/nix.conf;
  };

  nixpkgs.config = {
    allowUnfree = true;
  };
}
