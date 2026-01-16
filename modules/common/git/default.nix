{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf mkDefault;
  cfg = config.module.git;

  identityDefaults = {
    name = "Jonas Eana";
    email = "jonas@eana.ro";
    key = "C01D2E8FCFCB6358";
  };

  renderIdentity =
    attrs:
    let
      merged = attrs // {
        name = attrs.name or identityDefaults.name;
        email = attrs.email or identityDefaults.email;
        key = attrs.key or identityDefaults.key;
      };
    in
    ''
      [user]
        name = ${merged.name}
        email = ${merged.email}
        signingkey = ${merged.key}
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
      description = "Attrset of identities. Each identity should have name,email,key and optional pathPatterns (list of gitdir patterns).";
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        sops
        meld
      ];

      file = fileAttrset // {
        ".gitconfig" = {
          text =
            let
              mkInclude =
                id:
                let
                  ident = cfg.identities.${id};
                  pats = ident.pathPatterns or [ ];
                  txt = renderIdentity ident;
                in
                if txt == "" || pats == [ ] then
                  ""
                else
                  ''
                    [includeIf "gitdir:${lib.concatStringsSep "|" pats}"] path = ~/.gitconfig-${id}
                  '';

              includeLines = lib.concatStringsSep "" (map mkInclude (lib.attrNames cfg.identities));

              chosen = if cfg.identity == null then { } else (lib.getAttr cfg.identity cfg.identities or { });
              globalUser = ''
                [user]
                  signingkey = ${chosen.key or "C01D2E8FCFCB6358"}
              '';
            in
            includeLines + "\n" + globalUser;
        };
      };
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
          key = mkDefault (chosen.key or "C01D2E8FCFCB6358");
        };

        settings = {
          core.pager = mkDefault "less";

          user = {
            name = mkDefault (chosen.name or "Jonas Eana");
            email = mkDefault (chosen.email or "jonas@eana.ro");
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
      enableGitIntegration = true;
      options = { };
    };
  };
}
