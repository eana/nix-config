{ pkgs, ... }:

{
  nix = {
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

  nixpkgs.config.allowUnfree = true;
}
