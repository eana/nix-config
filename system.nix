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
    systemPackages = with pkgs; [ sway curl gparted blueman ];
    variables = {
      EDITOR = "nvim";
      MOZ_ENABLE_WAYLAND = "1";
    };
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.05";
}
