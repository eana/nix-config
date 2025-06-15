{
  description = "Nix flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    disko.url = "github:nix-community/disko";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    };

    dev-flake = {
      url = "github:terlar/dev-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
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

          devshells.default = {
            packages = with pkgs; [
              deadnix
              statix
            ];
          };
        };

      flake = {
        formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;

        nixosConfigurations.nixbox = inputs.nixpkgs.lib.nixosSystem {
          system = nixbox-arch;
          modules = [
            ./hosts/nixbox/default.nix
            inputs.disko.nixosModules.disko
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.jonas = {
                  imports = [
                    ./home/users/jonas/default.nix

                    # Linux-specific modules
                    ./modules/avizo/default.nix
                    ./modules/foot/default.nix
                    ./modules/fuzzel/default.nix
                    ./modules/gammastep/default.nix
                    ./modules/git/default.nix
                    ./modules/gpg-agent/default.nix
                    ./modules/kanshi/default.nix
                    ./modules/mhalo/default.nix
                    ./modules/neovim/default.nix
                    ./modules/ollama/default.nix
                    ./modules/openra/default.nix
                    ./modules/sway/default.nix
                    ./modules/tmux/default.nix
                    ./modules/waybar/default.nix
                    ./modules/zsh/default.nix
                  ];
                };
              };
            }
          ];
        };
      };
    };

  nixConfig = {
    extra-substituters = "https://cuda-maintainers.cachix.org";
    extra-trusted-public-keys = "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E=";
  };
}
