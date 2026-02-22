{
  pkgs,
  ...
}:
let
  theme = {
    package = pkgs.yaru-theme;
    name = "Yaru-prussiangreen";
  };

  aws-export-profile = pkgs.stdenv.mkDerivation {
    name = "aws-export-profile";
    src = pkgs.fetchFromGitHub {
      owner = "cytopia";
      repo = "aws-export-profile";
      rev = "a08ed774a36e5a7386adf645652a4af7b972e208"; # specific commit/tag
      sha256 = "sha256-hvQzKXHfeyN4qm6kEAG/xuIqmHhL8GKpvn8aE+gTMDE=";
    };
    installPhase = ''
      mkdir -p $out/bin
      cp aws-export-profile $out/bin/aws-export-profile.sh
      chmod +x $out/bin/aws-export-profile.sh
    '';
  };
in
{
  imports = [ ./common.nix ];

  systemd.user = {
    startServices = "sd-switch";

    services = {
      copyq = {
        Unit = {
          Description = "CopyQ clipboard management daemon";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.copyq}/bin/copyq";
          Restart = "on-failure";
          Environment = [ "QT_QPA_PLATFORM=xcb" ];
        };
        Install.WantedBy = [ "sway-session.target" ];
      };

      telegram = {
        Unit = {
          Description = "Telegram Desktop";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.telegram-desktop}/bin/Telegram -startintray";
          Restart = "on-failure";
          Environment = [ "QT_QPA_PLATFORM=xcb" ];
        };
        Install.WantedBy = [ "sway-session.target" ];
      };

      bluetooth-applet = {
        Unit = {
          Description = "Blueman Applet";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.blueman}/bin/blueman-applet";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "sway-session.target" ];
      };

      swaynag-battery = {
        Unit = {
          Description = "Low battery notification";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.swaynag-battery}/bin/swaynag-battery";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "sway-session.target" ];
      };
    };
  };

  dconf = {
    settings = {
      "org/gnome/desktop/interface" = {
        font-name = "Helvetica Neue LT Std";
        monospace-font-name = "Source Code Pro";
        document-font-name = "Cantarell";
      };
    };
  };

  gtk = {
    enable = true;

    inherit theme;
    iconTheme = theme;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 0;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 0;
  };

  # Install packages for user.
  # Search for packages here: https://search.nixos.org/packages
  home = {
    packages = with pkgs; [
      # File Management
      gthumb # Image browser and viewer

      # Networking
      iproute2 # Utilities for controlling TCP/IP networking and traffic control in Linux
      protonvpn-gui # ProtonVPN

      # Media
      freetube # YouTube client

      # Development Tools
      aws-export-profile # AWS profile exporter
      nix-tree # Visualize Nix dependencies

      # Fonts
      cantarell-fonts # Cantarell font family

      # Development Tools
      aws-export-profile # AWS profile exporter
      awscli2 # AWS command-line interface
      nix-tree # Visualize Nix dependencies
      oath-toolkit # OATH one-time password tool

      # Emulators
      fuse-emulator # ZX Spectrum (Z80) emulator

      # Browsers
      firefox # Web browser
      google-chrome # Web browser
    ];

    sessionVariables = {
      LIBGL_ALWAYS_INDIRECT = 1;
      DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
      KPT_FN_RUNTIME = "podman";
    };
  };

  module = {
    avizo.enable = true;
    foot.enable = true;
    fuzzel.enable = true;
    gammastep.enable = true;
    kanshi.enable = true;
    mhalo = {
      enable = true;
      swayKeybinding = "Mod4+Shift+m";
    };
    mpv.enable = true;
    ollama.enable = true;
    opencode.enable = true;
    openra.enable = false;
    sway = {
      enable = true;
      background = "~/.local/share/backgrounds/hannah-grace-dSqWwzrLJaQ-unsplash.jpg";
      swaylock = {
        enable = true;
        settings.indicator-radius = 45;
      };
    };
    waybar = {
      enable = true;
      systemdIntegration.enable = true;
    };
  };
}
