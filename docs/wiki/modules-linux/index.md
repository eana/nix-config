______________________________________________________________________

title: modules/linux
generated_commit: b9ee706915c5dfd42b98ba9de6c553e1df8a2c8d
source_paths:

- modules/linux/

______________________________________________________________________

# modules/linux

Linux-only Home Manager modules, auto-imported on nixbox via `modulesFromDir`
(`hosts/nixbox/home-manager/default.nix:19-21`), with libvirt filtered out (see
below). Same interface/default convention as common modules: `interface.nix`
declares `options.module.<name>`, `default.nix` gates on `cfg.enable`.

## Inventory

| Module | Purpose |
| --- | --- |
| avizo | Wayland notification daemon (HM service) |
| foot | Wayland terminal; DPI-aware font, Tokyo Night colors from shared palette |
| fuzzel | Application launcher |
| gammastep | Screen color temperature (tray/provider/location settings) |
| kanshi | Wayland display profile manager (swaymsg-based profiles) |
| libvirt | KVM/libvirt stack; system-level config, not a pure HM module (see below) |
| mhalo | Wayland mouse pointer halo effect; custom package + optional Sway keybinding |
| mpv | mpv wrapped with Python env for DLNA; ships mpvDLNA script and conf |
| openra | OpenRA RTS variants as AppImage-wrapped packages with .desktop + icons |
| sway | Wayland compositor: keybindings, startup, backgrounds, swaylock; bundles Wayland utils (grim/slurp/wl-copy, mako, copyq, rofi, playerctl, earlyoom, ...) |
| waybar | Wayland bar; theme palettes (gruvbox/default) driven by `custom.theme`, large CSS block, modular settings |

## Custom packages

- **mhalo**: derivation from GitHub progandy/mhalo (pinned rev), built with
  meson/ninja, Qt6 + wayland + pixman, wrapped via `wrapQtApp`. Exposes `package`
  and `swayKeybinding` options (`mhalo/interface.nix:14-25`, `mhalo/package.nix:18-82`).
- **openra**: per-variant AppImage wrapper (`package.nix`) using `appimage-run` +
  runtime libs; `desktop.nix` fetches per-variant icon from GitHub release tags and
  builds a desktop item; `default.nix` maps enabled variants to [pkg, desktopPkg]
  (`openra/interface.nix:13-37`, `default.nix:17-86`).

## libvirt special case

Not imported via HM auto-import: `hosts/nixbox/home-manager/default.nix:21` filters
`name != "libvirt"` out of the module list. Imported at system level in
`hosts/nixbox/default.nix:23` with `module.libvirt = { enable = true; user = "jonas"; gui.enable = true; platformCpu = "intel"; }`. It configures
`virtualisation.libvirtd`, kernel modules, and groups - NixOS system config rather
than Home Manager.

## Notable patterns

- Custom package exposed as an option (mhalo), AppImage wrapping (openra),
  Python-wrapped runtime deps (mpv).
- Sway disables `checkConfig` with a comment (sway/default.nix:48-99).
- Theme-driven styling: waybar palette from `custom.theme` (waybar/default.nix:7-72);
  foot imports the tokyo-night palette (foot/default.nix:6-8).

## Related pages

- [modules-common](../modules-common/index.md)
- [hosts](../hosts/index.md)
