{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkPackageOption
    types
    ;
  cfg = config.module.git;

  identityDefaults = {
    name = "Jonas Eana";
    email = "jonas@eana.ro";
    key = "C01D2E8FCFCB6358";
  };

  renderIdentity =
    attrs:
    let
      merged = {
        name = if attrs.name != null then attrs.name else identityDefaults.name;
        email = if attrs.email != null then attrs.email else identityDefaults.email;
        key = if attrs.key != null then attrs.key else identityDefaults.key;
        sshKey = if attrs.sshKey != null then attrs.sshKey else "~/.ssh/id_ed25519";
      };
    in
    ''
      [user]
        name = ${merged.name}
        email = ${merged.email}
        signingkey = ${merged.key}
      [core]
        sshCommand = ssh -i ${merged.sshKey} -o IdentitiesOnly=yes
    '';

  fileAttrset = lib.foldl' (
    acc: id:
    let
      ident = cfg.identities.${id};
      fileName = ".gitconfig-${id}";
      txt = renderIdentity ident;
    in
    if txt == "" then
      acc
    else
      acc
      // {
        "${fileName}" = {
          text = txt;
        };
      }
  ) { } (lib.attrNames cfg.identities);

  includeEntries = lib.concatMap (
    id:
    let
      ident = cfg.identities.${id};
      pats = ident.pathPatterns;
    in
    map (pattern: {
      condition = "gitdir:" + pattern;
      path = "~/.gitconfig-${id}";
    }) pats
  ) (lib.attrNames cfg.identities);
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
      enable = mkEnableOption "ghq remote repository management";

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
      enable = mkEnableOption "glab GitLab command-line tool";

      package = mkPackageOption pkgs "glab" { };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home = {
        packages = with pkgs; [
          sops
          meld
        ];

        file = fileAttrset;
      };

      programs.git =
        let
          chosen = if cfg.identity == null then { } else (lib.getAttr cfg.identity cfg.identities or { });
        in
        {
          enable = true;
          package = pkgs.git;

          signing = {
            signByDefault = mkDefault true;
            key = mkDefault (chosen.key or identityDefaults.key);
            format = mkDefault "openpgp";
          };

          includes = includeEntries;

          settings = {
            core.pager = mkDefault "less";

            user = {
              name = mkDefault (chosen.name or identityDefaults.name);
              email = mkDefault (chosen.email or identityDefaults.email);
            };

            alias = {
              "co" = "checkout";
              "lol" =
                "log --graph --abbrev-commit --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)%an <%ae>%Creset' --date=relative";
              "in" = "!git fetch && git log --pretty=oneline --abbrev-commit --graph ..@{u}";
              "out" = "log --pretty=oneline --abbrev-commit --graph @{u}..";
              "unstage" = "reset HEAD --";
              "last" = "log -1 HEAD";
              "alias" = "!git config --get-regexp 'alias.*' | colrm 1 6 | sed 's/[ ]/ = \"/'";
              "mb" = "merge-base master HEAD";
              "ma" = "merge-base main HEAD";
              "mb-rebase" = "!git rebase -i $(git mb)";
              "mb-log" = "!git log $(git mb)..HEAD";
              "mb-diff" = "!git diff $(git mb)..HEAD";
              "ma-diff" = "!git diff $(git ma)..HEAD";
              "pfl" = "push --force-with-lease";
              "ppr" = "pull --all --prune --rebase";
              "au" = "add --update";
              "locate" = "!f() { git ls-tree -r --name-only HEAD | grep -i --color -E $1 - ; } ; f";
              "pushall" = "!git remote | xargs -L1 git push --all";
              "pull" = "pull --all --prune --rebase";
            };

            fetch.prune = true;
            pull.rebase = true;
            push.default = "current";
            commit.verbose = true;

            rerere = {
              enabled = true;
              autoUpdate = true;
            };

            diff = {
              tool = "meld";
              sopsdiffer = {
                textconv = "sops -d";
              };
            };

            difftool = {
              prompt = false;
              meld = {
                cmd = "meld $LOCAL $REMOTE";
              };
            };
          };
        };

      programs.delta = {
        enable = mkDefault false;
        options = { };
      };
    }

    (mkIf cfg.ghq.enable {
      home.packages = [ cfg.ghq.package ];
      programs.git.settings.ghq = cfg.ghq.options;
    })

    (mkIf cfg.glab.enable {
      home.packages = [ cfg.glab.package ];
    })
  ]);
}
