{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.module.opencode;

  superpowersSrc = pkgs.fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    rev = "v5.0.7";
    hash = "sha256-HQtO9cZfPPIkHDj64NeQuG9p9WhSKBVkWGWhZkZjZoo=";
  };

  superpowersSkillsList = [
    "brainstorming"
    "dispatching-parallel-agents"
    "executing-plans"
    "finishing-a-development-branch"
    "receiving-code-review"
    "requesting-code-review"
    "subagent-driven-development"
    "systematic-debugging"
    "test-driven-development"
    "using-git-worktrees"
    "using-superpowers"
    "verification-before-completion"
    "writing-plans"
    "writing-skills"
  ];

  superpowersSkills = builtins.listToAttrs (
    map (name: {
      name = "superpowers-${name}";
      value = "${superpowersSrc}/skills/${name}";
    }) superpowersSkillsList
  );

  opentofu-mcp-server = pkgs.callPackage ./packages/opentofu-mcp-server.nix { };

  context-mode = pkgs.callPackage ./packages/context-mode.nix { };

  mcp-nixos = pkgs.callPackage ./packages/mcp-nixos.nix { };

  defaultSkills = {
    # keep-sorted start
    ghq-lookup = ../../../assets/.config/opencode/skills/ghq-lookup;
    git-commit = ../../../assets/.config/opencode/skills/git-commit;
    gitlab-cli-tool = ../../../assets/.config/opencode/skills/gitlab-cli-tool;
    skill-creator = ../../../assets/.config/opencode/skills/skill-creator;
    style = ../../../assets/.config/opencode/skills/style;
    # keep-sorted end
  }
  // superpowersSkills;

  baseContext = builtins.readFile ./base-context.md;
in
{
  options.module.opencode = {
    enable = mkEnableOption "opencode";

    package = mkOption {
      type = types.package;
      default = pkgs.opencode;
      defaultText = literalExpression "pkgs.opencode";
      description = "The opencode package to use.";
    };

    extraSkills = mkOption {
      type = types.attrsOf types.path;
      default = { };
      description = "Skills merged on top of the default set.";
    };

    extraContext = mkOption {
      type = types.lines;
      default = "";
      description = "Context appended after the base context.";
    };
  };

  config = mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      inherit (cfg) package;

      settings = {
        autoshare = false;
        autoupdate = false;
        experimental.disable_paste_summary = true;
        share = "disabled";

        permission.bash = {
          # age: deny direct invocations to prevent secret exposure; ask on
          # incidental matches where "age" appears as a substring
          "age *" = "deny";
          "*age *" = "ask";

          # git: ask before committing; deny push entirely to avoid
          # unintended remote writes
          "git commit *" = "ask";
          "git push *" = "deny";

          # SSH: allow local key management tools (no remote access involved)
          "ssh-keygen *" = "allow";
          "ssh-add *" = "allow";
          "ssh-agent *" = "allow";

          # SSH: ask before any remote access or file transfer over SSH
          "ssh *" = "ask";
          "scp *" = "ask";
          "sftp *" = "ask";
          # Only gate remote rsync (contains user@host: or host: syntax)
          "rsync *@*:*" = "ask";
          "rsync * *:*" = "ask";

          # IaC: deny destroy operations; ask for all other state-mutating
          # commands across terraform, tofu, and tf wrappers
          "*terraform destroy*" = "deny";
          "*terraform *" = "ask";
          "*tofu destroy*" = "deny";
          "*tofu *" = "ask";
          "*tf destroy*" = "deny";
          "*tf *" = "ask";
        };

        mcp = {
          k8s = {
            type = "local";
            enabled = false;
            command = [ "${pkgs.mcp-k8s-go}/bin/mcp-k8s-go" ];
          };

          nix = {
            type = "local";
            command = [ "${mcp-nixos}/bin/mcp-nixos" ];
          };

          opentofu = {
            type = "local";
            enabled = false;
            command = [ "${opentofu-mcp-server}/bin/opentofu-mcp-server" ];
          };

          context7 = {
            type = "local";
            enabled = false;
            command = [ "${pkgs.context7-mcp}/bin/context7-mcp" ];
          };

          sequential-thinking = {
            type = "local";
            enabled = false;
            command = [ "${pkgs.mcp-server-sequential-thinking}/bin/mcp-server-sequential-thinking" ];
          };

          "context-mode" = {
            type = "local";
            command = [ "${context-mode}/bin/context-mode" ];
          };
        };

        # Load the context-mode TypeScript plugin for hook-based routing enforcement,
        # session continuity on compaction, and output compression. The plugin runs
        # inside OpenCode's bun process, so bun:sqlite is used (no native addon needed).
        plugin = [ "${context-mode}/lib/context-mode" ];
      };

      tui = {
        theme = "gruvbox";
        keybinds = {
          session_export = "none";
          session_share = "none";
          session_unshare = "none";
          terminal_suspend = "none";
          messages_first = "ctrl+home";
          messages_last = "ctrl+end";
        };
      };

      context = baseContext + cfg.extraContext;

      skills = defaultSkills // cfg.extraSkills;
    };
  };
}
