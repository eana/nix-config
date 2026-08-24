{ lib, pkgs }:
let
  inherit (lib) filterAttrs optionalAttrs;
  inherit (pkgs) callPackage;
  mcp-nixos = callPackage ./packages/mcp-nixos.nix { };
in
filterAttrs (_n: v: v != { }) {
  k8s = optionalAttrs (pkgs ? mcp-k8s-go) {
    command = "${pkgs.mcp-k8s-go}/bin/mcp-k8s-go";
    enabled = false;
  };

  nix = {
    command = "${mcp-nixos}/bin/mcp-nixos";
  };

  opentofu = optionalAttrs (pkgs ? opentofu-mcp-server) {
    command = "${pkgs.opentofu-mcp-server}/bin/opentofu-mcp-server";
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

  "context-mode" = {
    command = "${pkgs.context-mode}/bin/context-mode";
  };
}
