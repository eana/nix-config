{
  imports = [
    # keep-sorted start
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

  age.secrets = {
    ssh-hosts = {
      file = ../../secrets/ssh-hosts.age;
      mode = "0400";
      owner = "jonas";
      group = "users";
    };
    atuin = {
      file = ../../secrets/atuin.age;
      mode = "0400";
      owner = "jonas";
      group = "users";
    };
  };

  hardware.nvidiaPrime.enable = true;

  time.timeZone = "Europe/Stockholm";
  console.keyMap = "us";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod.enabled = null;
  };

  module.libvirt = {
    enable = true;
    gui.enable = true;
    platformCpu = "intel";
  };

  system.stateVersion = "24.05";
}
