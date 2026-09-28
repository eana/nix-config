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
    host = "127.0.0.1";
    port = 11434;
  };
in
{
  options.module.ollama = {
    enable = mkEnableOption "Ollama LLM service";

    package = mkOption {
      type = types.package;
      default = pkgs.ollama;
      description = ''
        The Ollama package to use for the LLM service.

        The package selects the compiled-in runner, so this is where hardware
        acceleration is chosen:

        - `pkgs.ollama`: autodetect. On Linux this follows
          `nixpkgs.config.{rocm,cuda}Support`; on aarch64-darwin it is Metal,
          which ollama's build always enables for Apple Silicon.
        - `pkgs.ollama-cpu`: force CPU-only.
        - `pkgs.ollama-rocm`: AMD GPUs.
        - `pkgs.ollama-cuda`: NVIDIA GPUs.
        - `pkgs.ollama-vulkan`: any Vulkan-capable GPU.
      '';
      example = lib.literalExpression "pkgs.ollama-rocm";
    };

    server = {
      host = mkOption {
        type = types.str;
        default = defaultServerSettings.host;
        description = ''
          Host address to bind the Ollama server to.

          The Ollama API is unauthenticated, so anything wider than
          `127.0.0.1` exposes model inference to every host on the network.
        '';
      };

      port = mkOption {
        type = types.port;
        default = defaultServerSettings.port;
        description = "Port number for the Ollama server to listen on";
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
