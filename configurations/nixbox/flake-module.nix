{ eanaLib, inputs, ... }:
{
  flake.nixosConfigurations.nixbox = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ../../hosts/nixbox/default.nix
      inputs.disko.nixosModules.disko
      inputs.agenix.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      inputs.nix-index-database.nixosModules.nix-index
    ];

    specialArgs = {
      inherit inputs;
      lib = eanaLib "x86_64-linux";
    };
  };
}
