{ eanaLib, inputs, ... }:
let
  # HACK: atuin e2e test hangs on unsandboxed darwin builds. Fixed upstream in
  # NixOS/nixpkgs 34f4a531e8fb (PR #574509), not yet in the pinned channel.
  # TODO: remove once the pinned nixpkgs contains 34f4a531e8fb.
  workaroundForAtuinDarwinCheck = _: prev: {
    atuin = prev.atuin.overrideAttrs (_: {
      doCheck = false;
    });
  };
in
{
  flake.darwinConfigurations.macbox = inputs.nix-darwin.lib.darwinSystem {
    pkgs = import inputs.nixpkgs {
      system = "aarch64-darwin";
      config.allowUnfree = true;
      overlays = [ workaroundForAtuinDarwinCheck ];
    };

    modules = [
      ../../hosts/macbox/default.nix
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

    specialArgs = {
      inherit inputs;
      lib = eanaLib "aarch64-darwin";
    };
  };
}
