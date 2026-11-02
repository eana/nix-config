{
  lib,
  stdenv,
  fetchFromGitHub,
  gnumake,
  zlib,
}:

stdenv.mkDerivation {
  pname = "codebase-memory-mcp";
  version = "0.12.1";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "DeusData";
    repo = "codebase-memory-mcp";
    rev = "a5b248f47272413189746589b9a2c551c6b6c5ec";
    hash = "sha256-MA7ZkfL9Zwni/sGOczSZORsFD/kI5wgI2HETDV6S/eg=";
  };

  nativeBuildInputs = [ gnumake ];
  buildInputs = [ zlib ];

  buildPhase = ''
    # HACK: upstream enables mimalloc's global malloc/free override on Linux.
    # With glibc 2.44 its newlocale calls mi_free on a pointer mimalloc does not
    # own, so libstdc++ global init SIGSEGVs before main. Keep the override off;
    # CBM's bound sqlite/tree-sitter allocators still use mimalloc.
    # TODO: remove once mimalloc supports glibc 2.44.
    make -j$NIX_BUILD_CORES -f Makefile.cbm cbm \
      MIMALLOC_OVERRIDE_DEFINE= \
      GLOBAL_OVERRIDE_DEFINE=
  '';

  installPhase = ''
    install -Dm755 build/c/codebase-memory-mcp $out/bin/codebase-memory-mcp
  '';

  meta = {
    description = "MCP server that builds and queries a semantic graph of your codebase";
    homepage = "https://github.com/DeusData/codebase-memory-mcp";
    license = lib.licenses.mit;
    mainProgram = "codebase-memory-mcp";
    platforms = lib.platforms.unix;
  };
}
