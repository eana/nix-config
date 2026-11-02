{
  lib,
  pkgs,
  garmin-mcp,
  contextMode,
  enableContextMode ? false,
  enablePlaywright ? false,
  enableGarmin ? false,
  enableContext7 ? false,
}:
let
  inherit (lib) filterAttrs optionalAttrs;
in
filterAttrs (_n: v: v != { }) {
  # Bare `context-mode` starts its stdio MCP server, serving the ctx_* tools.
  context-mode = optionalAttrs enableContextMode {
    command = "${contextMode}/bin/context-mode";
    enabled = true;
  };

  playwright = optionalAttrs (enablePlaywright && pkgs ? playwright-mcp) {
    command = "${pkgs.playwright-mcp}/bin/playwright-mcp";
    enabled = false;
  };

  context7 = optionalAttrs (pkgs ? context7-mcp) {
    command = "${pkgs.context7-mcp}/bin/context7-mcp";
    enabled = enableContext7;
  };

  garmin = optionalAttrs enableGarmin {
    command = "${garmin-mcp}/bin/garmin-mcp";
    enabled = false;
  };
}
