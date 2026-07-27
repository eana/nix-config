{ lib, pkgs }:
let
  inherit (lib) filterAttrs optionalAttrs;
  inherit (pkgs) callPackage;
  mcp-nixos = callPackage ./packages/mcp-nixos.nix { };
  context-mode = callPackage ./packages/context-mode.nix { };

  servers = filterAttrs (_n: v: v != { }) {
    k8s = optionalAttrs (pkgs ? mcp-k8s-go) {
      type = "local";
      enabled = false;
      command = [ "${pkgs.mcp-k8s-go}/bin/mcp-k8s-go" ];
    };

    nix = {
      type = "local";
      command = [ "${mcp-nixos}/bin/mcp-nixos" ];
    };

    opentofu = optionalAttrs (pkgs ? opentofu-mcp-server) {
      type = "local";
      enabled = false;
      command = [ "${pkgs.opentofu-mcp-server}/bin/opentofu-mcp-server" ];
    };

    context7 = optionalAttrs (pkgs ? context7-mcp) {
      type = "local";
      enabled = false;
      command = [ "${pkgs.context7-mcp}/bin/context7-mcp" ];
    };

    sequential-thinking = optionalAttrs (pkgs ? mcp-server-sequential-thinking) {
      type = "local";
      enabled = false;
      command = [ "${pkgs.mcp-server-sequential-thinking}/bin/mcp-server-sequential-thinking" ];
    };

    "context-mode" = {
      type = "local";
      command = [ "${context-mode}/bin/context-mode" ];
    };
  };
in
{
  mcp = servers;
}
