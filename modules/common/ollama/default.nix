{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    ;
  cfg = config.module.ollama;

  defaultServerSettings = {
    host = "0.0.0.0";
    port = 11434;
    acceleration = null;
  };

  finalEnvironmentVariables =
    cfg.server.environmentVariables
    // lib.optionalAttrs (cfg.server.host != defaultServerSettings.host) {
      OLLAMA_HOST = "${cfg.server.host}:${toString cfg.server.port}";
    };
in
{
  imports = [ ./interface.nix ];

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Linux: Use NixOS services.ollama module
    services.ollama = mkIf pkgs.stdenv.hostPlatform.isLinux {
      enable = true;
      inherit (cfg.server) host;
      inherit (cfg.server) port;
      inherit (cfg.server) acceleration;
      environmentVariables = mkIf (finalEnvironmentVariables != { }) finalEnvironmentVariables;
    };

    # macOS: Use launchd agent
    launchd.agents.ollama = mkIf pkgs.stdenv.hostPlatform.isDarwin {
      enable = true;
      config = {
        Label = "org.nix-community.ollama";
        ProgramArguments = [
          "${cfg.package}/bin/ollama"
          "serve"
        ]
        ++ cfg.server.extraFlags;
        EnvironmentVariables =
          finalEnvironmentVariables
          // {
            OLLAMA_HOST = "${cfg.server.host}:${toString cfg.server.port}";
          }
          // lib.optionalAttrs (cfg.server.acceleration != null) (
            if !cfg.server.acceleration then
              { OLLAMA_ACCELERATION = "cpu"; }
            else if cfg.server.acceleration == "rocm" then
              { OLLAMA_ACCELERATION = "rocm"; }
            else if cfg.server.acceleration == "cuda" then
              { OLLAMA_ACCELERATION = "cuda"; }
            else
              { }
          );
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/ollama.out.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/ollama.err.log";
      };
    };

    # Warning for unsupported platforms
    warnings = lib.optional (
      !pkgs.stdenv.hostPlatform.isLinux && !pkgs.stdenv.hostPlatform.isDarwin
    ) "Ollama service is only supported on Linux and macOS platforms.";
  };
}
