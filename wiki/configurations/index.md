---
generated_commit: 06cd74bc677d19a9e44814ed8572eab31dbcd7f9
generated_at: 2026-10-30T09:19:38Z
source_paths:
  - configurations
---

# configurations

Thin flake-parts modules, imported by hand from `flake.nix`, each defining one host
configuration as a flake attribute. They contain no host logic; system assembly lives in
`hosts/<host>/default.nix`.

## Key files

| File | Defines |
| ---- | ------- |
| `configurations/nixbox/flake-module.nix` | `flake.nixosConfigurations.nixbox` via `inputs.nixpkgs.lib.nixosSystem`. |
| `configurations/macbox/flake-module.nix` | `flake.darwinConfigurations.macbox` via `inputs.nix-darwin.lib.darwinSystem`. |
| `configurations/nasbox/flake-module.nix` | `flake.homeConfigurations.nasbox` via `inputs.home-manager.lib.homeManagerConfiguration`. |

`flake.nix` imports all three explicitly. Only `x86_64-linux` and `aarch64-darwin` are in
`systems`.

## nixbox

- Arguments: `{ eanaLib, inputs, ... }`.
- No `system` and no `pkgs` argument is passed; the platform comes from
  `nixpkgs.hostPlatform = "x86_64-linux"` in `hosts/nixbox/nix/default.nix`.
- Modules: `../../hosts/nixbox/default.nix`, `inputs.disko.nixosModules.disko`,
  `inputs.agenix.nixosModules.default`, `inputs.home-manager.nixosModules.home-manager`,
  `inputs.nix-index-database.nixosModules.nix-index`.
- `specialArgs = { inherit inputs; lib = eanaLib "x86_64-linux"; }`.

## macbox

- Arguments: `{ eanaLib, inputs, ... }`.
- `pkgs = import inputs.nixpkgs { system = "aarch64-darwin"; config.allowUnfree = true; }`.
- Adds overlay `workaroundForAtuinDarwinCheck` to that `pkgs` import. It overrides `atuin`
  with `doCheck = false` because the atuin e2e test hangs on unsandboxed darwin builds.
  Upstream fix is NixOS/nixpkgs `34f4a531e8fb` (PR #574509), not yet in the pinned
  channel. Remove the overlay once the pinned nixpkgs contains it.
- Modules: `../../hosts/macbox/default.nix`, `inputs.agenix.nixosModules.default`,
  `inputs.home-manager.darwinModules.home-manager`,
  `inputs.nix-homebrew.darwinModules.nix-homebrew`, and an inline
  `users.users.jonas = { name = "jonas"; home = "/Users/jonas"; }`.
- `specialArgs = { inherit inputs; lib = eanaLib "aarch64-darwin"; }`.

## nasbox

- Arguments: `{ inputs, ... }`.
- `pkgs = import inputs.nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; }`.
- Modules: `../../hosts/nasbox/default.nix` and an inline
  `{ nixpkgs.config.allowUnfree = true; }`.
- `extraSpecialArgs = { inherit inputs; nixvimInput = inputs.nixvim; }`. No `lib`
  override; `hosts/nasbox/home-manager/default.nix` binds
  `eanaLib = import ../../../lib.nix { lib = inputs.nixpkgs.lib; }` (a plain attrset, so
  there is no `lib.eana` there).

## eanaLib

`flake.nix` defines `eana = import ./lib.nix { lib = inputs.nixpkgs.lib; }` and
`eanaLib = _system: inputs.nixpkgs.lib.extend (_: _: { inherit eana; })`, and exposes it to
flake modules with `_module.args.eanaLib`. nixbox and macbox pass the extended lib as
`specialArgs.lib`, which makes `lib.eana.modulesFromDir` available in host modules. The
`_system` argument is unused.

## Outputs

`dev/flake-module.nix` turns these attributes into packages:

- x86_64-linux: `nixbox = self.nixosConfigurations.nixbox.config.system.build.toplevel`,
  `nasbox = self.homeConfigurations.nasbox.activationPackage`.
- otherwise (aarch64-darwin): `macbox = self.darwinConfigurations.macbox.system`.

## Notes

- `allowUnfree`: macbox sets it in the `pkgs` import; nasbox sets it in the `pkgs` import and
  again inline; nixbox sets it through `hosts/shared/nix/default.nix`.
- macbox is the only configuration with a package overlay: the atuin `doCheck = false`
  workaround described above. It was added by `fix(configurations): disable atuin checks on macbox`, the only commit touching this directory since the previous wiki run.
- nasbox is a Home Manager configuration, so its buildable output is `activationPackage`.
- `nixvimInput = inputs.nixvim` is passed as a special argument on all three hosts (here for
  nasbox, in `hosts/{nixbox,macbox}/home-manager/default.nix` for the others), but no module
  in the repo reads it. Hosts import `inputs.nixvim.homeModules.nixvim` directly.

## Related pages

- [hosts](../hosts/index.md)
- [dev](../dev/index.md)
