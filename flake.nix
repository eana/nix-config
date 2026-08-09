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
    inputs@{ flake-parts, ... }:
    let
      # Only cross-platform (common/) modules are exported as homeModules.
      # Linux-specific modules (modules/linux/) are consumed directly by host
      # configurations and are not suitable for standalone home-manager use.
      moduleList = [
        # keep-sorted start
        "git"
        "gpg-agent"
        "nixvim"
        "ollama"
        "opencode"
        "podman"
        "tmux"
        "zsh"
        # keep-sorted end
      ];
      homeModules = builtins.listToAttrs (
        map (name: {
          inherit name;
          value = import ./modules/common/${name};
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
        {
          config,
          pkgs,
          system,
          ...
        }:
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
          pre-commit = import ./dev/pre-commit.nix { inherit pkgs; };

          packages = {
            agenix = inputs.agenix.packages.${system}.default;
            pre-commit = config.pre-commit.settings.package;
            pre-commit-install = pkgs.writeShellScriptBin "pre-commit-install" ''
              #!${pkgs.runtimeShell}
              ${pkgs.pre-commit}/bin/pre-commit install
            '';
          };

          devshells.default = {
            packages = with pkgs; [
              cachix
              deadnix
              nixfmt
              statix
            ];
          };
        };

      flake = {
        inherit homeModules;

        nixosConfigurations."nixbox" = inputs.nixpkgs.lib.nixosSystem {
          modules = [
            ./hosts/nixbox/default.nix
            inputs.disko.nixosModules.disko
            inputs.agenix.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            inputs.nix-index-database.nixosModules.nix-index
            # HACK: yaru-theme was removed from nixpkgs unstable (Jul 2026, commit
            # 3991532) because gtk-engine-murrine (GTK2) was removed from nixpkgs.
            # Upstream ubuntu/yaru already dropped GTK2 in v26.10.1 — the removal
            # was overly aggressive. Fix merged to nixpkgs master (PR #547796,
            # Aug 2026) but not yet propagated to nixos-unstable.
            # TODO: Remove this module once pkgs.yaru-theme is available in the
            # tracked nixpkgs rev (check: nix eval nixpkgs#yaru-theme.version).
            {
              nixpkgs.overlays = [
                (final: _: {
                  yaru-theme = final.stdenv.mkDerivation {
                    pname = "yaru";
                    version = "26.10.1";
                    src = final.fetchFromGitHub {
                      owner = "ubuntu";
                      repo = "yaru";
                      rev = "50ea18cba78c652e9a5682ec375cbd609dc8aca6";
                      hash = "sha256-zbXFHEW83u4WAgc5u94rRT0bLgvtii5V+503aOfF9HU=";
                    };
                    nativeBuildInputs = with final; [
                      glib
                      meson
                      ninja
                      pkg-config
                      python3
                      sassc
                    ];
                    buildInputs = with final; [
                      gnome-themes-extra
                      gtk3
                    ];
                    propagatedBuildInputs = with final; [
                      hicolor-icon-theme
                      humanity-icon-theme
                    ];
                    dontDropIconThemeCache = true;
                    postPatch = "patchShebangs .";
                    meta = with final.lib; {
                      description = "Ubuntu community theme 'yaru' - default Ubuntu theme since 18.10";
                      homepage = "https://github.com/ubuntu/yaru";
                      license = with licenses; [
                        cc-by-sa-40
                        gpl3Plus
                        lgpl21Only
                        lgpl3Only
                      ];
                      platforms = platforms.linux;
                    };
                  };
                })
              ];
            }
          ];

          specialArgs = { inherit inputs; };
        };

        darwinConfigurations."macbox" = inputs.nix-darwin.lib.darwinSystem {
          pkgs = import inputs.nixpkgs-darwin {
            system = "x86_64-darwin";
            config.allowUnfree = true;
            # HACK: typst Haskell library 0.8.0.2 has 21 failing tests on
            # x86_64-darwin in nixos-26.05. Tests pass on Linux but fail on
            # macOS due to platform-specific rendering differences. No upstream
            # fix available in nixos-26.05 branch as of 2026-08-08.
            # TODO: Remove once nixos-26.05 ships a fixed typst Haskell package
            # or when nixpkgs-darwin is updated to a rev where tests pass.
            overlays = [
              (_: prev: {
                haskellPackages = prev.haskellPackages.override {
                  overrides = _: hprev: {
                    typst = prev.haskell.lib.dontCheck hprev.typst;
                  };
                };
              })
            ];
          };

          modules = [
            ./hosts/macbox/default.nix
            inputs.agenix.nixosModules.default
            inputs.home-manager.darwinModules.home-manager
            inputs.nix-homebrew.darwinModules.nix-homebrew
            {
              users.users.jonas = {
                name = "jonas";
                home = "/Users/jonas";
              };
            }
          ];

          specialArgs = { inherit inputs; };
        };

        homeConfigurations."nasbox" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          modules = [
            ./hosts/nasbox/default.nix
            { nixpkgs.config.allowUnfree = true; }
          ];

          extraSpecialArgs = {
            inherit inputs;
            nixvimInput = inputs.nixvim;
          };
        };
      };
    };

  nixConfig = {
    extra-substituters = "https://cache.nixos.org https://eana.cachix.org https://cuda-maintainers.cachix.org https://nix-community.cachix.org";
    extra-trusted-public-keys = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= eana.cachix.org-1:3sJHATrL9zjGFGZwAXpECSMR+Ql5k02GgdxfJyzHi84= cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
  };
}
