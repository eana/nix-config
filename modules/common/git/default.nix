{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf mkDefault;
  cfg = config.module.git;
in
{
  options.module.git = {
    enable = mkEnableOption "Git version control system";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      sops # Required for 'diff.sopsdiffer'
      meld # Required for 'difftool.meld'
    ];

    programs.git = {
      enable = true;
      package = pkgs.git;

      signing = {
        signByDefault = mkDefault true;
        key = mkDefault "C01D2E8FCFCB6358";
      };

      settings = {
        user = {
          name = mkDefault "Jonas Eana";
          email = mkDefault "jonas@eana.ro";
        };

        commit.gpgsign = mkDefault true;

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
      enableGitIntegration = true;

      options = {
        # You can add custom delta themes here if you want
        # e.g. features = "decorations";
      };
    };
  };
}
