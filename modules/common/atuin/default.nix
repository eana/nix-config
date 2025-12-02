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
  cfg = config.module.atuin;
in
{
  options.module.atuin = {
    client = {
      enable = mkEnableOption "Atuin shell history client";
      package = mkOption {
        type = types.package;
        default = pkgs.atuin;
        description = "The Atuin package to use for the client";
      };
      settings = mkOption {
        type = types.attrs;
        default = { };
        description = "Atuin client configuration settings";
        example = {
          auto_sync = true;
          sync_frequency = "5m";
          sync_address = "http://localhost:8888";
          search_mode = "fuzzy";
        };
      };
    };

    server = {
      enable = mkEnableOption "Atuin shell history server";
      package = mkOption {
        type = types.package;
        default = pkgs.atuin;
        description = "The Atuin package to use for the server";
      };
      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Host address for the Atuin server";
      };
      port = mkOption {
        type = types.port;
        default = 8888;
        description = "Port for the Atuin server";
      };
      openRegistration = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to allow open registration on the server";
      };
      dataDir = mkOption {
        type = types.str;
        default = "%h/.local/share/atuin-server";
        description = "Directory to store the Atuin server database and data (supports systemd specifiers like %h for home)";
      };
      settings = mkOption {
        type = types.attrs;
        default = { };
        description = "Additional Atuin server configuration settings";
      };
    };
  };

  config = lib.mkMerge [
    # Client configuration
    (mkIf cfg.client.enable {
      programs.atuin = {
        enable = true;
        inherit (cfg.client) package;
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
        inherit (cfg.client) settings;
      };
    })

    # Server configuration (as user service)
    (mkIf cfg.server.enable {
      systemd.user.services.atuin-server = {
        Unit = {
          Description = "Atuin shell history server";
          After = [ "network.target" ];
        };

        Service = {
          Type = "simple";
          WorkingDirectory = cfg.server.dataDir;
          ExecStart = "${cfg.server.package}/bin/atuin server start";
          Restart = "on-failure";
          RestartSec = "5s";
          Environment = [
            "ATUIN_HOST=${cfg.server.host}"
            "ATUIN_PORT=${toString cfg.server.port}"
            "ATUIN_OPEN_REGISTRATION=${if cfg.server.openRegistration then "true" else "false"}"
            "ATUIN_DB_URI=sqlite://${cfg.server.dataDir}/atuin.db"
            "ATUIN_CONFIG_DIR=${cfg.server.dataDir}"
          ]
          ++ (lib.mapAttrsToList (name: value: "${name}=${toString value}") cfg.server.settings);
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };

      # Ensure the data directory exists
      home.activation.atuinServerDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ${
          lib.replaceStrings [ "%h" ] [ config.home.homeDirectory ] cfg.server.dataDir
        }
      '';
    })
  ];
}
