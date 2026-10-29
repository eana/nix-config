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
  jsonFormat = pkgs.formats.json { };

  catalog = import ./skills-catalog.nix;

  pluginConfig = import ./plugins.nix {
    inherit lib pkgs;
    enableSnip = cfg.snip.enable;
    enableCopilotAutoModel = cfg.copilotAutoModel.enable;
    copilotAutoModelAutos = cfg.copilotAutoModel.autos;
    enablePonytail = cfg.ponytail.enable;
  };

  skillsConfig = import ./skills.nix {
    inherit lib pkgs;
    enabledSkills = cfg.skills.enabled;
    inherit (cfg.ticket) ticketsRepo;
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

  ticketAgent = model: description: ''
    ---
    description: ${description}
    mode: subagent
    model: ${model}
    ---

    Follow the instructions in the prompt exactly. Load the skills it names before acting.
  '';
  inherit (pkgs) callPackage;
  garmin-mcp = callPackage ./packages/garmin-mcp {
    inherit (inputs) uv2nix pyproject-nix pyproject-build-systems;
  };

  # Bundles the repo-wiki SKILL.md plus its index/query tools. Installed as a
  # normal package (commands on PATH) and pointed at as the skill directory,
  # so the tools work on any repo, not just inside this flake's devshell.
  repo-wiki = callPackage ./packages/repo-wiki { };
  repoWikiEnabled = lib.elem "repo-wiki" cfg.skills.enabled;

  ticketAgentsEnabled = lib.any (name: lib.elem name cfg.skills.enabled) [
    "ticket-plan"
    "ticket-run"
    "ticket-task"
  ];

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

      # HACK: home-manager's programs.opencode.tui writes tui.json, which
      # OpenCode V2 no longer reads - terminal settings moved to one global
      # cli.json. Install cli.json directly until HM exposes a cli option.
      # No upstream issue tracked; remove this workaround once HM gains one.
      "opencode/cli.json".source = jsonFormat.generate "opencode-cli.json" {
        "$schema" = "https://opencode.ai/v2/cli.json";
        # Show pasted text instead of a "[Pasted ~N lines]" placeholder.
        prompt.paste = "full";
        theme.name = tuiTheme;
        keybinds = {
          "session.export" = "none";
          "session.first" = "ctrl+home";
          "session.last" = "ctrl+end";
          "terminal.suspend" = "none";
        };
        diffs.wrap = "word";
        session = {
          sidebar = "auto";
          scrollbar = false;
          thinking = "hide";
        };
        animations = true;
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
      "opencode/agents/ticket-planner.md" = mkIf ticketAgentsEnabled {
        text = ticketAgent cfg.ticket.models.planner "Plans, splits, checks and reviews work for the ticket-plan and ticket-run skills.";
      };
      "opencode/agents/ticket-builder.md" = mkIf ticketAgentsEnabled {
        text = ticketAgent cfg.ticket.models.builder "Implements one ticket task (high complexity, retries, review fixes) via the ticket-task skill.";
      };
      "opencode/agents/ticket-builder-light.md" = mkIf ticketAgentsEnabled {
        text = ticketAgent cfg.ticket.models.builderLight "Implements one low-complexity ticket task via the ticket-task skill.";
      };
    };

    programs.mcp = {
      enable = true;
      servers = import ./mcp.nix {
        inherit lib pkgs garmin-mcp;
        contextMode = cfg.contextMode.package;
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

      # Terminal settings live in cli.json (see xdg.configFile above), not here.
      # OpenCode V2 ignores tui.json entirely.

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
