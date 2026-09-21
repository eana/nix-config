{ eanaLib, inputs, ... }:
{
  flake.darwinConfigurations.macbox = inputs.nix-darwin.lib.darwinSystem {
    pkgs = import inputs.nixpkgs {
      system = "aarch64-darwin";
      config.allowUnfree = true;
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
      lib = eanaLib "aarch64-darwin";
    };
  };
}
