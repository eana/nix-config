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

  # HACK: nixpkgs swift ships only .tbd stubs, no macOS Swift runtime dylibs
  # (NixOS/nixpkgs#557896), so Telegram's swift-stdlib-tool bundling step dies
  # with "Couldn't discover Swift library directories". Skip the copy and let
  # the app use the runtime macOS provides.
  # https://github.com/NixOS/nixpkgs/pull/586511
  # TODO: remove once the pinned nixpkgs builds telegram-desktop on darwin
  # without an overlay.
  workaroundForTelegramDarwinSwiftRuntime = _: prev: {
    telegram-desktop = prev.telegram-desktop.override {
      unwrapped = prev.telegram-desktop.unwrapped.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace Telegram/cmake/telegram_apple_swift_runtime.cmake \
            --replace-fail 'COMMAND "''${swift_bin_dir}/swift-stdlib-tool"' 'COMMAND true'
        '';
      });
    };
  };
in
{
  flake.darwinConfigurations.macbox = inputs.nix-darwin.lib.darwinSystem {
    pkgs = import inputs.nixpkgs {
      system = "aarch64-darwin";
      config.allowUnfree = true;
      overlays = [
        workaroundForAtuinDarwinCheck
        workaroundForTelegramDarwinSwiftRuntime
      ];
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
