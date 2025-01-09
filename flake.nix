{
  description = "Nix flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # disko
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, disko, }: {
    nixosConfigurations.nixbox = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./system.nix
        home-manager.nixosModules.home-manager
        ({ config, lib, pkgs, ... }: {
          home-manager.users.jonas =
            import ./home.nix { inherit pkgs lib config; };
        })
        disko.nixosModules.disko
      ];
    };
  };

  # nixConfig = {
  #   extra-substituters = "https://cuda-maintainers.cachix.org";
  #   extra-trusted-public-keys = "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E=";
  # };
}
