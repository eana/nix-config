{
  lib,
  stdenvNoCC,
  fetchurl,
  bun,
}:
let
  plugin = fetchurl {
    url = "https://registry.npmjs.org/opencode-history-search/-/opencode-history-search-1.5.1.tgz";
    hash = "sha256-WcoH7orODxmdG0vNA0oeHYDm4uj3519WY0nA23vJnjk=";
  };
  zod = fetchurl {
    url = "https://registry.npmjs.org/zod/-/zod-4.6.2.tgz";
    hash = "sha256-7kaQFILCZLz4onCp/7Bxo+XnuigzSkyPqDt0BaicRSY=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "opencode-history-search";
  version = "1.5.1";

  nativeBuildInputs = [
    bun
  ];

  src = plugin;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/opencode-history-search
    cp -r . $out/lib/opencode-history-search/

    # HACK: the published bundle imports `@opencode-ai/plugin` at runtime (for the
    # `tool` helper, which is an identity fn whose `schema` is zod) and opencode
    # resolves bare package imports via node_modules lookups from the plugin
    # directory. A bare tarball copy into the nix store has no node_modules, so
    # the import only succeeds if `@opencode-ai/plugin` happens to be in bun's
    # global install cache. Vendor zod (self-contained, zero deps) plus a shim
    # for `@opencode-ai/plugin` that is byte-identical to the real package's
    # dist/index.js + dist/tool.js. TODO: drop the shim and zod once upstream
    # bundles its deps, these packages land in nixpkgs, or the plugin drops the
    # import. https://github.com/joeyism/opencode-history-search
    mkdir -p $out/lib/opencode-history-search/node_modules/zod
    tar -xzf ${zod} --strip-components=1 -C $out/lib/opencode-history-search/node_modules/zod

    mkdir -p $out/lib/opencode-history-search/node_modules/@opencode-ai/plugin/dist
    cat > $out/lib/opencode-history-search/node_modules/@opencode-ai/plugin/dist/tool.js <<'EOF'
    import { z } from "zod";
    export function tool(input) {
        return input;
    }
    tool.schema = z;
    EOF
    cat > $out/lib/opencode-history-search/node_modules/@opencode-ai/plugin/dist/index.js <<'EOF'
    export * from "./tool.js";
    EOF
    cat > $out/lib/opencode-history-search/node_modules/@opencode-ai/plugin/package.json <<EOF
    {
      "name": "@opencode-ai/plugin",
      "version": "1.18.30",
      "type": "module",
      "main": "./dist/index.js",
      "exports": {
        ".": {
          "types": "./dist/index.d.ts",
          "import": "./dist/index.js"
        }
      }
    }
    EOF

    # Load-check under bun: copies into the sandbox workdir because bun's eval
    # sandbox restricts reads to paths inside the current project root, which
    # the store output (still a /nix/store bind during build) is not.
    mkdir -p $TMPDIR/ohs-check
    cp -r $out/lib/opencode-history-search/. $TMPDIR/ohs-check/
    cd $TMPDIR/ohs-check
    ${bun}/bin/bun -e '
      import("./dist/history-search.ts").then(function () {
        console.log("opencode-history-search load check OK");
        process.exit(0);
      }).catch(function (e) {
        console.error(e);
        process.exit(1);
      });
    '

    runHook postInstall
  '';

  meta = {
    description = "OpenCode tool to search conversation history (keyword, regex, fuzzy, multi-term, file trace)";
    homepage = "https://github.com/joeyism/opencode-history-search";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
