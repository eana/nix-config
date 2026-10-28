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
    rev = "dca2a44ef0c514384d297410fd05fd8335a4d5b5";
    hash = "sha256-z0Og9yRYKCn36Nligl+TXs3xj43kHMOxjnLN8J2O6dI=";
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
