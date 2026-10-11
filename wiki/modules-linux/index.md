---
generated_commit: ef4c8823581f45a9dadf2046c37c739f96352523
generated_at: 2026-10-11T08:44:01Z
source_paths:
  - modules/linux
---

# modules/linux

Eleven Linux modules: avizo, foot, fuzzel, gammastep, kanshi, libvirt, mhalo, mpv, openra,
sway, waybar. Each follows the `interface.nix` / `default.nix` split; `mhalo` and `openra`
also have `package.nix`, and `openra` has `desktop.nix`.

## How they are imported

`hosts/nixbox/home-manager/default.nix` imports ten of them into Home Manager:

```nix
++ builtins.attrValues (lib.eana.modulesFromDir ../../../modules/common)
++ builtins.attrValues (
  lib.filterAttrs (name: _: name != "libvirt") (lib.eana.modulesFromDir ../../../modules/linux)
);
```

`libvirt` is a NixOS system module. `hosts/nixbox/default.nix` imports it directly and sets
`module.libvirt`. No other host imports anything from `modules/linux`.

All ten Home Manager modules are enabled in `home/users/jonas/linux.nix`.

## Desktop (Wayland)

- `sway/` - `wayland.windowManager.sway` with systemd and the gtk wrapper,
  `checkConfig = false` (comment: fontconfig cannot write its cache to `/homeless-shelter`
  in the build sandbox), `bars = [ ]`, font "Helvetica Neue LT Std". Packages: swaylock,
  swayidle, swaybg, grim, slurp, wl-clipboard, imagemagick, tesseract, jq, libnotify,
  brightnessctl, playerctl, earlyoom, mako, copyq, google-chrome, nautilus, rofi,
  rofi-rbw-wayland. Installs `assets/.config/mimeapps.list` and the backgrounds directory,
  and a generated swaylock config. Interface options: `modifier`, `background` (default
  `hannah-grace-dSqWwzrLJaQ-unsplash.jpg`), `keybindings` (including swaylock on `$mod+0`
  and `$mod+l`), `startup`, `extraConfig` (borders, window rules, input, modes, lid switch,
  autostart of earlyoom, mako, swayidle with a 300 s lock), `swaylock.settings`.
- `waybar/` - `programs.waybar`; if `custom.theme` is `gruvbox` it uses a gruvbox CSS palette,
  otherwise a generic palette. `default.nix` sets `module.waybar.style` with `lib.mkDefault`,
  which takes priority over the option default, so the CSS default in `interface.nix` is never
  used. systemd targets default to `sway-session.target`.
- `foot/` - `programs.foot`; font from `custom.fonts` via `mkDefault` (effective size 11,
  although foot's own option default is 10); colors from `modules/common/colors/tokyo-night.nix`.
- `fuzzel/` - `programs.fuzzel` with `dpi-aware = "auto"`.
- `kanshi/` - `services.kanshi` with profiles `MonitorAndLaptop` (Dell at scale 1.5, Sharp
  panel disabled; exec moves workspaces 1-3 to the Dell via `swaymsg`) and `LaptopOnly`
  (Sharp at 0.8).
- `avizo/` - `services.avizo`; sway's startup restarts it.
- `gammastep/` - `services.gammastep`, manual provider at 59.3 / 18.0, 5700K day /
  3600K night, tray, `fade = 1`, `gamma = 0.8`.

## Media

- `mpv/` - the interface builds a wrapper that puts a `python3.withPackages` (python-dateutil,
  ifaddr, lxml, requests, upnpclient) on `PATH`/`PYTHONPATH` and execs mpv. The default
  installs it, writes `mpv/input.conf` and `mpv/mpv.conf` (defaults from `assets/.config/mpv`),
  installs the mpvDLNA script (`chachmu/mpvDLNA` v3.4.1) and generates
  `script-settings/mpvDLNA.conf` (`dlnaTimeout` default 5, optional server names/addresses).

## Apps and virtualization

- `openra/` - options `release` (default `release-20250330`) and `variants` (an `attrsOf`
  submodule, default `{ }`, each with `enable`, `appimageSha256`, `iconSha256`). The variant
  table (red-alert, dune, tiberian-dawn) is hardcoded in `default.nix`. `package.nix`
  downloads the x86_64 AppImage and wraps it with `appimage-run` and an `LD_LIBRARY_PATH`;
  `desktop.nix` builds a desktop item and icon.
- `mhalo/` - mouse-pointer halo. `package.nix` builds `progandy/mhalo` at rev
  `3088f5152f66360828df0e7935b020f6500f540b` with meson and Qt6, sets
  `dontWrapQtApps = true` and calls `wrapQtApp` in `postFixup`; `platforms = linux`. The
  `swayKeybinding` option adds a binding to
  `wayland.windowManager.sway.config.keybindings` (set to `Mod4+Shift+m` in `linux.nix`).
- `libvirt/` - `virtualisation.libvirtd` with `qemu_kvm`, `runAsRoot = true`, swtpm, plus
  `daemonSettings` merged into `qemu`; `kvm-<cpu>` kernel module when `platformCpu` is set;
  with `gui.enable`: virt-manager, spice-gtk, dconf and spice USB redirection; adds `user` to
  the `libvirtd` group.

## Notes

- No `HACK:`, `TODO` or `FIXME` markers in this directory.
- Declared but unused options: `module.sway.swaylock.enable`, `module.sway.package`,
  `module.kanshi.package`, `module.gammastep.package`. Swaylock is always installed and
  configured when sway is enabled.
- The openra AppImage is x86_64-only; mhalo is Linux-only.

## Related pages

- [modules/common](../modules-common/index.md)
- [hosts](../hosts/index.md)
- [home](../home/index.md)
