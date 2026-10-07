______________________________________________________________________

title: Dev Tooling
generated_commit: b9ee706915c5dfd42b98ba9de6c553e1df8a2c8d
source_paths:

- dev/
- .github/workflows/ci.yml
- renovate.json5

______________________________________________________________________

# Dev Tooling

Devshell, formatting, pre-commit hooks, pin checker, CI, and Renovate config.
`dev/flake-module.nix` imports terlar/dev-flake and defines packages plus the
devshell per system.

## Key files

| File | Role |
| --- | --- |
| `dev/flake-module.nix` | Devshell, packages (agenix, version-check, pre-commit-install), treefmt/pre-commit wiring, per-system host builds |
| `dev/nix.conf` | Enables `nix-command flakes`; injected via `NIX_USER_CONF_FILES` in devshell |
| `dev/pre-commit.nix` | Hook list; forces `prek` as hook package runner |
| `dev/repl.nix` | Nix repl prelude binding `self`, `b`, `system`, `lib`, `pkgs`, `inputs` |
| `dev/treefmt.nix` | Formatters: keep-sorted, mdformat, nixfmt, stylua (2-space) |
| `dev/version-check.py` | Scans/updates hardcoded version pins in `.nix` files |
| `.github/workflows/ci.yml` | CI jobs |
| `renovate.json5` | Dependency bot config |

## Devshell

Packages: deadnix, nixfmt, nix-prefetch-github, python3, statix, version-check;
cachix on x86_64-linux only. Commands: `repl` (nix repl with flake context),
`pre-commit` (prek alias). Startup script is patched by string replace to pass
`-f` (force reinstall hooks). Env: `NIX_USER_CONF_FILES -> dev/nix.conf`.

## CI pipeline

1. `pre-commit` (ubuntu): install Nix 2.33.0, `prek run --all-files`,
   `version-check --check`.
1. `changes` (ubuntu): dorny/paths-filter with per-host path filters
   (nixbox/macos/nasbox).
1. `build-nixbox` (ubuntu), `build-macbox` (macos), `build-nasbox` (ubuntu):
   gated on filter output or workflow_dispatch; cachix-action (cache `eana`),
   nixbox frees disk space first, then `nix build` of toplevel / darwin system /
   activationPackage.

## Hooks and formatters

- pre-commit hooks: check-json, check-xml, end-of-file-fixer (excludes `*.age`),
  check-merge-conflict, version-check (pre-push stage, always_run, exit 1 if
  updated). conform disabled.
- treefmt: keep-sorted, mdformat (excludes `**/SKILL.md` due to YAML frontmatter),
  nixfmt, stylua.

## version-check.py

Scans `modules`, `home`, `configurations`, `hosts` for `fetchFromGitHub` rev pins
(`v*` tag = release, 40-char sha = commit) and npm `fetchurl` pins.
`EXCLUDES` skips `anomalyco/opencode`. Queries upstream via `git ls-remote` /
npm registry with a ThreadPoolExecutor (max 16). Modes: `--dry-run` report,
`--check` exits 1 if outdated (CI), `--hook` rewrites pins then exits 1 if files
changed. Query errors never block.

## Renovate

Extends recommended config, semantic commits, pinned action digests, weekday
schedule. Reviewer @eana, label `dependencies`, platform automerge. Groups with
automerge: minor/patch, pre-commit-hooks (incl. major), GitHub Actions. Weekly
lockFileMaintenance. `nix: { enabled: true }`.

## Notable patterns

- HACK comment in `dev/flake-module.nix`: must set `_module.args.pkgs` via a fresh
  `import inputs.nixpkgs` (allowUnfree) instead of the module `pkgs` parameter, so
  dev-flake submodules resolve pkgs through the module system.
- Packages merged with `//` conditional: x86_64-linux gets nasbox/nixbox, else
  macbox (mutually exclusive).
- flake-parts `formatter.<system>` is not runnable via `nix run`, so it is exported
  as `apps.formatter` instead.

## Related pages

- [flake-root](../flake-root/index.md)
