---
name: nix-commands
description: Quick reference for common build, check, and maintenance commands in this Nix config repo
compatibility: opencode
---

## Build commands

| Target | Command |
| --- | --- |
| NixOS (nixbox) | `nix build .#nixosConfigurations.nixbox.config.system.build.toplevel` |
| nix-darwin (macbox) | `nix build .#darwinConfigurations.macbox.system` |
| home-manager (nasbox) | `nix build .#homeConfigurations.nasbox.activationPackage` |
| home-manager switch (nasbox) | `home-manager switch --flake .#nasbox` |

## Check and lint

| Task | Command |
| --- | --- |
| Flake check (Linux) | `nix flake check --system x86_64-linux` |
| Flake check (all systems) | `nix flake check --all-systems` |
| Pre-commit check only | `nix build .#checks.x86_64-linux.pre-commit` |
| Run all pre-commit hooks | `nix develop -c pre-commit run --all-files` |
| Static lint (dead code + statix) | `nix develop -c sh -c "deadnix . && statix check ."` |

## Formatting

| Task | Command |
| --- | --- |
| Format everything | `nix fmt` |
| Format single path | `nix run .#formatter -- --fail-on-change <path>` |

## Other

| Task | Command |
| --- | --- |
| Enter dev shell | `nix develop` |
| Evaluate flake outputs | `nix flake show` |
| Update all inputs | `nix flake update` |
| Install git hooks locally | `nix run .#pre-commit-install` |

## CI path filters

CI triggers per-host builds based on changed paths:

- `hosts/nixbox/`, `modules/common/`, `modules/linux/` → rebuilds nixbox and nasbox
- `hosts/macbox/`, `modules/darwin/` → rebuilds macbox
- `flake.nix` or `flake.lock` → triggers all three
