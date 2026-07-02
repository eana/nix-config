{ pkgs }:
let
  inherit (pkgs) callPackage;
  context-mode = callPackage ./packages/context-mode.nix { };
  opencode-snip = callPackage ./packages/opencode-snip.nix { };
in
{
  plugin = [
    "${context-mode}/lib/context-mode"
    "${opencode-snip}/lib/opencode-snip"
  ];
}
