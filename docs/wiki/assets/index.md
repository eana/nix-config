______________________________________________________________________

title: Assets
generated_commit: b9ee706915c5dfd42b98ba9de6c553e1df8a2c8d
source_paths:

- assets/

______________________________________________________________________

# Assets

Raw dotfile payloads referenced by Nix modules as store paths, never edited in
place. Modules wire them via `xdg.configFile` / `home.file` source, or as
overridable option defaults (`mkDefault ../../../assets/...`). Copy-on-build:
Home Manager installs them into `$HOME`.

The tree mirrors `$HOME` layout (`.config/`, `.local/share/`, dotfiles at root) so
paths drop in directly.

## Key files

| File | Role |
| --- | --- |
| `assets/.config/mimeapps.list` | XDG default-app associations; wired by sway module as `xdg.configFile."mimeapps.list"` |
| `assets/.config/mpv/input.conf` | mpv keybinds (mpvDLNA toggle, benchmark profile); option default in `modules/linux/mpv/interface.nix` |
| `assets/.config/mpv/mpv.conf` | mpv playback config (hwdec=auto, pipewire, save-position-on-quit) |
| `assets/.config/snip/config.toml` | snip plugin config; `xdg.configFile."snip/config.toml"` in opencode module |
| `assets/.p10k.zsh` | Powerlevel10k lean prompt config; zsh module option default -> `home.file.".p10k.zsh"` |
| `assets/.local/share/backgrounds/*.jpg` | Wallpapers; sway `backgroundsDir` |

## Vendored OpenCode skills

`assets/.config/opencode/skills/`: flake-parts, ghq-lookup, git-commit,
gitlab-cli-tool, linkedin-profile-editor, nix-check, nix-coding, nix-config,
repo-wiki, skill-creator, style. Wired via
`modules/common/opencode/skills.nix` (name -> asset path); new skills go in the
catalog, not host config.

## Notable patterns

- Two wiring styles: hardwired source (sway, snip) vs overridable mkOption default
  (mpv, p10k).
- Binary wallpapers exist but carry no wiki-relevant config.

## Related pages

- [modules-common](../modules-common/index.md)
- [modules-linux](../modules-linux/index.md)
