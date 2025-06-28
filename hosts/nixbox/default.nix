{
  imports = [
    ./disko.nix
    ./gdm.nix
    ./hardware-configuration.nix
    ./system/audio.nix
    ./system/boot.nix
    ./system/environment.nix
    ./system/hardware.nix
    ./system/networking.nix
    ./system/nvidia.nix
    ./system/packages.nix
    ./system/services.nix
    ./system/virtualization.nix
    ./home-manager/default.nix
    ./nix/default.nix
  ];

  hardware.nvidiaPrime.enable = true;

  time.timeZone = "Europe/Stockholm";
  console.keyMap = "us";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod.enabled = null;
  };

  system.stateVersion = "24.05";
}
