{ pkgs }:
let
  inherit (pkgs) callPackage;
  mcp-nixos = callPackage ./packages/mcp-nixos.nix { };
  context-mode = callPackage ./packages/context-mode.nix { };
  opencode-snip = callPackage ./packages/opencode-snip.nix { };
  opentofu-mcp-server = callPackage ./packages/opentofu-mcp-server.nix { };
in
{
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
  plugin = [
    "${context-mode}/lib/context-mode"
    "${opencode-snip}/lib/opencode-snip"
  ];
}
