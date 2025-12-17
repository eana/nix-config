{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
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
  options.module.ollama = {
    enable = mkEnableOption "Ollama LLM service";

    package = mkOption {
      type = types.package;
      default = pkgs.ollama;
      description = "The Ollama package to use for the LLM service";
      example = lib.literalExpression "pkgs.ollama";
    };

    server = {
      host = mkOption {
        type = types.str;
        default = defaultServerSettings.host;
        description = "Host address to bind the Ollama server to";
      };

      port = mkOption {
        type = types.port;
        default = defaultServerSettings.port;
        description = "Port number for the Ollama server to listen on";
      };

      acceleration = mkOption {
        type = types.nullOr (
          types.either types.bool (
            types.enum [
              "rocm"
              "cuda"
            ]
          )
        );
        default = defaultServerSettings.acceleration;
        description = ''
          Hardware acceleration to use:
          - null: Automatic detection (default)
          - false: Force CPU-only mode
          - "rocm": AMD GPU acceleration
          - "cuda": NVIDIA GPU acceleration
        '';
      };

      environmentVariables = mkOption {
        type = types.attrsOf types.str;
        default = { };
        description = "Environment variables for the Ollama server";
      };

      extraFlags = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Additional command line flags to pass to the Ollama server";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Linux: Use NixOS services.ollama module
    services.ollama = mkIf pkgs.stdenv.isLinux {
      enable = true;
      inherit (cfg.server) host;
      inherit (cfg.server) port;
      inherit (cfg.server) acceleration;
      environmentVariables = mkIf (finalEnvironmentVariables != { }) finalEnvironmentVariables;
    };

    # macOS: Use launchd agent
    launchd.agents.ollama = mkIf pkgs.stdenv.isDarwin {
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
      !pkgs.stdenv.isLinux && !pkgs.stdenv.isDarwin
    ) "Ollama service is only supported on Linux and macOS platforms.";
  };
}
