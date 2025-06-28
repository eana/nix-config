{
  description = "Nix flake configuration";

  inputs = {
    dev-flake = {
      url = "github:terlar/dev-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    disko.url = "github:nix-community/disko";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{
      self,
      disko,
      home-manager,
      homebrew-cask,
      homebrew-core,
      nix-darwin,
      nix-homebrew,
      nix-index-database,
      flake-parts,
      nixpkgs,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
      ];

      imports = [ inputs.dev-flake.flakeModule ];

      # Dev configuration
      dev.name = "devbox";

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

          devshells.default = {
            packages = with pkgs; [
              deadnix
              statix
            ];
          };
        };

      flake = {
        nixosConfigurations = {
          nixbox = inputs.nixpkgs.lib.nixosSystem {
            modules = [
              ./hosts/nixbox/default.nix
              disko.nixosModules.disko
              home-manager.nixosModules.home-manager
              nix-index-database.nixosModules.nix-index
            ];
          };
        };
        darwinConfigurations."macbox" = nix-darwin.lib.darwinSystem {
          modules = [
            ./hosts/macbox/default.nix
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            nix-index-database.darwinModules.nix-index
            {
              users.users.jonas = {
                name = "jonas";
                home = "/Users/jonas";
              };
            }
          ];

          specialArgs = {
            inherit self;
            inherit inputs;
            inherit homebrew-core;
            inherit homebrew-cask;
          };
        };
      };
    };

  nixConfig = {
    extra-substituters = [
      "https://cuda-maintainers.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
