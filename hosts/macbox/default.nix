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
    casks = [
      "altserver"
      "iterm2"
      "openvpn-connect"
      "podman-desktop"
      "vlc"
      # "firefox"
      # "google-chrome"
      # "spotify"
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

    activationScripts.applications.text =
      let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
      pkgs.lib.mkForce ''
        # Set up system applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
            app_name=$(basename "$src")
            echo "copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
        # Set up home-manager applications.
        cd "${config.users.users.jonas.home}/Applications/Home Manager Apps/"
        find . -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
            app_name=$(basename "$src")
            echo "copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
      '';

    defaults = {
      controlcenter.BatteryShowPercentage = true;
      ActivityMonitor = {
        IconType = 6; # Show CPU history
        OpenMainWindow = true;
        ShowCategory = 101; # All Processes, Hierarchally
        SortColumn = "CPUUsage";
        SortDirection = 0; # Descending
      };
      LaunchServices.LSQuarantine = false;
      NSGlobalDomain = {
        AppleEnableMouseSwipeNavigateWithScrolls = true;
        AppleEnableSwipeNavigateWithScrolls = true;
        AppleFontSmoothing = null;
        AppleICUForce24HourTime = true;
        AppleInterfaceStyle = "Dark";
        AppleInterfaceStyleSwitchesAutomatically = false;
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        ApplePressAndHoldEnabled = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = false;
        AppleShowScrollBars = "WhenScrolling";
        AppleTemperatureUnit = "Celsius";
        InitialKeyRepeat = 12;
        KeyRepeat = 1;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticInlinePredictionEnabled = true;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = true;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        NSScrollAnimationEnabled = true;
        NSTableViewDefaultSizeMode = 3;
        NSWindowShouldDragOnGesture = false;
        _HIHideMenuBar = false;
        "com.apple.keyboard.fnState" = false;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.swipescrolldirection" = true;
      };
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      WindowManager = {
        EnableStandardClickToShowDesktop = false;
        GloballyEnabled = false;
      };
      dock = {
        enable-spring-load-actions-on-all-items = false;
        appswitcher-all-displays = true;
        autohide = false;
        largesize = 16;
        launchanim = true;
        magnification = false;
        mineffect = "scale";
        minimize-to-application = true;
        mru-spaces = false;
        orientation = "bottom";
        persistent-apps = [
          "/Applications/Nix Apps/Spotify.app"
          "/Applications/Nix Apps/Google Chrome.app"
          "/Applications/Nix Apps/Firefox.app"
          "/Applications/Nix Apps/WezTerm.app"
        ];
        persistent-others = null;
        show-process-indicators = true;
        show-recents = false;
        showhidden = true;
        slow-motion-allowed = false;
        tilesize = 43;
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
      };
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = false;
        CreateDesktop = true;
        FXDefaultSearchScope = "SCcf";
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        QuitMenuItem = false;
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = false;
        _FXSortFoldersFirst = true;
      };
      loginwindow = {
        DisableConsoleAccess = true;
        GuestEnabled = false;
      };
      menuExtraClock = {
        IsAnalog = false;
        Show24Hour = true;
        ShowAMPM = false;
        ShowDate = 1;
        ShowDayOfMonth = true;
        ShowDayOfWeek = true;
        ShowSeconds = false;
      };
      screencapture.show-thumbnail = false;
      screensaver.askForPassword = true;
      spaces.spans-displays = false;
      trackpad = {
        ActuationStrength = 0;
        Clicking = true;
        Dragging = false;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = false;
        TrackpadThreeFingerTapGesture = 0;
      };
    };

    # Set Git commit hash for darwin-version.
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  };

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
