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
    config.allowUnfree = true;
  };
}
