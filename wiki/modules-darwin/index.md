---
generated_commit: ef4c8823581f45a9dadf2046c37c739f96352523
generated_at: 2026-10-11T08:44:01Z
source_paths:
  - modules/darwin
---

# modules/darwin

Darwin Home Manager modules. The directory contains one module, `aerospace`, plus an empty
`.gitkeep`. Nothing here is auto-imported: `hosts/macbox/home-manager/default.nix` imports
`../../../modules/darwin/aerospace` by path. `home/users/jonas/darwin.nix` enables it with
`modifier = "cmd"`.

## aerospace

Generates `~/.aerospace.toml` for the AeroSpace tiling window manager. The application
itself is installed as a Homebrew cask in `hosts/macbox/system/homebrew.nix`.

### Options (`interface.nix`)

- `enable`.
- `modifier` - string, default `"alt"`.
- `keybindings` - `attrsOf (either str (listOf str))`; the default is
  `defaultKeybindings // rescueKeybindings`. Setting it replaces the whole default set.
- `settings` - `types.attrs`, default `{ }`, deep-merged into the generated config.

Default keybindings (`<mod>` = `modifier`):

- `<mod>-shift-r` - reload config and show a notification (a list, so it does not run in
  a shell).
- `<mod>-enter` - kitty with `--directory ~` (`config.module.kitty.package or pkgs.kitty`).
- `<mod>-alt-t` - Telegram, launched from the `pkgs.telegram-desktop` binary because apps
  started with `open` are invisible to AeroSpace.
- `<mod>-alt-<arrow>` focus, `<mod>-shift-<arrow>` move (plain `<mod>-<arrow>` is left alone
  because Karabiner maps Home/End to cmd+arrows).
- `<mod>-1..7` workspace, `<mod>-shift-1..7` move window to workspace,
  `<mod>-ctrl-left/right` previous/next workspace with wrap-around.
- `<mod>-shift-space` toggle floating/tiling.

Rescue keybindings use fixed keys, independent of `modifier`: `cmd-shift-q` close,
`alt-tab` workspace back-and-forth, `alt-shift-tab` move workspace to next monitor,
`alt-c` / `alt-v` horizontal / vertical tiles, `alt-f` fullscreen, `alt-r` resize mode.

### Generated config (`default.nix`)

- `config-version = 2`, `start-at-login = true`.
- Tiles layout, `default-root-container-orientation = "auto"`, inner gaps 2, no outer gaps.
- Persistent workspaces 1 to 7.
- `on-window-detected` floats System Settings (`com.apple.SystemSettings` /
  `com.apple.systempreferences`) and Calculator.
- `mode.main.binding = cfg.keybindings`; resize mode: h/k `-50`, j/l `+50`, arrows resize
  width/height, enter/esc return to main.
- `recursiveUpdate baseSettings cfg.settings`, written with `pkgs.formats.toml`.

## Related pages

- [hosts](../hosts/index.md) - macbox import, Homebrew cask, Karabiner config.
- [home](../home/index.md) - `jonas/darwin.nix` enables the module.
- [modules/common](../modules-common/index.md) - the kitty module used for the terminal binding.
