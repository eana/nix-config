{
  lib,
  stdenv,
  fetchurl,
  bun,
  gnutar,
  installAgentSkills,
  makeWrapper,
}:

# Packaged locally rather than taken from pkgs.context-mode, which is stuck on
# 1.0.143 and omits build/adapters/opencode/plugin.js (its main/exports
# entry), so opencode never loads it. build/server.js is replaced below with
# a re-export of the pre-bundled server.bundle.mjs to avoid resolving the sdk
# tree; only zod stays vendored for real.
#
# HACK: zod pin must track context-mode's own package.json; nothing enforces
# that automatically here (nixpkgs does via update-zod.sh).
# TODO: replace with pkgs.context-mode once it ships a bundled plugin entry.
let
  zod = fetchurl {
    url = "https://registry.npmjs.org/zod/-/zod-4.6.5.tgz";
    hash = "sha256-p4wMUz3jDcHEr8JZrEOsBuOQyw2o0uMurjVTAbULNvw=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "context-mode";
  version = "1.0.169";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl {
    url = "https://registry.npmjs.org/context-mode/-/context-mode-${finalAttrs.version}.tgz";
    hash = "sha256-CcQeTPd7IVZsdrjqL9vX89gjBV/uLwLCFm/Vu1ddryw=";
  };

  sourceRoot = "package";

  nativeBuildInputs = [
    gnutar
    installAgentSkills
    makeWrapper
  ];

  dontBuild = true;

  # HACK: auto-glob installs every **/SKILL.md, hitting duplicate "context-mode"
  # skills under configs/*/skills/ (other agents' bundles) and hard-failing the
  # build. Scoped manually to skills/*/ below instead.
  # TODO: drop this and the loop if the setup hook gains an exclusion, or
  # context-mode stops shipping the duplicates.
  dontInstallAgentSkills = 1;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/context-mode
    cp -r \
      build \
      server.bundle.mjs \
      cli.bundle.mjs \
      package.json \
      LICENSE \
      README.md \
      bin \
      configs \
      hooks \
      scripts \
      skills \
      $out/lib/context-mode/

    # server.bundle.mjs is the bundled build of build/server.js (sdk/ajv
    # inlined, only node: builtins imported) - re-export it instead of
    # resolving the sdk tree.
    echo 'export * from "../server.bundle.mjs";' \
      > $out/lib/context-mode/build/server.js

    # HACK: opencode's file-path plugin loader is documented as calling the
    # default export as a function; context-mode's export is { id, server }.
    # Not reproduced in isolated testing (both shapes loaded fine), but the
    # wrapper is a harmless no-op if so, and a real fix if some opencode build
    # or invocation path needs it.
    # TODO: drop once confirmed unnecessary, or context-mode exports a function.
    cat > $out/lib/context-mode/build/adapters/opencode/plugin-function.mjs <<'EOF'
    import plugin from "./plugin.js";

    export default async (input) => plugin.server(input);
    EOF

    # zod is the plugin's one remaining bare import (zod3tov4.js). Bun
    # resolves it by walking up from the importing file, so a node_modules
    # dir beside build/ suffices; unpacked rather than symlinked since
    # fetchurl yields a tarball, not a loadable module directory.
    mkdir -p $out/lib/context-mode/node_modules/zod
    tar -xzf ${zod} --strip-components=1 -C $out/lib/context-mode/node_modules/zod
    # Payload self-references as "context-mode/plugin", resolvable only from
    # inside a node_modules directory.
    ln -s $out/lib/context-mode $out/lib/context-mode/node_modules/context-mode

    # The eight real agent skills (see dontInstallAgentSkills above).
    for skill in skills/*/; do installSkill "$skill"; done

    mkdir -p $out/bin
    # bun as the runtime so globalThis.Bun is set, making db-base.js use
    # bun:sqlite instead of better-sqlite3 (unavailable in nixpkgs).
    makeWrapper ${bun}/bin/bun $out/bin/context-mode \
      --add-flags "$out/lib/context-mode/server.bundle.mjs" \
      --prefix PATH : ${lib.makeBinPath [ bun ]}

    runHook postInstall
  '';

  meta = {
    description = "Context window optimization plugin and MCP server for AI coding agents";
    homepage = "https://github.com/mksglu/context-mode";
    license = lib.licenses.elastic20;
    platforms = lib.platforms.all;
    mainProgram = "context-mode";
  };
})
