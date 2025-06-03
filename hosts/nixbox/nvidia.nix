{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.hardware.nvidiaPrime;
in
{
  options.hardware.nvidiaPrime = {
    enable = mkEnableOption "NVIDIA Prime setup with Intel and NVIDIA GPU";
  };

  config = mkIf cfg.enable {
    hardware.nvidia = {
      open = false;
      prime = {
        # ❯ nix-shell -p pciutils --run "lspci -nn | grep -E 'VGA|3D'"
        # 00:02.0 VGA compatible controller [0300]: Intel Corporation HD Graphics 530 [8086:191b] (rev 06)
        # 01:00.0 3D controller [0302]: NVIDIA Corporation GM107GLM [Quadro M1000M] [10de:13b1] (rev a2)
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
      powerManagement.enable = true;
      modesetting.enable = true;
    };

    services.xserver.videoDrivers = [ "nvidia" ];
    boot.kernelPackages = pkgs.linuxPackages_6_14;
  };
}
