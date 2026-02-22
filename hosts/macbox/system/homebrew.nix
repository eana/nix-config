{ config, inputs, ... }:
let
  inherit (inputs) homebrew-core;
  inherit (inputs) homebrew-cask;
in
{
  homebrew = {
    enable = true;
    casks = [
      # keep-sorted start
      "firefox"
      "google-chrome"
      "iterm2"
      "podman-desktop"
      "vlc"
      # keep-sorted end
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
