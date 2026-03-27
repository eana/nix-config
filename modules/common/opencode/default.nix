{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.opencode;

  defaultSettings = {
    "$schema" = "https://opencode.ai/config.json";
    autoshare = false;
    autoupdate = false;
    experimental = {
      disable_paste_summary = true;
    };
    keybinds = {
      session_export = "none";
      session_share = "none";
      session_unshare = "none";
      terminal_suspend = "none";
      messages_first = "ctrl+home";
      messages_last = "ctrl+end";
    };
    share = "disabled";
  };

  # Build xdg.configFile entries for all SKILL.md files found inside a skills
  # directory.  The directory must contain subdirectories named after each
  # skill, each with a SKILL.md inside:
  #
  #   <dir>/
  #     <skill-name>/
  #       SKILL.md
  #
  # Returns an attrset suitable for merging into xdg.configFile.
  skillsFromDir =
    dir:
    let
      entries = builtins.readDir dir;
      skillNames = builtins.filter (n: entries.${n} == "directory") (builtins.attrNames entries);
    in
    builtins.listToAttrs (
      map (name: {
        name = "opencode/skills/${name}/SKILL.md";
        value = {
          source = "${dir}/${name}/SKILL.md";
        };
      }) skillNames
    );

  # Directories to process: built-in skills (when enabled) followed by any
  # extra dirs supplied by the caller.  Processing order means extraSkillsDirs
  # entries override built-in skills on name collision (last writer wins).
  activeDirs = lib.optional cfg.skills.enable ./skills ++ cfg.skills.extraSkillsDirs;

  allSkillFiles = lib.foldl' (acc: dir: acc // skillsFromDir dir) { } activeDirs;

in
{
  options.module.opencode = {
    enable = mkEnableOption "OpenCode AI coding agent";

    package = mkOption {
      type = types.package;
      default = pkgs.opencode;
      description = "The open source AI coding agent";
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "OpenCode configuration settings";
    };

    # Skills are reusable instruction sets loaded on-demand by OpenCode agents.
    # Each skill lives in its own subdirectory containing a single SKILL.md:
    #
    #   modules/common/opencode/skills/
    #     <skill-name>/
    #       SKILL.md        <- YAML frontmatter (name, description) + Markdown body
    #
    # To add a new built-in skill: create the subdirectory and SKILL.md, then
    # set skills.enable = true on the host.  No Nix code changes are needed.
    #
    # To add skills from an external source (e.g. a private work repo), pass
    # a path to a directory with the same layout via skills.extraSkillsDirs:
    #
    #   module.opencode.skills.extraSkillsDirs = [ "${inputs.my-work-repo}/skills" ];
    #
    # skills.extraSkillsDirs is evaluated independently of skills.enable, so
    # external skills are deployed even when skills.enable = false.
    # When two directories contain a skill with the same name, the last entry
    # in extraSkillsDirs wins, allowing overrides of built-in skills.
    skills = {
      enable = lib.mkEnableOption "built-in OpenCode skills bundled with this config" // {
        default = true;
      };

      extraSkillsDirs = mkOption {
        type = types.listOf types.path;
        default = [ ];
        description = ''
          Additional directories of OpenCode skills to deploy alongside the
          built-in ones. Each directory must contain subdirectories named
          after the skill, with a SKILL.md file inside each:

            <dir>/<skill-name>/SKILL.md

          Skills from these directories are deployed independently of
          skills.enable. When a skill name collides with one from an earlier
          directory (or the built-in skills), the last directory in the list
          wins, allowing overrides.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = {
      "opencode/opencode.json".text = builtins.toJSON (lib.recursiveUpdate defaultSettings cfg.settings);
    }
    // allSkillFiles;
  };
}
