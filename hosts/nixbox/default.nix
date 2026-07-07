{
  imports = [
    # keep-sorted start
    ../shared/default.nix
    ../shared/system/linux.nix
    ./disko.nix
    ./gdm.nix
    ./hardware-configuration.nix
    ./home-manager/default.nix
    ./nix/default.nix
    ./system/audio.nix
    ./system/boot.nix
    ./system/environment.nix
    ./system/hardware.nix
    ./system/networking.nix
    ./system/nvidia.nix
    ./system/packages.nix
    ./system/security.nix
    ./system/services.nix
    ./system/virtualization.nix
    # keep-sorted end

    ../../modules/linux/libvirt/default.nix
  ];

  hardware.nvidiaPrime.enable = true;

  console.keyMap = "us";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod.enabled = null;
  };

  module.libvirt = {
    enable = true;
    user = "jonas";
    gui.enable = true;
    platformCpu = "intel";
  };

  system.stateVersion = "24.05";
}
