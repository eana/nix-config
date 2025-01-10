{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ./disko.nix ];

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  hardware = {
    bluetooth = {
      enable = true;
      settings = { General = { Enable = "Source,Sink,Media,Socket"; }; };
    };
    enableAllFirmware = true;
    graphics.enable = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "btrfs" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "nixbox";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Stockholm";
  console.keyMap = "us";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod.enabled = null;
  };

  services = {
    blueman.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
    xserver.enable = true;
    xserver.displayManager.gdm.enable = true;
    xserver.displayManager.gdm.wayland = true;
    printing.enable = true;
    libinput.enable = true;
    dbus.enable = true;
    openssh.enable = true;
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      font-awesome
      meslo-lgs-nf
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.jetbrains-mono
      nerd-fonts.space-mono
      powerline-fonts
      powerline-symbols
      source-code-pro
    ];
  };

  users.users.jonas = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  # Use zsh as your default shell.
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  programs.sway.enable = true;
  programs.ssh.startAgent = true;

  environment = {
    systemPackages = with pkgs; [
      # Browsers
      firefox # A free and open-source web browser developed by Mozilla
      google-chrome # A fast, secure, and free web browser built for the modern web by Google

      # Terminal Emulators
      foot # A fast, lightweight and minimalistic Wayland terminal emulator

      # Utilities
      blueman # A GTK+ Bluetooth manager
      curl # A command-line tool for transferring data with URLs
      dive # A tool for exploring a Docker image, layer contents, and discovering ways to shrink the size of your Docker/OCI image
      docker-compose # A tool for defining and running multi-container Docker applications
      gparted # A free partition editor for graphically managing disk partitions
      podman-tui # A terminal user interface for managing Podman containers

      # IDEs
      jetbrains.idea-community-bin # The free and open-source edition of IntelliJ IDEA, an IDE for Java development
      vscode # Visual Studio Code, a source-code editor developed by Microsoft

      # Window Managers
      sway # A tiling Wayland compositor and a drop-in replacement for the i3 window manager for X11

      # Shells
      zsh-powerlevel10k # A theme for Zsh that emphasizes speed, flexibility, and out-of-the-box experience
    ];
    variables = {
      EDITOR = "nvim";
      MOZ_ENABLE_WAYLAND = "1";
    };
  };

  programs.nix-ld = {
    enable = true;
    libraries = config.hardware.graphics.extraPackages;
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.05";
}
