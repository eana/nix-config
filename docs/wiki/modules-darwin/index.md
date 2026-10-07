______________________________________________________________________

title: modules/darwin
generated_commit: b9ee706915c5dfd42b98ba9de6c553e1df8a2c8d
source_paths:

- modules/darwin/

______________________________________________________________________

# modules/darwin

Darwin-only Home Manager modules. No auto-import: add by hand to
`hosts/macbox/home-manager/default.nix`. Contains `.gitkeep` and `aerospace/`.

## aerospace

Generates `~/.aerospace.toml` via `pkgs.formats.toml` when `module.aerospace.enable`
is set.

- `interface.nix`: options only - `enable`, `modifier` (default `"alt"`),
  `keybindings`, `settings` (freeform attrs merged in).
- `default.nix`: base settings merged with `cfg.settings` via `recursiveUpdate`.
  Tiled layout, 2px inner gaps, persistent workspaces 1-7 (mirrors sway), floating
  rules for System Settings/Calculator, resize mode bindings.
- Keybindings split into `defaultKeybindings` (reload, kitty + Telegram launch,
  focus/move/workspaces) and `rescueKeybindings` (combos clashing with macOS: cmd-q,
  cmd-tab, cmd-c/v/f/r remapped to alt). Terminal is `config.module.kitty.package`
  or `pkgs.kitty`, launched with `--directory ~`.

## Notable patterns

- interface/default split, gated on `cfg.enable`; freeform `settings` escape hatch.
- Comments document Karabiner/sway interplay (workspaces mirror nixbox sway).

## Related pages

- [hosts](../hosts/index.md)
- [modules-linux](../modules-linux/index.md)
