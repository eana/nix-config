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
    types
    mkIf
    ;
  cfg = config.module.ssh-client;

  mkHostOption = {
    options = {
      hostname = mkOption {
        type = types.str;
        description = "Hostname or IP address for the SSH host";
      };
      user = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Username for SSH connection";
      };
      port = mkOption {
        type = types.nullOr types.port;
        default = null;
        description = "Port number for SSH connection";
      };
      identityFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to identity file for authentication";
      };
      hostKeyAlgorithms = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Allowed host key algorithms";
      };
      pubkeyAcceptedKeyTypes = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Accepted public key types";
      };
      kexAlgorithms = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Key exchange algorithms";
      };
      preferredAuthentications = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Preferred authentication methods";
      };
      pubkeyAuthentication = mkOption {
        type = types.nullOr (
          types.enum [
            "yes"
            "no"
          ]
        );
        default = null;
        description = "Enable or disable public key authentication";
      };
      extraConfig = mkOption {
        type = types.attrsOf types.str;
        default = { };
        description = "Additional SSH configuration options";
      };
    };
  };

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
  options.module.ssh-client = {
    enable = mkEnableOption "SSH client configuration";
    enableDefaultConfig = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable home-manager's default SSH configuration";
    };
    secretsFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Path to decrypted secrets file containing SSH config format.
        This should be a string path like "/run/agenix/ssh-hosts".
        The file should contain SSH config syntax directly.
        Note: This cannot be read at build time, so it will be included
        via a separate config.d file.
      '';
    };
    hosts = mkOption {
      type = types.attrsOf (types.submodule mkHostOption);
      default = { };
      description = "SSH host configurations (public, unencrypted)";
    };
    globalOptions = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Global SSH options (applied to Host *)";
    };
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      inherit (cfg) enableDefaultConfig;

      includes = mkIf (cfg.secretsFile != null) [
        "config.d/ssh-hosts"
      ];

      matchBlocks =
        let
          customHosts = lib.mapAttrs (_: host: {
            inherit (host)
              hostname
              user
              port
              identityFile
              ;
            extraOptions =
              lib.filterAttrs (_: v: v != null) {
                inherit (host)
                  hostKeyAlgorithms
                  pubkeyAcceptedKeyTypes
                  kexAlgorithms
                  preferredAuthentications
                  pubkeyAuthentication
                  ;
              }
              // host.extraConfig;
          }) cfg.hosts;

          globalBlock =
            if cfg.globalOptions != { } then
              {
                "*" = {
                  extraOptions = cfg.globalOptions;
                };
              }
            else
              { };
        in
        customHosts // globalBlock;
    };

    # Linux
    systemd.user.services.ssh-secret-provision = mkIf (pkgs.stdenv.isLinux && cfg.secretsFile != null) {
      Unit = {
        Description = "Provision SSH secret configuration";
        After = [ "default.target" ];
        ConditionPathExists = cfg.secretsFile;
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${sshProvisionScript}";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # macOS
    launchd.agents.ssh-secret-provision = mkIf (pkgs.stdenv.isDarwin && cfg.secretsFile != null) {
      enable = true;
      config = {
        Label = "org.nix-community.ssh-secret-provision";
        ProgramArguments = [ "${sshProvisionScript}" ];
        RunAtLoad = true;
        KeepAlive = false;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/ssh-secret-provision.out.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/ssh-secret-provision.err.log";
      };
    };
  };
}
