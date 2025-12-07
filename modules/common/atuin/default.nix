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

    systemd.user.services.atuin-login = mkIf (cfg.sync.enable && cfg.sync.credentialsFile != null) {
      Unit = {
        Description = "Atuin automatic login/logout service";
        After = [
          "network-online.target"
          "sops-nix.service"
        ];
        Wants = [ "network-online.target" ];
        ConditionPathExists = cfg.sync.credentialsFile;
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "30s";

        ExecStart = pkgs.writeShellScript "atuin-login" ''
          set -euo pipefail

          CRED_FILE="${cfg.sync.credentialsFile}"
          ATUIN="${cfg.package}/bin/atuin"

          # Check if already logged in
          if $ATUIN account status &>/dev/null; then
            echo "Atuin: Already logged in."
            $ATUIN sync
            exit 0
          fi

          echo "Atuin: Attempting authentication..."

          # Extract credentials using grep for better readability
          USERNAME=$(grep "^username:" "$CRED_FILE" | cut -d: -f2- | tr -d '[:space:]')
          PASSWORD=$(grep "^password:" "$CRED_FILE" | cut -d: -f2- | tr -d '[:space:]')
          KEY=$(grep "^key:" "$CRED_FILE" | cut -d: -f2- | tr -d '[:space:]')

          if [[ -z "$USERNAME" || -z "$PASSWORD" || -z "$KEY" ]]; then
            echo "Atuin: Error - Missing credentials in $CRED_FILE"
            exit 1
          fi

          # Login and sync
          $ATUIN login --username "$USERNAME" --password "$PASSWORD" --key "$KEY"
          echo "Atuin: Login successful."
          $ATUIN sync
        '';

        ExecStop = "${cfg.package}/bin/atuin logout";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
