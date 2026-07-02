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
    mkMerge
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

  config = mkIf cfg.enable (mkMerge [
    (import ./snip-rtk.nix { inherit lib pkgs; })
    {
      programs.opencode = {
        enable = true;
        inherit (cfg) package;

        settings = {
          autoshare = false;
          autoupdate = false;
          experimental.disable_paste_summary = true;
          share = "disabled";
        }
        // import ./permissions.nix
        // import ./mcp.nix { inherit pkgs; };

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
    }
  ]);
}
