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

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      moduleList = [
        "git"
        "gpg-agent"
        "neovim"
        "ollama"
        "tmux"
        "zsh"
      ];
      homeModules = builtins.listToAttrs (
        map (name: {
          inherit name;
          value = import ./modules/common/${name}/default.nix;
        }) moduleList
      );
    in
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
              cachix
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
              inputs.disko.nixosModules.disko
              inputs.home-manager.nixosModules.home-manager
              inputs.nix-index-database.nixosModules.nix-index
            ];
          };
        };

        darwinConfigurations."macbox" = inputs.nix-darwin.lib.darwinSystem {
          modules = [
            ./hosts/macbox/default.nix
            inputs.home-manager.darwinModules.home-manager
            inputs.nix-homebrew.darwinModules.nix-homebrew
            inputs.nix-index-database.darwinModules.nix-index
            {
              users.users.jonas = {
                name = "jonas";
                home = "/Users/jonas";
              };
            }
          ];

          specialArgs = {
            inherit inputs;
          };
        };

        homeConfigurations = {
          nasbox = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
            modules = [
              ./hosts/nasbox/home-manager/default.nix
            ];
          };
        };

        inherit homeModules;
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
