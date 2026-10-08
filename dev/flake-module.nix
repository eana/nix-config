{ self, inputs, ... }:
{
  imports = [ inputs.dev-flake.flakeModule ];

  # Dev configuration
  dev.name = "devbox";

  perSystem =
    {
      config,
      pkgs,
      system,
      ...
    }:
    let
      version-check = pkgs.writeShellScriptBin "version-check" ''
        exec ${pkgs.python3}/bin/python3 ${./version-check.py} "$@"
      '';
      repo-wiki-index = pkgs.writeShellScriptBin "repo-wiki-index" ''
        exec ${repo-wiki-python}/bin/python3 ${./repo-wiki-index.py} "$@"
      '';
      repo-wiki-query = pkgs.writeShellScriptBin "repo-wiki-query" ''
        exec ${repo-wiki-python}/bin/python3 ${./repo-wiki-query.py} "$@"
      '';
      repo-wiki-python = pkgs.python3.withPackages (
        ps: with ps; [
          numpy
          requests
          tree-sitter
          tree-sitter-language-pack
        ]
      );
    in
    {
      # Must use _module.args.pkgs (not a let binding) so submodules
      # like dev-flake's devshell resolve pkgs through the module
      # system. No reference to the parameter pkgs — import fresh.
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      treefmt = import ./treefmt.nix { inherit pkgs; };
      pre-commit = import ./pre-commit.nix { inherit pkgs version-check; };

      # The flake only supports x86_64-linux and aarch64-darwin, so the
      # linux hosts and the darwin host are mutually exclusive per system.
      packages = {
        agenix = pkgs.callPackage "${inputs.agenix}/pkgs/agenix.nix" { };
        pre-commit = config.pre-commit.settings.package;
        pre-commit-install = pkgs.writeShellScriptBin "pre-commit-install" ''
          #!${pkgs.runtimeShell}
          ${pkgs.prek}/bin/prek install -f --hook-type pre-commit --hook-type pre-push
        '';
        inherit version-check repo-wiki-index repo-wiki-query;
      }
      // (
        if system == "x86_64-linux" then
          {
            nasbox = self.homeConfigurations.nasbox.activationPackage;
            nixbox = self.nixosConfigurations.nixbox.config.system.build.toplevel;
          }
        else
          {
            macbox = self.darwinConfigurations.macbox.system;
          }
      );

      # flake-parts' `formatter.<system>` is a package output group, so
      # `nix run .#formatter` cannot resolve it (nix run only accepts
      # apps/packages output groups). Export it as an app instead.
      apps.formatter = {
        type = "app";
        program = "${config.treefmt.build.wrapper}/bin/treefmt";
      };

      devshells.default = {
        devshell.startup.pre-commit-install.text = pkgs.lib.mkForce (
          pkgs.lib.replaceStrings [ " install -c " ] [ " install -f -c " ]
            config.pre-commit.installationScript
        );
        env = [
          {
            name = "NIX_USER_CONF_FILES";
            value = toString ./nix.conf;
          }
        ];
        packages =
          (with pkgs; [
            deadnix
            nixfmt
            nix-prefetch-github
            python3
            statix
          ])
          ++ pkgs.lib.optionals (system == "x86_64-linux") [ pkgs.cachix ]
          ++ [
            config.packages.version-check
            config.packages.repo-wiki-index
            config.packages.repo-wiki-query
          ];
        commands = [
          {
            name = "repl";
            help = "nix repl with full flake context pre-loaded";
            command = "nix repl --file ${toString ./repl.nix}";
          }
          {
            package = pkgs.writeShellScriptBin "pre-commit" ''
              exec ${pkgs.prek}/bin/prek "$@"
            '';
            help = "Drop-in pre-commit alias that runs prek";
          }
        ];
      };
    };
}
