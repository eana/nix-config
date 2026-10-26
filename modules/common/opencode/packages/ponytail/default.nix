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

  # HACK: opencode's plugin loader probes server/tui/rpc entrypoints and treats
  # Bun's ResolveMessage (not instanceof Error) for a missing file as fatal,
  # breaking the whole config bootstrap.
  # https://github.com/anomalyco/opencode/issues/48122
  # TODO: remove once a released opencode includes the fix.
  # server.mjs must re-export the real entry (an empty stub would shadow it);
  # tui/rpc only need valid no-op plugins.
  preInstall = ''
    workaroundForOpencodePluginProbe() {
      echo "export { default } from './index.js'" > $out/.opencode/plugins/server.mjs
      for entrypoint in tui rpc; do
        echo 'export default { id: "ponytail", setup: async () => {} }' \
          > "$out/.opencode/plugins/$entrypoint.mjs"
      done
    }
  '';

  meta = {
    description = "Lazy senior dev mode for AI agents, with OpenCode 2 plugin-loader workaround";
    homepage = "https://github.com/DietrichGebert/ponytail";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
