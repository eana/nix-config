{ inputs, ... }:
{
  flake.homeConfigurations.nasbox = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
    modules = [
      ../../hosts/nasbox/default.nix
      { nixpkgs.config.allowUnfree = true; }
      inputs.agenix.homeManagerModules.default
    ];

    extraSpecialArgs = {
      inherit inputs;
      nixvimInput = inputs.nixvim;
    };
  };
}
