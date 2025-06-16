{
  config,
  pkgs,
  inputs,
  ...
}:
let
  inherit (inputs) home-manager;
  inherit (inputs) nix-homebrew;
  inherit (inputs) homebrew-core;
  inherit (inputs) homebrew-cask;
in
{
  time.timeZone = "Europe/Stockholm";

  homebrew = {
    enable = true;
    # casks = [
    #   "google-chrome"
    #   "docker"
    # ];
    # masApps = {
    #   Bitwarden = 1352778147;
    # };
    onActivation.cleanup = "zap";
    taps = builtins.attrNames config.nix-homebrew.taps;
  };

  nix-homebrew = {
    enable = true;
    user = "jonas";

    # autoMigrate = true;

    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
    };
    mutableTaps = false;
  };

  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jonas = {
      imports = [
        ../../home/users/jonas/darwin.nix

        # Common modules
        ../../modules/common/git/default.nix
        ../../modules/common/gpg-agent/default.nix
        ../../modules/common/neovim/default.nix
        ../../modules/common/ollama/default.nix
        ../../modules/common/tmux/default.nix
        ../../modules/common/zsh/default.nix
      ];
      home.packages = [
        pkgs.spotify
      ];
      home.stateVersion = "24.05";
    };
  };

  system = {
    primaryUser = "jonas";

    defaults = {
      dock.autohide = true;
      dock.persistent-apps = [
        "/Applications/Google Chrome.app"
        "/System/Applications/Utilities/Terminal.app"
      ];
      # NSGlobalDomain.AppleInterfaceStyle = "Dark";
    };

    # Set Git commit hash for darwin-version.
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  };

  # Sudo with fingerprint
  security.pam.services.sudo_local.touchIdAuth = true;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs = {
    hostPlatform = "x86_64-darwin";
    config.allowUnfree = true;
  };

  environment = {
    systemPackages = with pkgs; [
      mkalias # Make APFS aliases without going via AppleScript
      home-manager # Nix-based user environment configurator

      jetbrains.idea-community-bin
      m-cli # Swiss-army knife for macOS
      vscode
      zsh-powerlevel10k
    ];

    pathsToLink = [ "/Applications" ]; # For GUI apps
    variables = {
      EDITOR = "nvim";
    };
  };

  nix = {
    settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://cuda-maintainers.cachix.org"
      ];
      trusted-public-keys = [
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
      trusted-users = [
        "root"
        "jonas"
      ];
    };
  };

  system.stateVersion = 6;
}
