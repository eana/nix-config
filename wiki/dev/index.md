---
generated_commit: 06cd74bc677d19a9e44814ed8572eab31dbcd7f9
generated_at: 2026-10-30T09:19:38Z
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
  `pkgs.callPackage ../modules/common/opencode/packages/repo-wiki { }` - the same package
  the opencode Home Manager module installs, so the devshell can index this repo.
- `treefmt = import ./treefmt.nix { inherit pkgs; }`,
  `pre-commit = import ./hooks.nix { inherit pkgs lib version-check; }`.
- `packages`: `agenix` (from the agenix input), `pre-commit`
  (`config.pre-commit.settings.package`), `pre-commit-install`
  (`prek install -f --hook-type pre-commit --hook-type pre-push --hook-type commit-msg`),
  `version-check`, `repo-wiki`, plus `nixbox` and `nasbox` on x86_64-linux or `macbox`
  otherwise.
- `apps.formatter` - runs `${config.treefmt.build.wrapper}/bin/treefmt`, because the
  flake-parts `formatter` output cannot be used with `nix run`.
- `devshells.default`:
  - the pre-commit installation script is wrapped in `mkForce` with `" install -c "`
    replaced by `" install -f -c "`;
  - `NIX_USER_CONF_FILES = ./nix.conf`;
  - packages `cachix`, `deadnix`, `nixfmt`, `nix-prefetch-github`, `python3`, `statix`,
    plus `version-check` and `repo-wiki`. `cachix` is installed on every supported
    system, not just x86_64-linux;
  - commands `repl` (`nix repl --file` on `repl.nix`) and `pre-commit` (execs `prek`).

## dev/treefmt.nix

Programs (inside a `keep-sorted` block): `keep-sorted`, `mdformat` (with the
`mdformat-frontmatter` plugin), `nixfmt` (`pkgs.nixfmt`), and `stylua` (spaces, width 2).

`mdformat` excludes only `**/SKILL.md`. The frontmatter plugin keeps YAML frontmatter in
`wiki/` pages intact, so wiki pages are formatted rather than excluded. `SKILL.md` files
are still skipped because mdformat would reflow their bodies and re-serialize their
frontmatter.

## dev/hooks.nix

`package = mkForce pkgs.prek`. The file was named `dev/pre-commit.nix` before the
`chore(dev): rename pre-commit hook module` commit. Hooks:

- `check-json`, `check-xml`, `end-of-file-fixer` (excluding `\.age$`), and
  `check-merge-conflict` (`entry` is `check-merge-conflict` from
  `pkgs.python312Packages.pre-commit-hooks`, `types = [ "text" ]`).
- `conform` - enabled, running on `commit-msg`. Rules live in `.conform.yaml` at the repo
  root: conventional commits with types `feat`, `fix`, `build`, `chore`, `ci`, `docs`,
  `perf`, `refactor`, `style`, `test`; scopes `module`, `deps`, `devshell`,
  `configurations`, `home`, `hosts`, `secrets`, `assets`, `flake`; header length 60,
  lowercase, imperative, no trailing period; description length 60.
- `version-check` - `entry = "${version-check}/bin/version-check --hook"`,
  `pass_filenames = false`, `always_run = true`, stage `pre-push`.
- `d2-render` - matches `(^|/)diagrams/.*\.d2$`. A `writeShellApplication` loops over the
  files and runs `d2 --layout elk --sketch --theme 1 "$file"`, then `chmod 644` on the
  sibling `.svg` because d2 writes SVGs with mode 0600. Both the `.d2` and rendered
  `.svg` are committed.

## dev/version-check.py

Finds and updates version pins in `**/*.nix` under `modules`, `home`, `configurations`
and `hosts` (relative to the git root). Pins elsewhere, such as `dev/` and `flake.nix`,
are not scanned. `EXCLUDES = [("anomalyco", "opencode")]`.

- `fetchFromGitHub` blocks: `rev` matching `^v[0-9]` or starting with `release-` is a
  release (latest = reverse string sort of `git ls-remote --tags`, not semver-aware); a
  40-character hex `rev` is a commit (latest = `git ls-remote <url> HEAD`); other formats
  and `#` revs are skipped. Block matching tolerates one level of nested braces so Nix
  interpolations do not truncate the match before the hash.
- npm pins from `registry.npmjs.org/<pkg>/-/<pkg>-<ver>.tgz` URLs in `fetchurl` blocks.
  `${pname}` / `${version}` interpolation is resolved from the surrounding Nix text;
  latest comes from the registry `latest` endpoint.
- Up to 16 concurrent queries; 15 s timeouts.
- Updates prefetch with `nix-prefetch-github` / `nix-prefetch-url`, convert to SRI with
  `nix hash convert`, then rewrite only the nearest matching rev/version and hash block.
- Modes: `--check` (implies dry run, never writes, exit 1 if any pin is outdated),
  `--hook` (writes, exit 1 if it updated anything), `-n/--dry-run` (report only), or no
  flag (writes, exit 0). `--check` and `--hook` are in a mutually exclusive group. Query
  and hash errors are reported but never block a push.

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
