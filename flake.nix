{
  description = "Nix flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    disko.url = "github:nix-community/disko";
    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    dev-flake.url = "github:terlar/dev-flake";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      nixbox-arch = "x86_64-linux";
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ nixbox-arch ];

      imports = [ inputs.dev-flake.flakeModule ];

      # Dev configuration
      dev.name = "nixbox";

      # Per-system configuration
      perSystem =
        { config, pkgs, ... }:
        {
          treefmt = import ./dev/treefmt.nix { inherit pkgs; };
          pre-commit = import ./dev/pre-commit.nix;

          packages = {
            pre-commit = config.pre-commit.settings.package;
            pre-commit-install = pkgs.writeShellScriptBin "pre-commit-install" ''
              #!${pkgs.stdenv.shell}
              ${pkgs.pre-commit}/bin/pre-commit install
            '';
          };
        };

      flake = {
        formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
        nixosConfigurations.nixbox = inputs.nixpkgs.lib.nixosSystem {
          system = nixbox-arch;
          modules = [
            ./system.nix
            inputs.disko.nixosModules.disko
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                users.jonas = {
                  imports = [ ./home.nix ];
                  home.packages = [ inputs.apple-fonts.packages.${nixbox-arch}.sf-pro ];
                };
              };
            }
          ];
        };
      };
    };
}
