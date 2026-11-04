{
  pkgs,
  lib,
  contextMode,
  enableContextMode ? false,
  enableSnip ? false,
  enablePonytail ? false,
}:
let
  inherit (pkgs) callPackage;
  opencode-snip = callPackage ./packages/opencode-snip { };
  ponytail = callPackage ./packages/ponytail { };
in
{
  # context-mode is loaded as a plugin only, never also as an MCP server -
  # it then serves an empty tool list (upstream #623).
  #
  # opencode-github-copilot-auto-model is also not listed: it exports only the
  # V1 API { server } instead of V2's { setup }. OpenCode V2 rejects v1-only
  # plugins at load time. The plugin is unmaintained; PR #13 (v2 port) is open
  # but not merged (see github.com/m0wer/opencode-github-copilot-auto-model/issues/10).
  # TODO: remove this comment and re-add copilotAutoModel when upstream ships
  # v2 support or a working fork is adopted.
  plugin =
    # OpenCode V2 only accepts directories here; a file path is rejected with
    # "configured plugin path must be a directory". Point at the package root:
    # its package.json exports resolve ./server to opencode/plugin.js.
    lib.optionals enableContextMode [
      "${contextMode}/lib/context-mode"
    ]
    ++ lib.optionals enableSnip [
      "${opencode-snip}/lib/opencode-snip"
    ]
    ++ lib.optionals enablePonytail [
      "${ponytail}/.opencode/plugins"
    ];
}
