{ config, ... }:

{
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  programs.nix-ld = {
    enable = true;
    libraries = config.hardware.graphics.extraPackages;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };
}
