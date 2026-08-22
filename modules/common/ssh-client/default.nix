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
  cfg = config.module.ssh-client;

  sshProvisionScript = pkgs.writeShellScript "ssh-provision-secrets" ''
    export PATH="${
      lib.makeBinPath [
        pkgs.coreutils
      ]
    }:$PATH"

    set -euo pipefail

    SECRETS_FILE="${toString cfg.secretsFile}"
    SSH_CONFIG_DIR="$HOME/.ssh/config.d"
    SSH_SECRETS_CONFIG="$SSH_CONFIG_DIR/ssh-hosts"

    mkdir -p "$SSH_CONFIG_DIR"

    if [ -f "$SECRETS_FILE" ]; then
      echo "SSH Client: Copying secrets to $SSH_SECRETS_CONFIG"
      cp "$SECRETS_FILE" "$SSH_SECRETS_CONFIG"
      chmod 600 "$SSH_SECRETS_CONFIG"
    else
      echo "SSH Client: Secrets file not found at $SECRETS_FILE, removing config entry"
      rm -f "$SSH_SECRETS_CONFIG"
    fi
  '';

in
{
  imports = [ ./interface.nix ];

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      inherit (cfg) enableDefaultConfig;

      includes = mkIf (cfg.secretsFile != null) [
        "config.d/ssh-hosts"
      ];

      settings =
        let
          customHosts = lib.mapAttrs' (
            name: host:
            lib.nameValuePair "Host ${name}" (
              lib.filterAttrs (_: v: v != null) {
                Hostname = host.hostname;
                User = host.user;
                Port = host.port;
                IdentityFile = host.identityFile;
                HostKeyAlgorithms = host.hostKeyAlgorithms;
                PubkeyAcceptedKeyTypes = host.pubkeyAcceptedKeyTypes;
                KexAlgorithms = host.kexAlgorithms;
                PreferredAuthentications = host.preferredAuthentications;
                PubkeyAuthentication = host.pubkeyAuthentication;
              }
              // host.extraConfig
            )
          ) cfg.hosts;

          globalBlock = if cfg.globalOptions != { } then { "Host *" = cfg.globalOptions; } else { };
        in
        customHosts // globalBlock;
    };

    # Linux — path unit re-fires the service whenever agenix rewrites the secret
    systemd.user.paths.ssh-secret-provision =
      mkIf (pkgs.stdenv.hostPlatform.isLinux && cfg.secretsFile != null)
        {
          Unit.Description = "Watch for SSH secret changes";
          Path = {
            # PathChanged fires on inode replacement, which is how agenix writes atomically.
            PathChanged = cfg.secretsFile;
            Unit = "ssh-secret-provision.service";
          };
          Install.WantedBy = [ "default.target" ];
        };

    # Linux
    systemd.user.services.ssh-secret-provision =
      mkIf (pkgs.stdenv.hostPlatform.isLinux && cfg.secretsFile != null)
        {
          Unit = {
            Description = "Provision SSH secret configuration";
            After = [ "default.target" ];
          };

          Service = {
            Type = "oneshot";
            ExecStart = "${sshProvisionScript}";
          };

          Install = {
            WantedBy = [ "default.target" ];
          };
        };

    # macOS
    launchd.agents.ssh-secret-provision =
      mkIf (pkgs.stdenv.hostPlatform.isDarwin && cfg.secretsFile != null)
        {
          enable = true;
          config = {
            Label = "org.nix-community.ssh-secret-provision";
            ProgramArguments = [ "${sshProvisionScript}" ];
            RunAtLoad = true;
            KeepAlive = false;
            # Re-run whenever agenix (re)writes the secret, eliminating the race
            # between activate-agenix and this agent at login.
            WatchPaths = [ cfg.secretsFile ];
            StandardOutPath = "${config.home.homeDirectory}/Library/Logs/ssh-secret-provision.out.log";
            StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/ssh-secret-provision.err.log";
          };
        };
  };
}
