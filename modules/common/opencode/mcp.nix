{
  lib,
  pkgs,
  enablePlaywright ? false,
  playwrightUserDataDir ? null,
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
    enabled = false;
  };

  opentofu = optionalAttrs (pkgs ? opentofu-mcp-server) {
    command = "${pkgs.opentofu-mcp-server}/bin/opentofu-mcp-server";
    enabled = false;
  };

  playwright = optionalAttrs (enablePlaywright && pkgs ? playwright-mcp) {
    command = "${pkgs.playwright-mcp}/bin/playwright-mcp";
    enabled = false;
    # HACK: playwright-mcp defaults to a user-data-dir derived from its
    # own package path under /nix/store, which is read-only, causing an
    # EACCES on launch. Point it at a writable directory instead.
    # Upstream: no upstream issue filed.
    # TODO: remove once playwright-mcp defaults to a writable location
    # (e.g. via os.tmpdir()) without needing --user-data-dir.
    args = lib.optionals (playwrightUserDataDir != null) [
      "--user-data-dir"
      playwrightUserDataDir
    ];
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
}
