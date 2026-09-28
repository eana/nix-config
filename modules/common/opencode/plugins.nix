{
  pkgs,
  lib,
  contextMode,
  enableSnip ? false,
  enableCopilotAutoModel ? false,
  copilotAutoModelAutos ? [ ],
}:
let
  inherit (pkgs) callPackage;
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
    # plugin-function.mjs, not plugin.js: opencode's file-path plugin loader is
    # documented as calling the default export as a function, and
    # context-mode's is { id, server }. See packages/context-mode.nix for the
    # shims that make the entry importable, and interface.nix for the runtime
    # option ctx_execute needs on PATH.
    "${contextMode}/lib/context-mode/build/adapters/opencode/plugin-function.mjs"
  ]
  ++ lib.optionals enableSnip [
    "${opencode-snip}/lib/opencode-snip"
  ]
  ++ lib.optionals enableCopilotAutoModel [
    copilotAutoModelEntry
  ];
}
