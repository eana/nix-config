{
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

  nixpkgs.config.allowUnfree = true;
}
