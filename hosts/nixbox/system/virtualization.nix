{ config, ... }:

{
  programs.nix-ld = {
    enable = true;
    libraries = config.hardware.graphics.extraPackages;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };
}
