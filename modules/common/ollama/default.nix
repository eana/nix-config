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

  defaultSettings = {
    host = "0.0.0.0";
    port = 11434;
    acceleration = null;
    environmentVariables = { };
  };

in
{
  options.module.ollama = {
    enable = mkEnableOption "Ollama LLM service";

    package = mkOption {
      type = types.package;
      default = ollamaPkg;
      description = "Customized Ollama package";
      example = lib.literalExpression "pkgs.ollama";
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
      default = defaultSettings.acceleration;
      description = ''
        Hardware acceleration to use:
        - null: Automatic detection (default)
        - false: Force CPU-only mode
        - "rocm": AMD GPU acceleration
        - "cuda": NVIDIA GPU acceleration
      '';
    };

    host = mkOption {
      type = types.str;
      default = defaultSettings.host;
      description = "Host address to bind to";
    };

    port = mkOption {
      type = types.port;
      default = defaultSettings.port;
      description = "Port number to listen on";
    };

    environmentVariables = mkOption {
      type = types.attrsOf types.str;
      default = defaultSettings.environmentVariables;
      description = "Environment variables for Ollama";
    };

    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Additional command line flags to pass to Ollama";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    services.ollama = {
      enable = true;
      inherit (cfg) host port acceleration;
      environmentVariables = lib.mkIf (cfg.environmentVariables != { }) cfg.environmentVariables;
    };
  };
}
