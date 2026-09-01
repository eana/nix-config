{
  description = "Nix flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # 26.05 is the last nixpkgs release supporting x86_64-darwin.
    # macbox is x86_64-darwin, so this pin is required.
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixos-26.05";

    dev-flake = {
      url = "github:terlar/dev-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    disko.url = "github:nix-community/disko";

    gsd = {
      url = "github:neosam/gsd-flake";
      # Follow the darwin (26.05) nixpkgs: unstable (26.11) dropped
      # x86_64-darwin, and macbox must build the gsd package there.
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim.url = "github:nix-community/nixvim";

    nixvim-darwin = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
      inputs.flake-parts.follows = "flake-parts";
    };

    # Intentionally tracking unstable for nixbox (linux). macbox overrides
    # its pkgs via home-manager.useGlobalPkgs + extra arguments, so HM
    # version is decoupled from the nixpkgs used for packages.
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
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      ...
    }:
    let
      eana = import ./lib.nix { lib = inputs.nixpkgs.lib; };
      eanaLib =
        system:
        (if system == "x86_64-darwin" then inputs.nixpkgs-darwin.lib else inputs.nixpkgs.lib).extend (
          _: _: { inherit eana; }
        );
      homeModules = eana.modulesFromDir ./modules/common;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
      ];

      imports = [
        inputs.dev-flake.flakeModule
        ./configurations/macbox/flake-module.nix
        ./configurations/nasbox/flake-module.nix
        ./configurations/nixbox/flake-module.nix
      ];

      _module.args.eanaLib = eanaLib;

      # Dev configuration
      dev.name = "devbox";

      # Per-system configuration
      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        let
          version-check = pkgs.writeShellScriptBin "version-check" ''
            exec ${pkgs.python3}/bin/python3 ${./dev/version-check.py} "$@"
          '';
        in
        {
          # Must use _module.args.pkgs (not a let binding) so submodules
          # like dev-flake's devshell resolve pkgs through the module
          # system. No reference to the parameter pkgs — import fresh
          # for both branches to avoid circularity.
          _module.args.pkgs =
            import (if system == "x86_64-darwin" then inputs.nixpkgs-darwin else inputs.nixpkgs)
              {
                inherit system;
                config.allowUnfree = true;
              };

          treefmt = import ./dev/treefmt.nix { inherit pkgs; };
          pre-commit = import ./dev/pre-commit.nix { inherit pkgs version-check; };

          packages = {
            agenix = pkgs.callPackage "${inputs.agenix}/pkgs/agenix.nix" { };
            pre-commit = config.pre-commit.settings.package;
            pre-commit-install = pkgs.writeShellScriptBin "pre-commit-install" ''
              #!${pkgs.runtimeShell}
              ${pkgs.pre-commit}/bin/pre-commit install --hook-type pre-commit --hook-type pre-push
            '';
            inherit version-check;
          }
          // pkgs.lib.optionalAttrs (system == "x86_64-linux") {
            nasbox = self.homeConfigurations.nasbox.activationPackage;
            nixbox = self.nixosConfigurations.nixbox.config.system.build.toplevel;
          }
          // pkgs.lib.optionalAttrs (system == "x86_64-darwin") {
            macbox = self.darwinConfigurations.macbox.system;
          };

          devshells.default = {
            env = [
              {
                name = "NIX_USER_CONF_FILES";
                value = toString ./dev/nix.conf;
              }
            ];
            packages =
              (with pkgs; [
                cachix
                deadnix
                nixfmt
                nix-prefetch-github
                python3
                statix
              ])
              ++ [ config.packages.version-check ];
            commands = [
              {
                name = "repl";
                help = "nix repl with full flake context pre-loaded";
                command = "nix repl --file ${toString ./.}/dev/repl.nix";
              }
            ];
          };
        };

      flake = {
        inherit homeModules;
      };
    };

  nixConfig = {
    extra-substituters = "https://cache.nixos.org https://eana.cachix.org https://cuda-maintainers.cachix.org https://nix-community.cachix.org";
    extra-trusted-public-keys = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= eana.cachix.org-1:3sJHATrL9zjGFGZwAXpECSMR+Ql5k02GgdxfJyzHi84= cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
  };
}
