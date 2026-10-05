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
  imports = [ ./interface.nix ];

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

    home = {
      packages = [ pkgs.podman-compose ];

      shellAliases = {
        docker = "podman";
        docker-compose = "podman-compose";
      };

      sessionVariables = lib.mkIf (cfg.dockerCompat && pkgs.stdenv.hostPlatform.isLinux) {
        DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
      };
    };

    systemd.user.sockets.podman = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      wantedBy = {
        "sockets.target" = true;
      };
    };
  };
}
