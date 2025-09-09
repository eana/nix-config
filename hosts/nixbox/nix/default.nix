{
  nix = {
    settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://cuda-maintainers.cachix.org"
      ];

      trusted-public-keys = [
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];

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
