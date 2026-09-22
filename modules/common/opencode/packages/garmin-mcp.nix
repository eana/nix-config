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
    rev = "6fe000e18cefcbbf7761d16495a0f8fda7aff764";
    hash = "sha256-GhfGnhr98QyBouV4P3fmLMc/x3xaVHfJnnYx+0tc9Pg=";
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

  pythonSet =
    (pkgs.callPackage pyproject-nix.build.packages {
      inherit python;
    }).overrideScope
      (
        lib.composeManyExtensions [
          pyproject-build-systems.overlays.default
          overlay
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
