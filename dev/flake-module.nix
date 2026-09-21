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
      // pkgs.lib.optionalAttrs (system == "aarch64-darwin") {
        macbox = self.darwinConfigurations.macbox.system;
      };

      # flake-parts' `formatter.<system>` is a package output group, so
      # `nix run .#formatter` cannot resolve it (nix run only accepts
      # apps/packages output groups). Export it as an app instead.
      apps.formatter = {
        type = "app";
        program = "${config.treefmt.build.wrapper}/bin/treefmt";
      };

      devshells.default = {
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
          ++ [ config.packages.version-check ];
        commands = [
          {
            name = "repl";
            help = "nix repl with full flake context pre-loaded";
            command = "nix repl --file ${toString ./repl.nix}";
          }
        ];
      };
    };
}
