{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkPackageOption
    types
    ;
in
{
  options.module.git = {
    enable = mkEnableOption "Git version control system";

    identity = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Name of the identity to use as the global active identity (null = use defaults).";
    };

    identities = lib.mkOption {
      default = { };
      description = "Attrset of named identities. Each entry configures user info, GPG key, gitdir path patterns, and an optional SSH private key path.";
      type = types.attrsOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Git user.name override. Falls back to the module default when null.";
            };
            email = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Git user.email override. Falls back to the module default when null.";
            };
            key = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "GPG signing key override. Falls back to the module default when null.";
            };
            pathPatterns = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "List of gitdir: patterns that activate this identity.";
            };
            sshKey = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = ''
                Path to the SSH private key used for git operations in repos matching
                this identity. When null, defaults to ~/.ssh/id_ed25519.
                The key file is not managed by this module — only the path is referenced.
              '';
            };
          };
        }
      );
    };

    ghq = {
      enable = mkEnableOption "ghq remote repository management" // {
        default = true;
      };

      package = mkPackageOption pkgs "ghq" { };

      options = mkOption {
        type =
          with types;
          let
            primitiveType = either str (either bool int);
            sectionType = attrsOf primitiveType;
          in
          attrsOf (either primitiveType sectionType);
        default = { };
        example = {
          root = "~/src";
        };
        description = "Options to configure ghq via the [ghq] git config section.";
      };
    };

    glab = {
      enable = mkEnableOption "glab GitLab command-line tool" // {
        default = true;
      };

      package = mkPackageOption pkgs "glab" { };
    };

    gh = {
      enable = mkEnableOption "gh GitHub command-line tool" // {
        default = true;
      };

      package = mkPackageOption pkgs "gh" { };
    };
  };
}
