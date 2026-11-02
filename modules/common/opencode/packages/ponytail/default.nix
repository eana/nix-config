{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation rec {
  pname = "ponytail";
  version = "5.3.2";
  src = fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    rev = "v${version}";
    hash = "sha256-IJlhfkdXI6pMZZCZO7XBRg88LBiNfzc5Gnm4ofGybL8=";
  };

  dontBuild = true;

  # Keep whole tree: ponytail.mjs resolves ../../hooks and ../../skills.
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r . $out/
    workaroundForOpencodePluginProbe
    runHook postInstall
  '';

  # HACK: opencode's plugin loader (packages/plugin/src/host.ts) probes the
  # server, tui, rpc and gui-experimental.cjs entrypoints and treats Bun's
  # ResolveMessage (not instanceof Error) for a missing file as fatal. That
  # aborts the whole plugin reload, taking built-in provider plugins such as
  # github-copilot down with it.
  # https://github.com/anomalyco/opencode/issues/48122
  # TODO: remove once a released opencode includes the fix.
  # server.mjs must re-export the real entry (an empty stub would shadow it);
  # tui/rpc/gui only need valid no-op plugins. The GUI entry is evaluated as
  # CommonJS, and gui-experimental.cjs stops the gui-experimental.js probe.
  preInstall = ''
    workaroundForOpencodePluginProbe() {
      local dir=$out/.opencode/plugins
      echo "export { default } from './index.js'" > $dir/server.mjs
      for entrypoint in tui rpc; do
        echo 'export default { id: "ponytail", setup: async () => {} }' \
          > "$dir/$entrypoint.mjs"
      done
      echo 'module.exports = { id: "ponytail", setup: async () => {} }' \
        > $dir/gui-experimental.cjs
    }
  '';

  meta = {
    description = "Lazy senior dev mode for AI agents, with OpenCode 2 plugin-loader workaround";
    homepage = "https://github.com/DietrichGebert/ponytail";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
