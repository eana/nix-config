---
name: nix-check
description: Use this before committing, pushing, or opening a PR for changes to this Nix config repo. It defines the validation sequence: nix fmt, then the pre-commit hooks (prek run --all-files), then nix flake check, plus the per-host nix build target to verify (hosts under hosts/, e.g. nixbox). Load it whenever the user asks to run checks, format and lint, validate the build, run pre-commit hooks, verify a host config, or asks 'is my branch ready' or 'what should I verify before I push'. Also when they changed flake.nix, host configs, or modules/ and want assurance everything still evaluates and builds. Do not use it for writing or reviewing Nix code style, debugging why a build failed, explaining how nix flake check works, or questions about repo structure.
compatibility: opencode
---

## Validation checklist

Run these in order before considering a change complete:

1. `nix fmt` - format and lint everything
2. `nix develop -c prek run --all-files` - run all pre-commit hooks
3. `nix flake check --system x86_64-linux` - evaluate and check the flake
4. Run the appropriate `nix build` for any host whose files were modified

## Per-host builds

| Host | Changed paths | Build command |
| --- | --- | --- |
| nixbox | `hosts/nixbox/`, `modules/common/`, `modules/linux/` | `nix build .#nixosConfigurations.nixbox.config.system.build.toplevel` |
| macbox | `hosts/macbox/`, `modules/darwin/` | `nix build .#darwinConfigurations.macbox.system` |
| nasbox | `hosts/nasbox/`, `modules/common/`, `modules/linux/` | `nix build .#homeConfigurations.nasbox.activationPackage` |
| nasbox (switch) | same as nasbox | `home-manager switch --flake .#nasbox` |

Touch `flake.nix` or `flake.lock` -> build all three.

## Fast checks

- Hook-only (no full build): `nix build .#checks.x86_64-linux.pre-commit`
- Formatting only: `nix run .#formatter -- --fail-on-change <path>`
- Static lint only: `nix develop -c sh -c "deadnix . && statix check ."`

## Flake health

| Task | Command |
| --- | --- |
| Check (Linux) | `nix flake check --system x86_64-linux` |
| Check (all systems) | `nix flake check --all-systems` |
| Pre-commit check | `nix build .#checks.x86_64-linux.pre-commit` |
| Run all hooks | `nix develop -c prek run --all-files` |
| Static lint | `nix develop -c sh -c "deadnix . && statix check ."` |

## Maintenance

| Task | Command |
| --- | --- |
| Enter dev shell | `nix develop` |
| Evaluate flake outputs | `nix flake show` |
| Update all inputs | `nix flake update` |
| Install git hooks locally | `nix run .#pre-commit-install` |

## Formatter stack

treefmt orchestrates all formatters via `nix fmt`:

| Language | Formatter | Notes |
| --- | --- | --- |
| Nix | nixfmt | Default rules; avoid manual alignment |
| Lua | stylua | 2-space indent, no tabs |
| Markdown | mdformat | 80-100 columns preferred; tables may flow |
| All | keep-sorted | Sorts marked lists |

### keep-sorted rules

- Lists wrapped in keep-sorted markers are sorted automatically by `nix fmt`
- Do not hand-sort or reorder them manually
- Do not remove keep-sorted markers
- After adding an item to a sorted list, run `nix fmt` to reorder

### Per-language style

- **Nix**: nixfmt default rules; lower-case with hyphens; no trailing whitespace; EOF newline
- **Lua**: stylua output; 2-space indent, no tabs; snake_case table keys; prefer local functions
- **Markdown**: one top-level heading; lists for steps; short lines; preserve README brevity

## Pre-commit hooks

Run via `nix develop -c prek run --all-files`:

- `check-json` - validate JSON files
- `check-xml` - validate XML files
- `check-merge-conflict` - detect leftover conflict markers
- `end-of-file-fixer` - ensure files end with a newline
- `deadnix` - flag unused Nix bindings
- `statix check` - Nix linting
- `treefmt --fail-on-change` - enforce formatting

Hook configuration lives in `dev/pre-commit.nix`; do not edit `.pre-commit-config.yaml` directly (it is generated).

## CI path filters

CI triggers per-host builds based on changed paths:

- `hosts/nixbox/`, `modules/common/`, `modules/linux/` -> rebuilds nixbox and nasbox
- `hosts/macbox/`, `modules/darwin/` -> rebuilds macbox
- `flake.nix` or `flake.lock` -> triggers all three

## Testing philosophy

- No dedicated unit test suite; lean on flake checks and formatting hooks
- Preferred full check: `nix flake check --system x86_64-linux`
- When adding new checks, prefer Nix flake `checks` outputs over ad-hoc scripts
- Ensure the worktree is clean after `nix fmt` before committing

## Safety rules

- For system-critical changes (`hosts/*/system`), always run the full host build
- Run `nix flake check` on darwin changes too when on a darwin machine:
  `nix flake check --system x86_64-darwin`
