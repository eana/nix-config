______________________________________________________________________

title: Flake Root
generated_commit: b9ee706915c5dfd42b98ba9de6c553e1df8a2c8d
source_paths:

- flake.nix
- lib.nix
- .envrc
- README.md

______________________________________________________________________

# Flake Root

Entry point of the repository. `flake.nix` declares 16 inputs, sets up flake-parts,
and assembles outputs from `configurations/{macbox,nasbox,nixbox}/flake-module.nix`
and `dev/flake-module.nix`.

## Key files

| File | Role |
| --- | --- |
| `flake.nix` | Inputs, flake-parts entry, nixConfig substituters, `flake.homeModules` export |
| `lib.nix` | Single helper `modulesFromDir`: directory -> attrset of imported modules |
| `.envrc` | direnv: `use flake`, `unset IN_NIX_SHELL` |
| `README.md` | Install runbooks: Linux disko install, macOS nix-darwin + agenix re-key, Synology setup |
| `flake.lock` | Pinned dependency graph (27 nodes) |

## Inputs

- `nixpkgs` (nixos-unstable) is the single source of truth; followed by
  `dev-flake`, `agenix`, `home-manager`, `nix-darwin`, `nix-index-database`,
  `pyproject-nix`, `pyproject-build-systems`, `uv2nix` (flake.nix:9,22,32,52,59,67,73,79).
- `flake-parts` pinned but `nixpkgs-lib` overridden to nix-community/nixpkgs.lib (flake.nix:17);
  `dev-flake` follows flake-parts too (flake.nix:10).
- Own pins (no follow): `disko`, `nixvim`, `nix-homebrew`.
- Non-flake inputs (`flake = false`): `homebrew-cask`, `homebrew-core`, `nikitabobko-tap`
  (brew taps consumed by nix-homebrew).

## flake-parts structure

- `systems = ["x86_64-linux" "aarch64-darwin"]` (flake.nix:94-97).
- Imports: `dev/flake-module.nix` plus the three host modules (flake.nix:99-104).
- `_module.args.eanaLib` (flake.nix:106) extends nixpkgs lib with `eana` (defined at flake.nix:90).
- `flake.homeModules = eana.modulesFromDir ./modules/common` (flake.nix:91,108-110).
- Per-system `packages.<system>.<host>` come from `dev/flake-module.nix`, not here.

## lib.nix

`modulesFromDir dir`:

- Recursively lists files, keeps only `*/default.nix` at depth exactly one under `dir`
  (lib.nix:8-18). Root `default.nix` and nested subdirectories are excluded - nested
  module dirs (for example `nixvim/plugins/`) must be imported by hand.
- Directory name converted from kebab-case to camelCase as the attrset key (lib.nix:20-37).

## Notable patterns

- Comment at flake.nix:27-29: home-manager tracks unstable deliberately; macbox
  decouples HM package versions from nixpkgs via `useGlobalPkgs`.
- `nixConfig.extraSubstituters`: cache.nixos.org, eana.cachix.org,
  nix-community.cachix.org (flake.nix:113-116).
- README documents agenix host-key re-key plus `launchctl kickstart` recovery for
  launchd races, and the NAS static nix-installer flow.

## Related pages

- [dev](../dev/index.md)
- [hosts](../hosts/index.md)
