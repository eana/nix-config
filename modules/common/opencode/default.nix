{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib)
    mkIf
    optional
    optionalString
    ;
  cfg = config.module.opencode;
  custom = config.custom or { };
  tuiTheme = if (custom.theme or "gruvbox") == "gruvbox" then "gruvbox" else "catppuccin";

  catalog = import ./skills-catalog.nix;

  pluginConfig = import ./plugins.nix {
    inherit lib pkgs;
    contextMode = cfg.contextMode.package;
    enableSnip = cfg.snip.enable;
    enableCopilotAutoModel = cfg.copilotAutoModel.enable;
    copilotAutoModelAutos = cfg.copilotAutoModel.autos;
  };

  skillsConfig = import ./skills.nix {
    inherit lib pkgs;
    enabledSkills = cfg.skills.enabled;
  };

  # Enumerated by name: home-manager's skills option wants an attrset, not
  # context-mode's own skills dir. New upstream skills need adding here.
  contextModeSkills = builtins.listToAttrs (
    map
      (name: {
        inherit name;
        value = "${cfg.contextMode.package}/share/skills/context-mode/${name}";
      })
      [
        "context-mode"
        "ctx-doctor"
        "ctx-index"
        "ctx-insight"
        "ctx-purge"
        "ctx-search"
        "ctx-stats"
        "ctx-upgrade"
      ]
  );

  baseContext = builtins.readFile ./base-context.md;
  inherit (pkgs) callPackage;
  garmin-mcp = callPackage ./packages/garmin-mcp {
    inherit (inputs) uv2nix pyproject-nix pyproject-build-systems;
  };

  # Bundles the repo-wiki SKILL.md plus its index/query tools. Installed as a
  # normal package (commands on PATH) and pointed at as the skill directory,
  # so the tools work on any repo, not just inside this flake's devshell.
  repo-wiki = callPackage ./packages/repo-wiki { };
  repoWikiEnabled = lib.elem "repo-wiki" cfg.skills.enabled;

  codebaseMemoryOpenCode = callPackage ./packages/codebase-memory-opencode {
    codebase-memory-mcp = cfg.codebaseMemory.package;
  };
in
{
  imports = [ ./interface.nix ];

  config = mkIf cfg.enable {
    # Opt-out baseline: local + superpowers skills are on unless a host
    # explicitly removes them (via mkForce). Linkedin and social skills stay
    # opt-in (see playwright.enable and skills.enabled = [ "social" ... ]).
    module.opencode.skills.enabled = catalog.local ++ [ "superpowers" ];

    home.packages = [
      cfg.contextMode.runtime
    ]
    ++ lib.optionals cfg.snip.enable [ pkgs.snip ]
    ++ lib.optionals cfg.garmin.enable [ garmin-mcp ]
    ++ lib.optional repoWikiEnabled repo-wiki;

    xdg.configFile = {
      "snip/config.toml" = mkIf cfg.snip.enable {
        source = ../../../assets/.config/snip/config.toml;
      };

      # HACK: programs.opencode.agents only treats Nix path values as file
      # sources; a store path string is written as inline text. Install the
      # generated profiles through xdg.configFile instead.
      # TODO: switch to programs.opencode.agents when HM accepts store paths.
      "opencode/agents/codebase-memory-scout.md" =
        mkIf (cfg.codebaseMemory.enable && cfg.codebaseMemory.agents.enable)
          {
            source = "${codebaseMemoryOpenCode}/share/opencode/agents/codebase-memory-scout.md";
          };
      "opencode/agents/codebase-memory.md" =
        mkIf (cfg.codebaseMemory.enable && cfg.codebaseMemory.agents.enable)
          {
            source = "${codebaseMemoryOpenCode}/share/opencode/agents/codebase-memory.md";
          };
      "opencode/agents/codebase-memory-auditor.md" =
        mkIf (cfg.codebaseMemory.enable && cfg.codebaseMemory.agents.enable)
          {
            source = "${codebaseMemoryOpenCode}/share/opencode/agents/codebase-memory-auditor.md";
          };
    };

    programs.mcp = {
      enable = true;
      servers = import ./mcp.nix {
        inherit lib pkgs garmin-mcp;
        codebaseMemory = cfg.codebaseMemory.package;
        enableCodebaseMemory = cfg.codebaseMemory.enable;
        enablePlaywright = cfg.playwright.enable;
        enableGarmin = cfg.garmin.enable;
      };
    };

    programs.opencode = {
      enable = true;
      inherit (cfg) package;

      enableMcpIntegration = true;

      settings = {
        autoshare = false;
        autoupdate = false;
        experimental.disable_paste_summary = true;
        share = "disabled";
        lsp = import ./lsp.nix { inherit lib pkgs; };
      }
      // import ./permissions.nix { enableSnip = cfg.snip.enable; }
      // {
        plugin =
          pluginConfig.plugin
          ++ optional (
            cfg.codebaseMemory.enable && cfg.codebaseMemory.plugin.enable
          ) "${codebaseMemoryOpenCode}/share/opencode/plugins/cbm-augment.ts";
      };

      tui = {
        theme = tuiTheme;
        keybinds = {
          session_export = "none";
          session_share = "none";
          session_unshare = "none";
          terminal_suspend = "none";
          messages_first = "ctrl+home";
          messages_last = "ctrl+end";
        };
      };

      # Keep codebase-memory-context.md in sync with agent_instructions_content
      # in the pinned codebase-memory-mcp source.
      context =
        baseContext
        + optionalString cfg.codebaseMemory.enable (builtins.readFile ./codebase-memory-context.md)
        + cfg.extraContext;

      skills =
        skillsConfig
        // lib.optionalAttrs cfg.codebaseMemory.enable {
          codebase-memory = "${codebaseMemoryOpenCode}/share/opencode/skills/codebase-memory";
          cbm-new-project = ../../../assets/.config/opencode/skills/cbm-new-project;
        }
        // lib.optionalAttrs repoWikiEnabled { repo-wiki = "${repo-wiki}"; }
        // lib.optionalAttrs cfg.playwright.enable {
          linkedin-profile-editor = ../../../assets/.config/opencode/skills/linkedin-profile-editor;
        }
        // contextModeSkills
        // cfg.extraSkills;
    };
  };
}
