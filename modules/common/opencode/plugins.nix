{
  pkgs,
  lib,
  enableSnip ? false,
  enableCopilotAutoModel ? false,
  copilotAutoModelAutos ? [ ],
}:
let
  inherit (pkgs) callPackage;
  context-mode = callPackage ./packages/context-mode.nix { };
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
  ];
}
