---
name: nix-check
description: Validate and test changes in this Nix config repo before finishing
compatibility: opencode
---

## Validation checklist

Run these in order before considering a change complete:

1. `nix fmt` — format and lint everything
2. `nix develop -c pre-commit run --all-files` — run all pre-commit hooks
3. `nix flake check --system x86_64-linux` — evaluate and check the flake
4. Run the appropriate `nix build` for any host whose files were modified

## Per-host build commands

| Host | Changed paths | Build command |
| --- | --- | --- |
| nixbox | `hosts/nixbox/`, `modules/common/`, `modules/linux/` | `nix build .#nixosConfigurations.nixbox.config.system.build.toplevel` |
| macbox | `hosts/macbox/`, `modules/darwin/` | `nix build .#darwinConfigurations.macbox.system` |
| nasbox | `hosts/nasbox/`, `modules/common/`, `modules/linux/` | `nix build .#homeConfigurations.nasbox.activationPackage` |

Touch `flake.nix` or `flake.lock` → build all three.

## Fast checks

- Hook-only (no full build): `nix build .#checks.x86_64-linux.pre-commit`
- Formatting only: `nix run .#formatter -- --fail-on-change <path>`
- Static lint only: `nix develop -c sh -c "deadnix . && statix check ."`

## Testing philosophy

- No dedicated unit test suite; lean on flake checks and formatting hooks
- Preferred full check: `nix flake check --system x86_64-linux`
- When adding new checks, prefer Nix flake `checks` outputs over ad-hoc scripts
- Ensure the worktree is clean after `nix fmt` before committing

## Safety rules

- For system-critical changes (`hosts/*/system`), always run the full host build
- Run `nix flake check` on darwin changes too when on a darwin machine:
  `nix flake check --system x86_64-darwin`
