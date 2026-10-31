{
  pkgs,
  lib,
  enableSnip ? false,
  enablePonytail ? false,
}:
let
  inherit (pkgs) callPackage;
  opencode-snip = callPackage ./packages/opencode-snip { };
  ponytail = callPackage ./packages/ponytail { };
in
{
  # context-mode is not listed here: its plugin uses the V1 API, which
  # OpenCode V2 does not run. It is wired as an MCP server in mcp.nix instead.
  # Do not re-add it alongside the MCP entry - context-mode then serves an
  # empty tool list (upstream #623).
  #
  # opencode-github-copilot-auto-model is also not listed: it exports only the
  # V1 API { server } instead of V2's { setup }. OpenCode V2 rejects v1-only
  # plugins at load time. The plugin is unmaintained; PR #13 (v2 port) is open
  # but not merged (see github.com/m0wer/opencode-github-copilot-auto-model/issues/10).
  # TODO: remove this comment and re-add copilotAutoModel when upstream ships
  # v2 support or a working fork is adopted.
  plugin =
    lib.optionals enableSnip [
      "${opencode-snip}/lib/opencode-snip"
    ]
    ++ lib.optionals enablePonytail [
      "${ponytail}/.opencode/plugins"
    ];
}
