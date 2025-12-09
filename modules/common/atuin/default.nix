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

  atuinLoginScript = pkgs.writeShellScript "atuin-login" ''
    export PATH="${
      lib.makeBinPath [
        pkgs.coreutils
        pkgs.gnugrep
        pkgs.gnused
      ]
    }:$PATH"

    set -euo pipefail

    CRED_FILE="${cfg.sync.credentialsFile}"
    ATUIN="${cfg.package}/bin/atuin"

    if $ATUIN status &>/dev/null; then
      echo "Atuin: Already logged in."
      exit 0
    fi

    echo "Atuin: Attempting authentication..."

    if [ ! -f "$CRED_FILE" ]; then
      echo "Atuin: Error - Credentials file not found at $CRED_FILE"
      exit 1
    fi

    USERNAME=$(grep "^username:" "$CRED_FILE" | cut -d: -f2- | tr -d '[:space:]')
    PASSWORD=$(grep "^password:" "$CRED_FILE" | cut -d: -f2- | tr -d '[:space:]')
    KEY=$(grep "^key:" "$CRED_FILE" | cut -d: -f2-)

    if [[ -z "$USERNAME" || -z "$PASSWORD" || -z "$KEY" ]]; then
      echo "Atuin: Error - Missing credentials in $CRED_FILE"
      exit 1
    fi

    $ATUIN login --username "$USERNAME" --password "$PASSWORD" --key "$KEY"

    echo "Atuin: Login successful."
  '';

in
{
  options.module.atuin = {
    enable = mkEnableOption "Atuin shell history client";
    package = mkOption {
      type = types.package;
      default = pkgs.atuin;
      description = "The Atuin package to use for the client";
    };
    sync = {
      enable = mkEnableOption "Enable sync with atuin server";
      address = mkOption {
        type = types.str;
        default = "";
        description = "Atuin server address";
      };
      credentialsFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to decrypted secrets file containing atuin credentials.";
      };
    };
    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "Additional Atuin client configuration settings";
    };
  };

  config = mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      inherit (cfg) package;

      flags = [
        "--disable-up-arrow"
        "--disable-ctrl-r"
      ];

      settings = lib.mkMerge [
        cfg.settings
        (mkIf cfg.sync.enable {
          sync_address = cfg.sync.address;
          auto_sync = true;
        })
      ];
    };

    # Linux
    systemd.user.services.atuin-login =
      mkIf (pkgs.stdenv.isLinux && cfg.sync.enable && cfg.sync.credentialsFile != null)
        {
          Unit = {
            Description = "Atuin automatic login/logout service";
            After = [ "network-online.target" ];
            Wants = [ "network-online.target" ];
            ConditionPathExists = cfg.sync.credentialsFile;
          };

          Service = {
            Type = "oneshot";
            RemainAfterExit = true;
            Restart = "on-failure";
            RestartSec = "30s";

            ExecStart = "${atuinLoginScript}";
            ExecStop = "${pkgs.atuin}/bin/atuin logout";
          };

          Install = {
            WantedBy = [ "default.target" ];
          };
        };

    # macOS
    launchd.agents.atuin-login =
      mkIf (pkgs.stdenv.isDarwin && cfg.sync.enable && cfg.sync.credentialsFile != null)
        {
          enable = true;
          config = {
            Label = "org.nix-community.atuin-login";
            ProgramArguments = [ "${atuinLoginScript}" ];
            RunAtLoad = true; # Run immediately when loaded
            KeepAlive = false; # Runs once (like oneshot)

            StandardOutPath = "${config.home.homeDirectory}/Library/Logs/atuin-login.out.log";
            StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/atuin-login.err.log";
          };
        };
  };
}
