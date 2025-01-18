{ pkgs }:

{
  enable = true;
  userName = "Jonas Eana";
  userEmail = "jonas@eana.ro";

  delta.enable = true;

  # GPG signing.
  signing = {
    signByDefault = true;
    key = "C01D2E8FCFCB6358";
  };

  aliases = {
    "co" = "checkout";
    "lol" =
      "log --graph --abbrev-commit --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)%an <%ae>%Creset' --date=relative";
    "in" =
      "!git fetch && git log --pretty=oneline --abbrev-commit --graph ..@{u}";
    "out" = "log --pretty=oneline --abbrev-commit --graph @{u}..";
    "unstage" = "reset HEAD --";
    "last" = "log -1 HEAD";
    "alias" =
      "!git config --get-regexp 'alias.*' | colrm 1 6 | sed 's/[ ]/ = \"/'";
    "mb" = "merge-base master HEAD";
    "ma" = "merge-base main HEAD";
    "mb-rebase" = "!git rebase -i $(git mb)";
    "mb-log" = "!git log $(git mb)..HEAD";
    "mb-diff" = "!git diff $(git mb)..HEAD";
    "ma-diff" = "!git diff $(git ma)..HEAD";
    "pfl" = "push --force-with-lease";
    "ppr" = "pull --all --prune --rebase";
    "au" = "add --update";
    "locate" =
      "!f() { git ls-tree -r --name-only HEAD | grep -i --color -E $1 - ; } ; f";
    "pushall" = "!git remote | xargs -L1 git push --all";
    "pull" = "pull --all --prune --rebase";
  };

  extraConfig = {
    fetch.prune = "true";
    pull.rebase = "true";
    push.default = "current";

    # Reuse recorded resolutions.
    rerere = {
      enabled = "true";
      autoUpdate = "true";
    };

    diff = {
      sopsdiffer = { textconv = "sops -d"; };
      tool = "meld";
    };

    difftool.prompt = false;
    difftool.meld.cmd = "meld $LOCAL $REMOTE";
  };
}
