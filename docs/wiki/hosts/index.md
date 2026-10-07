______________________________________________________________________

title: Hosts
generated_commit: b9ee706915c5dfd42b98ba9de6c553e1df8a2c8d
source_paths:

- configurations/
- hosts/

______________________________________________________________________

# Hosts

System configuration for three hosts. Each `configurations/<host>/flake-module.nix`
assembles a flake output; `hosts/<host>/default.nix` composes the actual system
config and imports `hosts/shared/` where applicable.

## How a change reaches a host

`configurations/<host>/flake-module.nix` builds the system
(`nixosSystem` / `darwinSystem` / `homeManagerConfiguration`) and imports
`../../hosts/<host>/default.nix`. Host defaults import `../shared/default.nix`
(nixbox and macbox only) plus platform-specific shared files
(`shared/system/linux.nix` or `shared/system/darwin.nix`), host system files, and
Home Manager wiring under `hosts/<host>/home-manager/`, which pulls user configs
from `home/users/<user>/<platform>.nix`. `useGlobalPkgs`/`useUserPackages` are set
in `hosts/shared/home-manager/default.nix` (redundantly repeated in
`hosts/macbox/nix/default.nix`), so HM package versions come from system pkgs.

## Hosts

| Host | Platform | Output type | Role |
| --- | --- | --- | --- |
| nixbox | x86_64-linux | `nixosSystem` | Desktop: disko LUKS+btrfs, NVIDIA Prime, libvirt, GDM/GNOME/Sway, zramSwap, nix-ld |
| nasbox | x86_64-linux | `homeManagerConfiguration` (root only) | Synology DS920+ NAS: minimal HM, no shared system imports, no agenix |
| macbox | aarch64-darwin | `darwinSystem` | Laptop: nix-homebrew, homebrew casks, macOS defaults, aerospace, dns-switcher |

### nixbox

Imports shared + `../shared/system/linux.nix`, disko (`disko.nix`: LUKS on NVMe
with btrfs subvols `@`, `@home`, `@nix`, `@snapshots`, `@log`, zstd), hardware
config, NVIDIA Prime (`system/nvidia.nix`, intelBusId 00:02.0 / nvidiaBusId 01:00.0),
libvirt (imported at system level, see below), GDM/GNOME/Sway, bluetooth/printing/avahi.
StateVersion 24.05.

### nasbox

Skips `../shared` entirely (see `hosts/nasbox/default.nix:2-7`). Home Manager only:
configures root HM (`home/users/root/ds920p.nix`) plus its own `nix/default.nix`
(explicit `nix.package`, allowUnfree, `doCheckByDefault = false`). StateVersion 26.05
(home). No agenix at system level.

### macbox

Imports shared + `../shared/system/darwin.nix`. nix-homebrew plus homebrew casks
(aerospace, firefox, google-chrome, karabiner-elements, protonvpn, vlc, xnviewmp)
and mas (Bitwarden) via `system/homebrew.nix`. macOS system defaults in
`system/defaults.nix` (keyboard, dock, Finder, NSGlobalDomain), `system/dns-switcher.nix`.
StateVersion 6 (system). primaryUser jonas.

## hosts/shared

Central aggregator imported by nixbox and macbox (not nasbox):

| File | Role |
| --- | --- |
| `shared/default.nix` | Top-level aggregator; imports the files below |
| `shared/home-manager/default.nix` | `useGlobalPkgs = true`, `useUserPackages = true`, `backupFileExtension = "backup"` |
| `shared/nix/default.nix` | Trusted users, extraOptions from `dev/nix.conf`, per-platform GC, `allowUnfree`, `doCheckByDefault = false` (TEMPORARY/TODO), imports `modules/common/nix-cache.nix` |
| `shared/secrets.nix` | agenix `age.secrets` declarations (see [secrets](../secrets/index.md)) |
| `shared/variables.nix` | `module.variables`: dnsServers, userName, timeZone, knownNetworkServices |
| `shared/system/linux.nix` | NetworkManager, sudo NOPASSWD for nixos-rebuild |
| `shared/system/darwin.nix` | knownNetworkServices, sudo NOPASSWD for darwin-rebuild |
| `shared/system/environment.nix` | `EDITOR=nvim` |
| `shared/system/packages.nix` | Fonts |

## Notable patterns

- nasbox is HM-only on DSM; it does not import shared and needs explicit
  `nix.package` because it runs on non-NixOS.
- `doCheckByDefault = false` set globally at `hosts/shared/nix/default.nix:39` and
  `hosts/nasbox/nix/default.nix:21` with a TEMPORARY/TODO comment - package tests
  are silently skipped.
- libvirt: `modules/linux/libvirt` is filtered out of HM auto-import
  (`hosts/nixbox/home-manager/default.nix:21`) and imported at system level in
  `hosts/nixbox/default.nix:23` instead, because it configures `virtualisation.libvirtd`.

## Related pages

- [home](../home/index.md)
- [secrets](../secrets/index.md)
- [modules-linux](../modules-linux/index.md)
