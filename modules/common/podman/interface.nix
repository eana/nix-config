{ lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkOption;
in
{
  options.module.podman = {
    enable = mkEnableOption "Podman container engine";

    dockerCompat = mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set DOCKER_HOST to use rootless podman socket for docker CLI compatibility (Linux only).";
    };

    machine = {
      enable = mkOption {
        type = lib.types.bool;
        default = pkgs.stdenv.hostPlatform.isDarwin;
        description = "Enable podman machine (macOS only).";
      };

      memory = mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = 4096;
        description = "Memory in MB for the podman machine.";
      };

      cpus = mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = 2;
        description = "Number of CPUs for the podman machine.";
      };

      diskSize = mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = 50;
        description = "Disk size in GB for the podman machine.";
      };
    };
  };
}
