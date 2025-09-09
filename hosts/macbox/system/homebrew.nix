{ config, inputs, ... }:
let
  inherit (inputs) homebrew-core;
  inherit (inputs) homebrew-cask;
in
{
  homebrew = {
    enable = true;
    casks = [
      "iterm2"
      "openvpn-connect"
      "podman-desktop"
      "vlc"
    ];
    # masApps = {
    #   Bitwarden = 1352778147;
    # };
    onActivation.cleanup = "zap";
    taps = builtins.attrNames config.nix-homebrew.taps;
  };

  nix-homebrew = {
    enable = true;
    user = "jonas";

    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
    };
    mutableTaps = false;
  };
}
