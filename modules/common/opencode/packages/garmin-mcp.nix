{
  lib,
  pkgs,
  stdenvNoCC,
  fetchFromGitHub,
  uv,
  makeWrapper,
}:

stdenvNoCC.mkDerivation rec {
  pname = "garmin-mcp";
  # Static; not derived from `rev` below. garmin_mcp has no release tags,
  # so this just mirrors the version string in its own pyproject.toml.
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "Taxuspt";
    repo = "garmin_mcp";
    rev = "655efb8f5639602f661c26164282d0ddd4f5d3db";
    hash = "sha256-EhiJOcQfhYjccFkIfywhdcmKbmmT2Kd112gjLkbQA8Q=";
  };
  nativeBuildInputs = [
    uv
    makeWrapper
  ];
  dontBuild = true;
  # HACK: uv resolves and downloads cryptography's wheel from PyPI at build
  # time instead of from a committed uv.lock, so this build is
  # network-dependent and non-hermetic. A prior attempt (29cedee) fixed
  # this via uv2nix + a committed lock, but that pipeline can't resolve
  # maturin's transitive build deps (maturin itself, then puccinialin)
  # when cryptography has no prebuilt wheel for the target platform, which
  # broke the build on x86_64-darwin with nixpkgs-26.05.
  # --only-binary cryptography forces a prebuilt wheel and skips the
  # maturin source build entirely; if PyPI has no matching wheel for the
  # target platform/interpreter, this install fails outright with no
  # fallback.
  #
  # Deliberately left unpinned (no requirements/hash lock for cryptography)
  # after evaluating the tradeoff: this is a single opt-in MCP server on
  # one host, failures are visible at build time (not silent/runtime), and
  # there is no historical incident of version drift causing a break here
  # (every prior break came from *adding* pinning, not from its absence).
  # Pinning without automated freshness tooling (dev/version-check.py only
  # scans fetchFromGitHub/fetchurl blocks, not Python requirement files)
  # would let the pin go stale indefinitely, which for a crypto library
  # risks missing upstream security fixes for longer than staying
  # unpinned. Not worth the added maintenance surface at this scale.
  #
  # TODO: Restore lockfile-pinned hermetic build once uv2nix/pyproject-nix
  # can resolve maturin's transitive build deps on darwin, or once
  # cryptography ships wheels covering all our target platforms.
  installPhase = ''
    ${uv}/bin/uv --cache-dir "$TMPDIR/uv-cache" pip install --only-binary cryptography --python ${pkgs.python3} --target $out/lib $src
    makeWrapper ${pkgs.python3}/bin/python3 $out/bin/garmin-mcp \
      --add-flags "-m garmin_mcp" \
      --prefix PYTHONPATH : $out/lib
  '';
  meta = {
    description = "MCP server to access Garmin Connect data";
    homepage = "https://github.com/Taxuspt/garmin_mcp";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "garmin-mcp";
  };
}
