{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "opencode-github-copilot-auto-model";
  version = "0.2.0";
  src = fetchurl {
    url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-1IlIrofqGObNMsuV9WzZ10b9sO2RC6x8oQr0kvPSZQk=";
  };
  dontBuild = true;
  installPhase = ''
    workaroundForOpenCodeOptionalHookLoader() {
      # HACK: OpenCode 2.1.1 directory plugin loader probes optional
      # server/tui/rpc entrypoints and fails hard on missing paths, which
      # prevents plugin bootstrap. Keep plugin directory installable by adding
      # explicit entrypoints for those probes.
      # Link: https://github.com/anomalyco/opencode/issues/48122
      # TODO: remove this function when upstream loader treats missing optional
      # hook entrypoints as non-fatal and released version is in use.
      printf '%s\n' \
        "import pluginModule from './dist/index.js'" \
        "" \
        "const plugin = pluginModule?.default ?? pluginModule" \
        "const setup = plugin?.server" \
        "" \
        "export default {" \
        "  id: plugin?.id ?? 'opencode-github-copilot-auto-model'," \
        "  setup" \
        "}" \
        > $out/lib/opencode-github-copilot-auto-model/server.mjs

      printf '%s\n' \
        'export default {' \
        '  id: "opencode-github-copilot-auto-model",' \
        '  setup: async () => ({ })' \
        '}' \
        > $out/lib/opencode-github-copilot-auto-model/tui.mjs

      printf '%s\n' \
        'export default {' \
        '  id: "opencode-github-copilot-auto-model",' \
        '  setup: async () => ({ })' \
        '}' \
        > $out/lib/opencode-github-copilot-auto-model/rpc.mjs
    }

    mkdir -p $out/lib/opencode-github-copilot-auto-model
    cp -r . $out/lib/opencode-github-copilot-auto-model/

    workaroundForOpenCodeOptionalHookLoader
  '';
  meta = {
    description = "OpenCode plugin exposing GitHub Copilot's auto model routing";
    homepage = "https://github.com/m0wer/opencode-github-copilot-auto-model";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
