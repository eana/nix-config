{
  lib,
  pkgs,
  enablePlaywright ? false,
  enableGarmin ? false,
}:
let
  inherit (lib) filterAttrs optionalAttrs;
  inherit (pkgs) callPackage;
  # HACK: context-mode isn't in nixpkgs-darwin (stable) yet, only nixpkgs
  # (unstable). Fall back to our own package on hosts using the stable
  # branch. Remove local package + fallback once context-mode lands in
  # nixpkgs-darwin.
  context-mode = pkgs.context-mode or (callPackage ./packages/context-mode.nix { });
  garmin-mcp = callPackage ./packages/garmin-mcp.nix { };
in
filterAttrs (_n: v: v != { }) {
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

  "context-mode" = {
    command = "${context-mode}/bin/context-mode";
  };

  garmin = optionalAttrs enableGarmin {
    command = "${garmin-mcp}/bin/garmin-mcp";
    enabled = false;
  };
}
