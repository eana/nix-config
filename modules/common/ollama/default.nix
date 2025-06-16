{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.ollama;
  ollamaPkg = import ./package.nix { inherit lib pkgs; };

in
{
  options.module.ollama = {
    enable = mkEnableOption "Ollama local LLM service";

    package = mkOption {
      type = types.package;
      default = ollamaPkg;
      description = "Customized Ollama package";
    };

    acceleration = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable GPU acceleration support";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.services.ollama = {
      Unit = {
        Description = "Ollama LLM Service";
        After = "network.target";
      };
      Service = {
        ExecStart = "${cfg.package}/bin/ollama serve";
        Restart = "on-failure";
        Environment = lib.optional cfg.acceleration "OLLAMA_ACCELERATION=1";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
