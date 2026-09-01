{
  pkgs,
  lib,
  enableSnip ? false,
  enableCopilotAutoModel ? false,
  copilotAutoModelAutos ? [ ],
  enableGsd ? false,
  gsdPlugin ? null,
}:
let
  inherit (pkgs) callPackage;
  # HACK: context-mode isn't in nixpkgs-darwin (stable) yet, only nixpkgs
  # (unstable). Fall back to our own package on hosts using the stable
  # branch. Remove local package + fallback once context-mode lands in
  # nixpkgs-darwin.
  context-mode = pkgs.context-mode or (callPackage ./packages/context-mode.nix { });
  opencode-snip = callPackage ./packages/opencode-snip.nix { };
  opencode-github-copilot-auto-model =
    callPackage ./packages/opencode-github-copilot-auto-model.nix
      { };
  copilotAutoModelEntry =
    if copilotAutoModelAutos != [ ] then
      [
        "${opencode-github-copilot-auto-model}/lib/opencode-github-copilot-auto-model"
        { autos = copilotAutoModelAutos; }
      ]
    else
      "${opencode-github-copilot-auto-model}/lib/opencode-github-copilot-auto-model";
in
{
  plugin = [
    "${context-mode}/lib/context-mode"
  ]
  ++ lib.optionals enableSnip [
    "${opencode-snip}/lib/opencode-snip"
  ]
  ++ lib.optionals enableCopilotAutoModel [
    copilotAutoModelEntry
  ]
  ++ lib.optionals enableGsd [
    gsdPlugin
  ];
}
