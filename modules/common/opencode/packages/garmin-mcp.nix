{
  lib,
  pkgs,
  fetchFromGitHub,
  uv2nix,
  pyproject-nix,
  pyproject-build-systems,
}:
let
  src = fetchFromGitHub {
    owner = "Taxuspt";
    repo = "garmin_mcp";
    rev = "655efb8f5639602f661c26164282d0ddd4f5d3db";
    hash = "sha256-EhiJOcQfhYjccFkIfywhdcmKbmmT2Kd112gjLkbQA8Q=";
  };

  workspace = uv2nix.lib.workspace.loadWorkspace {
    workspaceRoot = src;
    # HACK: upstream uv.lock records only an sdist for fitparse (no wheel),
    # and fitparse is a legacy setup.py-only project with no declared
    # build-system. uv's sdist build then can't import setuptools and fails
    # with ModuleNotFoundError. Mirror uv's own hint by declaring setuptools
    # as an extra build dependency.
    # TODO: Remove once upstream lock ships a fitparse wheel entry or a
    # pyproject.toml build-system.
    config = {
      extra-build-dependencies = {
        fitparse = [
          { requirement = pyproject-nix.lib.pep508.parseString "setuptools"; }
        ];
      };
    };
  };

  # HACK: garmin_mcp's own uv.lock prefers wheels; some transitive deps
  # (mcp -> pydantic-core, cryptography via garminconnect) need compiled
  # artifacts. wheel sourcePreference avoids building them from sdist in
  # the sandbox. TODO: revisit if upstream locks new sdists-only deps.
  overlay = workspace.mkPyprojectOverlay { sourcePreference = "wheel"; };

  python = pkgs.python3;

  hacks = pkgs.callPackage pyproject-nix.build.hacks { };

  # HACK: cryptography uses maturin (Rust) as its build backend, but PyPI
  # has no prebuilt wheel for x86_64-darwin on this nixpkgs/Python
  # combination, so uv2nix falls back to a source build. That source build
  # needs maturin's own transitive build deps (maturin itself, then
  # puccinialin) which pyproject-nix's package set can't resolve, breaking
  # the build on darwin only (see the CI run that surfaced this: nixbox
  # built fine, macbox didn't, because Linux had a usable wheel and darwin
  # didn't).
  # Substitute nixpkgs' own prebuilt cryptography instead of letting
  # uv2nix build it from PyPI at all. Nixpkgs already builds and caches
  # cryptography for every platform we target (darwin included), so this
  # sidesteps the maturin/puccinialin resolution gap entirely, requires no
  # network at build time, and inherits nixpkgs' own version/security
  # update cadence instead of us needing to track a separate pin.
  # TODO: Drop this override if uv2nix/pyproject-nix ever gains a way to
  # resolve maturin's transitive build deps for source builds on darwin.
  pyprojectOverrides = _final: prev: {
    cryptography = hacks.nixpkgsPrebuilt {
      from = pkgs.python3Packages.cryptography;
      prev = prev.cryptography;
    };
  };

  pythonSet =
    (pkgs.callPackage pyproject-nix.build.packages {
      inherit python;
    }).overrideScope
      (
        lib.composeManyExtensions [
          pyproject-build-systems.overlays.default
          overlay
          pyprojectOverrides
        ]
      );

  venv = pythonSet.mkVirtualEnv "garmin-mcp" workspace.deps.default;
in
venv.overrideAttrs (old: {
  meta = (old.meta or { }) // {
    description = "MCP server to access Garmin Connect data";
    homepage = "https://github.com/Taxuspt/garmin_mcp";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "garmin-mcp";
  };
})
