{ config, lib, ... }:
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

      # Include the secrets via config.d directory
      includes = mkIf (cfg.secretsFile != null) [
        "config.d/ssh-hosts"
      ];

      matchBlocks =
        let
          # Only use manually defined hosts
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

    # Activation script to copy secrets to config.d
    home.activation.sshSecretsConfig = mkIf (cfg.secretsFile != null) (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        secrets_file="${cfg.secretsFile}"
        ssh_config_dir="$HOME/.ssh/config.d"
        ssh_secrets_config="$ssh_config_dir/ssh-hosts"

        $DRY_RUN_CMD mkdir -p "$ssh_config_dir"

        if [ -f "$secrets_file" ]; then
          $VERBOSE_ECHO "Copying SSH secrets to config.d/ssh-hosts"
          $DRY_RUN_CMD cp "$secrets_file" "$ssh_secrets_config"
          $DRY_RUN_CMD chmod 600 "$ssh_secrets_config"
        else
          $VERBOSE_ECHO "Secrets file not found, removing config.d/ssh-hosts"
          $DRY_RUN_CMD rm -f "$ssh_secrets_config"
        fi
      ''
    );
  };
}
