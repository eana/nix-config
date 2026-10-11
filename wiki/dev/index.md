---
generated_commit: ef4c8823581f45a9dadf2046c37c739f96352523
generated_at: 2026-10-11T08:44:01Z
source_paths:
  - dev
---

# dev

Development tooling: devshell, formatters, pre-commit hooks, the version-pin checker, the
repo-wiki tools, and a repl helper.

## dev/flake-module.nix

Imports `inputs.dev-flake.flakeModule`, sets `dev.name = "devbox"`, and in `perSystem`:

- `_module.args.pkgs = import inputs.nixpkgs { inherit system; config.allowUnfree = true; }`.
  The comment says this must be a module argument, not a let binding, so dev-flake's
  devshell submodule resolves pkgs through the module system.
- `version-check` (let binding):
  `writeShellScriptBin "version-check" ''exec ${pkgs.python3}/bin/python3 ${./version-check.py} "$@"''`.
- `repo-wiki` (let binding):
  `pkgs.callPackage ../modules/common/opencode/packages/repo-wiki.nix { }` - the same
  package the opencode Home Manager module installs, so the devshell can index this repo.
- `treefmt = import ./treefmt.nix { inherit pkgs; }`,
  `pre-commit = import ./pre-commit.nix { inherit pkgs version-check; }`.
- `packages`: `agenix` (from the agenix input), `pre-commit`
  (`config.pre-commit.settings.package`), `pre-commit-install`
  (`prek install -f --hook-type pre-commit --hook-type pre-push`), `version-check`,
  `repo-wiki`, plus `nixbox` and `nasbox` on x86_64-linux or `macbox` otherwise.
- `apps.formatter` - runs `${config.treefmt.build.wrapper}/bin/treefmt`, because the
  flake-parts `formatter` output cannot be used with `nix run`.
- `devshells.default`:
  - the pre-commit installation script is wrapped in `mkForce` with `" install -c "`
    replaced by `" install -f -c "`;
  - `NIX_USER_CONF_FILES = ./nix.conf`;
  - packages deadnix, nixfmt, nix-prefetch-github, python3, statix, `version-check`,
    `repo-wiki`, and cachix on x86_64-linux;
  - commands `repl` (`nix repl --file` on `repl.nix`) and `pre-commit` (execs `prek`).

## dev/treefmt.nix

`keep-sorted`, `mdformat`, `nixfmt`, `stylua` (spaces, width 2). `mdformat` excludes
`**/SKILL.md` and `wiki/**/*.md` because it misparses their YAML frontmatter as horizontal
rules.

## dev/pre-commit.nix

`package = mkForce pkgs.prek`. Hooks: `check-json`, `check-xml`, `end-of-file-fixer`
(excluding `\.age$`), `check-merge-conflict` (`types = [ "text" ]`), and `version-check`
(`<store path>/bin/version-check --hook`, `pass_filenames = false`, `always_run = true`,
stage `pre-push`). `conform` is disabled.

## dev/version-check.py

Finds and updates version pins in `**/*.nix` under `modules`, `home`, `configurations` and
`hosts` (relative to the git root). Pins elsewhere, such as `dev/` and `flake.nix`, are not
scanned. `EXCLUDES = [("anomalyco", "opencode")]`.

- `fetchFromGitHub` blocks: `rev` matching `^v[0-9]` or starting with `release-` is a
  release (latest = reverse string sort of `git ls-remote --tags`, not semver-aware); a
  40-character hex `rev` is a commit (latest = `git ls-remote <url> HEAD`); other formats
  and `#` revs are skipped.
- npm pins from `registry.npmjs.org/<pkg>/-/<pkg>-<ver>.tgz` URLs (with `pname` / `version`
  interpolation); latest from the registry `latest` endpoint.
- Up to 16 concurrent queries; 15 s timeouts.
- Updates prefetch with `nix-prefetch-github` / `nix-prefetch-url`, convert to SRI with
  `nix hash convert`, and rewrite the rev/version and hash.
- Modes: `--check` (implies dry run, exit 1 if outdated), `--hook` (writes, exit 1 if it
  updated anything), `-n/--dry-run`, or no flag (writes, exit 0). `--check` and `--hook` are
  mutually exclusive. Query errors are warnings only.

## dev/repl.nix

Loads the flake with `builtins.getFlake (toString ../.)` and returns it extended with
`b = builtins`, `system` (default `builtins.currentSystem`), `lib`, `pkgs`
(`legacyPackages.${system}`) and `inputs`.

## dev/nix.conf

`experimental-features = nix-command flakes`. Also used as `extraOptions` by
`hosts/shared/nix` and `hosts/nasbox/nix`.

## Related pages

- [configurations](../configurations/index.md)
- [modules/common](../modules-common/index.md) - defines the `repo-wiki` package.
