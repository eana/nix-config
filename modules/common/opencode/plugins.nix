{
  pkgs,
  lib,
  enableSnip ? false,
  enableCopilotAutoModel ? false,
  copilotAutoModelAutos ? [ ],
  enablePonytail ? false,
}:
let
  inherit (pkgs) callPackage;
  opencode-snip = callPackage ./packages/opencode-snip { };
  ponytail = callPackage ./packages/ponytail { };
  opencode-github-copilot-auto-model = callPackage ./packages/opencode-github-copilot-auto-model { };
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
  # context-mode is not listed here: its plugin uses the V1 API, which
  # OpenCode V2 does not run. It is wired as an MCP server in mcp.nix instead.
  # Do not re-add it alongside the MCP entry - context-mode then serves an
  # empty tool list (upstream #623).
  plugin =
    lib.optionals enableSnip [
      "${opencode-snip}/lib/opencode-snip"
    ]
    ++ lib.optionals enableCopilotAutoModel [
      copilotAutoModelEntry
    ]
    ++ lib.optionals enablePonytail [
      "${ponytail}/.opencode/plugins"
    ];
}
