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
  # Explicitly define paths for needed tools to avoid Exit Code 127 errors
  sed = "${pkgs.gnused}/bin/sed";
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

      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;

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

    # Systemd One-Shot Service for Login/Logout
    systemd.user.services.atuin-login = mkIf (cfg.sync.enable && cfg.sync.credentialsFile != null) {
      Unit = {
        Description = "Atuin automatic login/logout service";
        # Wait for network and secrets to be online
        After = [
          "network-online.target"
          "sops-nix.service"
        ];
        Wants = [ "network-online.target" ];
        ConditionPathExists = cfg.sync.credentialsFile;
      };

      Service = {
        Type = "oneshot";
        # Crucial for ExecStop: Keeps the service 'active' after login
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "30s";

        # --- ExecStart (The Login Logic) ---
        ExecStart =
          let
            atuinBin = "${cfg.package}/bin/atuin";
            script = pkgs.writeShellScript "atuin-login-script" ''
              set -e
              CRED_FILE="${cfg.sync.credentialsFile}"

              # 1. Check if already logged in. If so, exit successfully.
              if ${atuinBin} account status &>/dev/null; then
                echo "Atuin: Already logged in. Exiting."
                ${atuinBin} sync # Optionally trigger a sync before exiting
                exit 0
              fi

              echo "Atuin: Not logged in. Attempting authentication..."

              # 2. Check for credentials file existence only if login failed.
              if [ ! -f "$CRED_FILE" ]; then
                 echo "Atuin: Error - Credentials file not found at $CRED_FILE"
                 exit 1
              fi

              # 3. Safely extract credentials
              USERNAME=$(${sed} -n 's/^username: //p' "$CRED_FILE")
              PASSWORD=$(${sed} -n 's/^password: //p' "$CRED_FILE")
              KEY=$(${sed} -n 's/^key: //p' "$CRED_FILE")

              if [[ -z "$USERNAME" || -z "$PASSWORD" || -z "$KEY" ]]; then
                echo "Atuin: Error - Missing credentials in $CRED_FILE"
                exit 1
              fi

              # 4. Perform Login
              ${atuinBin} login \
                --username "$USERNAME" \
                --password "$PASSWORD" \
                --key "$KEY"

              echo "Atuin: Login successful."
              ${atuinBin} sync
            '';
          in
          "${script}";

        # --- ExecStop (The Logout Logic) ---
        # Runs when 'systemctl --user stop atuin-login' is executed
        ExecStop = "${cfg.package}/bin/atuin logout";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
