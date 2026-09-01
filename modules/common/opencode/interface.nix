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

    snip = {
      enable = mkEnableOption "snip shell-command recording plugin for opencode";
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
            reasoning = [
              "claude-sonnet-5"
            ];
            noReasoning = [
              "claude-haiku-4.5"
              "claude-sonnet-5"
            ];
          }
          {
            name = "Auto Building";
            preferredModels = [
              "gpt-5.3-codex"
              "gpt-5.4-mini"
            ];
            reasoning = [
              "gpt-5.3-codex"
              "gpt-5.4-mini"
            ];
            noReasoning = [
              "gpt-5.6-luna"
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

    gsd = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable GSD Core opencode plugin + companion MCP server.";
      };
    };

    extraContext = mkOption {
      type = types.lines;
      default = "";
      description = "Context appended after the base context.";
    };
  };
}
