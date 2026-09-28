{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkOption
    types
    ;

  catalog = import ./skills-catalog.nix;
  catalogKeys =
    catalog.local ++ (map (name: "superpowers-${name}") catalog.superpowers) ++ catalog.social;
  groupAliases = [
    "superpowers"
    "social"
  ];
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

    contextMode = {
      package = mkOption {
        type = types.package;
        default = pkgs.callPackage ./packages/context-mode.nix { };
        defaultText = literalExpression "callPackage ./packages/context-mode.nix { }";
        description = ''
          The context-mode plugin package opencode loads. Built locally from
          the npm tarball, not pkgs.context-mode (pinned to 1.0.143, no
          build/ directory - no plugin entry, no ctx_* tools).
        '';
      };

      runtime = mkOption {
        type = types.package;
        default = pkgs.bun;
        defaultText = literalExpression "pkgs.bun";
        description = ''
          JS runtime for context-mode's ctx_execute, put on PATH. It only
          accepts a host fallback when process.execPath is named node, bun or
          deno; opencode's binary is named opencode, so without this on PATH
          ctx_execute throws "No JavaScript runtime available".
        '';
      };
    };

    snip = {
      enable = mkEnableOption "snip shell-command recording plugin for opencode";
    };

    playwright = {
      enable = mkEnableOption "Playwright browser-automation MCP server (for LinkedIn profile editing and similar tasks)";
    };

    garmin = {
      enable = mkEnableOption "Garmin Connect MCP server and auth CLI";
    };

    skills = {
      enabled = mkOption {
        type = types.listOf (types.enum (catalogKeys ++ groupAliases));
        default = catalog.local ++ [ "superpowers" ];
        description = ''
          Skills to enable, by flat skill name (e.g. "nix-check",
          "superpowers-brainstorming", "social-post") or group alias
          ("superpowers", "social") which expands to every skill in that
          group. Unknown names error at eval time.
        '';
      };
    };

    copilotAutoModel = {
      autos = mkOption {
        type = types.listOf (types.attrsOf types.anything);
        default = [
          {
            name = "Auto Planning";
            preferredModels = [
              "claude-sonnet-5"
            ];
          }
          {
            name = "Auto Building";
            preferredModels = [
              "gpt-5.3-codex"
              "gpt-5.4-mini"
            ];
          }
        ];
        description = "Autos passed to opencode-github-copilot-auto-model plugin. Set to [] to disable all autos and use the plugin's default Auto picker.";
      };
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable opencode-github-copilot-auto-model plugin (opt-out).";
      };
    };

    extraContext = mkOption {
      type = types.lines;
      default = "";
      description = "Context appended after the base context.";
    };
  };
}
