{ inputs, ... }:
let
  inherit (inputs) homebrew-core;
  inherit (inputs) homebrew-cask;
  inherit (inputs) nikitabobko-tap;
in
{
  homebrew = {
    enable = true;
    casks = [
      # keep-sorted start
      "aerospace"
      "firefox"
      "google-chrome"
      "karabiner-elements"
      "protonvpn"
      "vlc"
      # keep-sorted end
    ];
    masApps = {
      Bitwarden = 1352778147;
    };
    onActivation.cleanup = "zap";
    taps = [
      "homebrew/homebrew-core"
      "homebrew/homebrew-cask"
      {
        name = "nikitabobko/homebrew-tap";
        trusted = true;
      }
    ];
  };

  nix-homebrew = {
    enable = true;
    user = "jonas";

    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "nikitabobko/homebrew-tap" = nikitabobko-tap;
    };
    mutableTaps = false;
    trust.taps = [ "nikitabobko/tap" ];
  };
}
