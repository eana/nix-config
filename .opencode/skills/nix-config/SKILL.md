---
name: nix-config
description: Coding conventions, module patterns, and repository structure for this Nix config repo
compatibility: opencode
---

## Repository structure

- `flake.nix` — flake inputs, `homeModules` exposure, host configurations
- `modules/common/<name>/default.nix` — home-manager modules (all hosts)
- `modules/linux/<name>/default.nix` — Linux-only home-manager modules
- `modules/darwin/<name>/default.nix` — macOS-only home-manager modules
- `home/users/<user>/<platform>.nix` — per-user, per-platform module wiring
- `hosts/<hostname>/` — host-specific NixOS/nix-darwin/home-manager config
- `dev/` — formatter and pre-commit hook configuration

## Module pattern

All home-manager modules follow this exact structure:

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.module.<name>;
in
{
  options.module.<name> = {
    enable = lib.mkEnableOption "<name>";
    # Add typed options with lib.mkOption and descriptions here
  };

  config = lib.mkIf cfg.enable {
    programs.<name> = { ... };
  };
}
```

Key rules:

- Namespace is always `config.module.<name>` — never `programs.*` or `services.*` at the top level
- `cfg = config.module.<name>` is the canonical let-binding name
- Gate all config behind `lib.mkIf cfg.enable`
- Thin `default.nix` aggregators just list `imports` in keep-sorted order; no logic
- Host wiring lives in `home/users/<user>/<platform>.nix`, not in module files

## Coding style (Nix)

- Use lower-case with hyphens for file and module names
- Prefer attrset merges via `//` only when intentional; otherwise pass attrs explicitly
- Keep let-bindings minimal; avoid unused bindings (deadnix will flag)
- Use meaningful attribute names; avoid one-letter names except for conventional args
- Keep option descriptions clear when adding new options
- Prefer `inherit` to reference in-scope attributes instead of repeating names
- Use `with` sparingly; avoid broad `with pkgs;` in large scopes
- Prefer `pkgs.lib` or `inputs.nixpkgs.lib` utilities rather than ad-hoc helpers
- Avoid impure paths; use flake inputs or `./relative` references
- Keep platform-specific logic scoped under the relevant host/module

## Imports and structure

- Prefer explicit module imports; avoid wildcards/globs
- Maintain alphabetical/keep-sorted ordering where markers exist
- Group related imports: external inputs, then local modules
- Keep module lists stable; add new modules at the correct sorted position
- For `moduleList` in `flake.nix`, preserve keep-sorted block order
- When adding new hosts or modules, mirror existing directory conventions

## Adding new modules or hosts

1. Create `modules/common/<name>/default.nix` following the module pattern above
2. Add `"<name>"` to `moduleList` in `flake.nix` (keep-sorted order)
3. Enable it in the appropriate `home/users/<user>/<platform>.nix`
4. For nixos/darwin/home-manager configs, keep stateVersion aligned with existing hosts

## Tooling inventory

- Dev shell packages: `cachix`, `deadnix`, `nixfmt`, `statix`
- Formatter: treefmt (flake formatter output)
- Pre-commit hooks: `check-json`, `check-xml`, `check-merge-conflict`,
  `end-of-file-fixer`, `deadnix`, `statix check`, `treefmt --fail-on-change`
- Flake structure: uses `flake-parts` + `terlar/dev-flake` for perSystem boilerplate
- Nix inputs: nixpkgs unstable, nixvim, home-manager, nix-darwin, disko, agenix, nix-index-database

## Secrets and credentials

- Store secrets as `.age` files managed by agenix
- Do not add raw secrets to git; never hardcode tokens
- If adding new secrets, update `secrets.nix` appropriately
- Keep `secrets.nix` and generated `*.age` files out of patches unless required

## Error handling and safety

- Avoid force pushes unless explicitly requested
- When modifying system-critical files (`hosts/*/system`), double-check build commands before merging
- Prefer smaller, reversible changes
- Ask for confirmation before destructive operations
