{
  lib,
  stdenv,
  fetchurl,
  bun,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "context-mode";
  version = "1.0.111";

  src = fetchurl {
    url = "https://registry.npmjs.org/context-mode/-/context-mode-${finalAttrs.version}.tgz";
    hash = "sha256-OII8myKKxQtlo6L4JcTR27FrYTKsg4YNow5hpgrP3V8=";
  };

  nativeBuildInputs = [
    bun
    makeWrapper
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # The npm tarball unpacks into "package/" and unpackPhase cds into it,
    # so the working directory here is already the package root.
    mkdir -p $out/lib/context-mode
    cp -r . $out/lib/context-mode/

    mkdir -p $out/bin
    # Use bun as the runtime so globalThis.Bun is set at startup, which causes
    # db-base.js to use bun:sqlite instead of better-sqlite3 (unavailable in
    # nixpkgs). The server.bundle.mjs shebang says "node" but we override here.
    makeWrapper ${bun}/bin/bun $out/bin/context-mode \
      --add-flags "$out/lib/context-mode/server.bundle.mjs"

    runHook postInstall
  '';

  meta = {
    description = "Context window optimization MCP server for AI coding agents";
    homepage = "https://github.com/mksglu/context-mode";
    # Elastic License v2 — source-available, not OSI open source
    license = lib.licenses.elastic20;
    mainProgram = "context-mode";
  };
})
