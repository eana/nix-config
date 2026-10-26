{
  lib,
  pkgs,
  garmin-mcp,
  contextMode,
  codebaseMemory,
  enableCodebaseMemory,
  enablePlaywright ? false,
  enableGarmin ? false,
}:
let
  inherit (lib) filterAttrs optionalAttrs;
in
filterAttrs (_n: v: v != { }) {
  # Bare `context-mode` starts its stdio MCP server, serving the ctx_* tools.
  context-mode = {
    command = "${contextMode}/bin/context-mode";
    enabled = true;
  };

  codebase-memory = optionalAttrs enableCodebaseMemory {
    command = "${codebaseMemory}/bin/codebase-memory-mcp";
    enabled = true;
  };

  k8s = optionalAttrs (pkgs ? mcp-k8s-go) {
    command = "${pkgs.mcp-k8s-go}/bin/mcp-k8s-go";
    enabled = false;
  };

  opentofu = optionalAttrs (pkgs ? opentofu-mcp-server) {
    command = "${pkgs.opentofu-mcp-server}/bin/opentofu-mcp-server";
    enabled = false;
  };

  playwright = optionalAttrs (enablePlaywright && pkgs ? playwright-mcp) {
    command = "${pkgs.playwright-mcp}/bin/playwright-mcp";
    enabled = false;
  };

  context7 = optionalAttrs (pkgs ? context7-mcp) {
    command = "${pkgs.context7-mcp}/bin/context7-mcp";
    enabled = false;
  };

  sequential-thinking = optionalAttrs (pkgs ? mcp-server-sequential-thinking) {
    command = "${pkgs.mcp-server-sequential-thinking}/bin/mcp-server-sequential-thinking";
    enabled = false;
  };

  garmin = optionalAttrs enableGarmin {
    command = "${garmin-mcp}/bin/garmin-mcp";
    enabled = false;
  };
}
