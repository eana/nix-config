{
  description = "Nix flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko.url = "github:nix-community/disko";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    };

    dev-flake = {
      url = "github:terlar/dev-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      home-manager,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

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
            # system = "x86_64-linux";
            modules = [
              ./hosts/nixbox/default.nix
              inputs.disko.nixosModules.disko
              inputs.home-manager.nixosModules.home-manager
            ];
          };
        };
        darwinConfigurations."vickys-MacBook-Pro" = nix-darwin.lib.darwinSystem {
          modules = [
            ./hosts/macbox/default.nix
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
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
