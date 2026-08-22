{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    ;

  defaultServerSettings = {
    host = "0.0.0.0";
    port = 11434;
    acceleration = null;
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
}
