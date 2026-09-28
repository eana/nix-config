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

  # ollama's build hardcodes GGML_METAL=ON for aarch64-darwin, so Metal is not
  # a selectable backend there — there is nothing to turn on. These tune the
  # Metal path for a unified-memory budget instead. Anything set in
  # `server.environmentVariables` overrides them.
  appleSiliconDefaults = {
    # Attention over the Metal kernels instead of the CPU fallback path.
    OLLAMA_FLASH_ATTENTION = "1";
    # Halves KV cache size, buying context length in shared memory.
    OLLAMA_KV_CACHE_TYPE = "q8_0";
    # Metal has no parallel-request support; setting it keeps ollama from
    # logging a warning on every model load.
    OLLAMA_NUM_PARALLEL = "1";
    # One resident model at a time, so a second load evicts instead of
    # pushing the machine into swap.
    OLLAMA_MAX_LOADED_MODELS = "1";
  };

  # NixOS's services.ollama derives OLLAMA_HOST from host/port itself, so the
  # launchd agent is the only side that needs it spelled out.
  darwinEnvironmentVariables =
    appleSiliconDefaults
    // {
      OLLAMA_HOST = "${cfg.server.host}:${toString cfg.server.port}";
    }
    // cfg.server.environmentVariables;

  linuxEnvironmentVariables = cfg.server.environmentVariables;
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
      environmentVariables = linuxEnvironmentVariables;
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
        EnvironmentVariables = darwinEnvironmentVariables;
        RunAtLoad = true;
        KeepAlive = true;
        # Inference is never the foreground task on a laptop; let launchd
        # throttle it against whatever the user is actually doing.
        ProcessType = "Background";
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
