{
  pkgs,
  lib,
  enableSnip ? false,
}:
let
  inherit (pkgs) callPackage;
  context-mode = callPackage ./packages/context-mode.nix { };
  opencode-snip = callPackage ./packages/opencode-snip.nix { };
in
{
  plugin = [
    "${context-mode}/lib/context-mode"
  ]
  ++ lib.optionals enableSnip [
    "${opencode-snip}/lib/opencode-snip"
  ];
}
