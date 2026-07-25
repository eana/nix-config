{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.module.podman;
in
{
  options.module.podman = {
    enable = lib.mkEnableOption "Podman container engine";

    dockerCompat = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set DOCKER_HOST to use rootless podman socket for docker CLI compatibility (Linux only).";
    };

    machine = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = pkgs.stdenv.hostPlatform.isDarwin;
        description = "Enable podman machine (macOS only).";
      };

      memory = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = 4096;
        description = "Memory in MB for the podman machine.";
      };

      cpus = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = 2;
        description = "Number of CPUs for the podman machine.";
      };

      diskSize = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = 50;
        description = "Disk size in GB for the podman machine.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.podman = {
      enable = true;
    }
    // lib.optionalAttrs (cfg.machine.enable && pkgs.stdenv.hostPlatform.isDarwin) {
      useDefaultMachine = false;
      machines.default = {
        autoStart = true;
        memory = cfg.machine.memory;
        cpus = cfg.machine.cpus;
        diskSize = cfg.machine.diskSize;
        volumes = [
          "/Users:/Users"
          "/private:/private"
          "/var/folders:/var/folders"
        ];
      };
    };

    home.shellAliases = {
      docker = "podman";
      docker-compose = "podman-compose";
    };

    home.sessionVariables = lib.mkIf (cfg.dockerCompat && pkgs.stdenv.hostPlatform.isLinux) {
      DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
    };

    systemd.user.sockets.podman = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      wantedBy = {
        "sockets.target" = true;
      };
    };
  };
}
