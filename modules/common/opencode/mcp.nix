{
  lib,
  pkgs,
  gsdMcpBin ? null,
}:
let
  inherit (lib) filterAttrs optionalAttrs;
  inherit (pkgs) callPackage;
  mcp-nixos = callPackage ./packages/mcp-nixos.nix { };
  # HACK: context-mode isn't in nixpkgs-darwin (stable) yet, only nixpkgs
  # (unstable). Fall back to our own package on hosts using the stable
  # branch. Remove local package + fallback once context-mode lands in
  # nixpkgs-darwin.
  context-mode = pkgs.context-mode or (callPackage ./packages/context-mode.nix { });
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
    command = "${context-mode}/bin/context-mode";
  };

  gsd = optionalAttrs (gsdMcpBin != null) {
    command = gsdMcpBin;
  };
}
