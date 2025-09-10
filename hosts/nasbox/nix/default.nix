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

    gc = {
      automatic = true;
      dates = "12:12";
    };
  };

  nixpkgs.config.allowUnfree = true;
}
