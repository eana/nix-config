{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.git;

in
{
  options.module.git = {
    enable = mkEnableOption "Git version control system";

    package = mkOption {
      type = types.package;
      default = pkgs.git;
      description = "Distributed version control system";
    };

    userName = mkOption {
      type = types.str;
      default = "Jonas Eana";
      description = "Default Git user name";
    };

    userEmail = mkOption {
      type = types.str;
      default = "jonas@eana.ro";
      description = "Default Git email";
    };

    signing = mkOption {
      type = types.submodule {
        options = {
          signByDefault = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to sign commits by default";
          };
          key = mkOption {
            type = types.str;
            default = "C01D2E8FCFCB6358";
            description = "GPG key ID for signing";
          };
        };
      };
      default = { };
      description = "Git commit signing configuration";
    };

    delta.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable delta diff viewer";
    };

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {
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
      description = "Git command aliases";
    };

    extraConfig = mkOption {
      type = types.attrs;
      default = {
        fetch.prune = "true";
        pull.rebase = "true";
        push.default = "current";
        commit.verbose = "true";
        rerere = {
          enabled = "true";
          autoUpdate = "true";
        };
        diff = {
          sopsdiffer = {
            textconv = "sops -d";
          };
          tool = "meld";
        };
        difftool.prompt = false;
        difftool.meld.cmd = "meld $LOCAL $REMOTE";
      };
      description = "Additional Git configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      inherit (cfg) package;
      settings = lib.recursiveUpdate {
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };
        alias = cfg.aliases;
      } cfg.extraConfig;
      inherit (cfg) signing;
    };
    programs.delta = {
      inherit (cfg.delta) enable;
      enableGitIntegration = true;
    };
  };
}
