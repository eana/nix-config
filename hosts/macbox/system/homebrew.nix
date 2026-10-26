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
      "markedit"
      "protonvpn"
      "vlc"
      "xnviewmp"
      # keep-sorted end
    ];
    masApps = {
      Bitwarden = 1352778147;
    };
    # HACK: zap needs Full Disk Access in the deleting process, but nix-darwin
    # runs `sudo --user=jonas ... brew bundle` from the root activation script,
    # and nix-installed apps (ad-hoc signed, rebuilt on every switch) cannot hold
    # a durable FDA grant. Chromium/Firefox zap stanzas glob FDA-gated paths,
    # raise EPERM, and abort the uninstall mid-way, leaving Caskroom receipts
    # behind plus a misleading "enable Full Disk Access" hint (brew's probe path
    # ~/Library/Application Support/com.apple.TCC does not exist on macOS 27).
    # "uninstall" removes the app bundle and receipt but keeps user data.
    # TODO: restore "zap" if nix-darwin ever runs brew outside the root chain.
    onActivation.cleanup = "uninstall";
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
