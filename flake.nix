{
  description = "Nix flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # disko
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Apple's fonts
    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: {
    formatter.x86_64-linux =
      inputs.nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;

    nixosConfigurations.nixbox = let system = "x86_64-linux";
    in inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./system.nix
        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            users.jonas = {
              imports = [ ./home.nix ];
              home.packages = [ inputs.apple-fonts.packages.${system}.sf-pro ];
            };
          };
        }
      ];
    };
  };

  nixConfig = {
    extra-substituters = "https://cuda-maintainers.cachix.org";
    extra-trusted-public-keys =
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E=";
  };
}
