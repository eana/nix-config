{ eanaLib, inputs, ... }:
{
  flake.darwinConfigurations.macbox = inputs.nix-darwin.lib.darwinSystem {
    pkgs = import inputs.nixpkgs-darwin {
      system = "x86_64-darwin";
      config.allowUnfree = true;
      # HACK: typst Haskell library 0.8.0.2 has 21 failing tests on
      # x86_64-darwin in nixos-26.05. Tests pass on Linux but fail on
      # macOS due to platform-specific rendering differences. No upstream
      # fix available in nixos-26.05 branch as of 2026-08-08.
      # TODO: Remove once nixos-26.05 ships a fixed typst Haskell package
      # or when nixpkgs-darwin is updated to a rev where tests pass.
      overlays = [
        (_: prev: {
          haskellPackages = prev.haskellPackages.override {
            overrides = _: hprev: {
              typst = prev.haskell.lib.dontCheck hprev.typst;
            };
          };
        })
      ];
    };

    modules = [
      ../../hosts/macbox/default.nix
      inputs.agenix.nixosModules.default
      inputs.home-manager.darwinModules.home-manager
      inputs.nix-homebrew.darwinModules.nix-homebrew
      {
        users.users.jonas = {
          name = "jonas";
          home = "/Users/jonas";
        };
      }
    ];

    specialArgs = {
      inherit inputs;
      lib = eanaLib "x86_64-darwin";
    };
  };
}
