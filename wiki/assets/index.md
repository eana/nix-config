---
generated_commit: ef4c8823581f45a9dadf2046c37c739f96352523
generated_at: 2026-10-11T08:44:01Z
source_paths:
  - assets
---

# assets

Static files laid out like `$HOME`. Modules reference them by relative path and install
them with `home.file` or `xdg.configFile`. The directory contains no Nix code.

```
assets/.p10k.zsh                 -> ~/.p10k.zsh
assets/.config/...               -> ~/.config/...
assets/.local/share/backgrounds/ -> ~/.local/share/backgrounds/
```

## Contents and consumers

| Path | Contents | Installed by |
| ---- | -------- | ------------ |
| `.p10k.zsh` | powerlevel10k config from the wizard (lean, nerdfont-v3, one line, transient prompt, custom `my_git_formatter`) | `modules/common/zsh` (`p10kConfigFile`) |
| `.config/mimeapps.list` | default apps: firefox for http/https/html; added associations list opera first for web, plus gedit, evince, libreoffice, gthumb, code-oss; chromium for `about`/`unknown` | `modules/linux/sway` |
| `.config/mpv/mpv.conf` | `hwdec=auto`, `ao=pulse`, pipewire audio device, `save-position-on-quit`, `[benchmark]` profile | `modules/linux/mpv` (`mpvConf`) |
| `.config/mpv/input.conf` | mpvDLNA bindings (`ctrl+b`, `;`, `:`), `b apply-profile benchmark` | `modules/linux/mpv` (`inputConf`) |
| `.config/snip/config.toml` | `[display] quiet_no_filter = true` | `modules/common/opencode` when `snip.enable` |
| `.local/share/backgrounds/*.jpg` | six wallpapers (binary) | `modules/linux/sway` (whole directory) |
| `.config/opencode/skills/<name>/` | eleven opencode skills | `modules/common/opencode` |

The sway default background is `hannah-grace-dSqWwzrLJaQ-unsplash.jpg`, set in
`modules/linux/sway/interface.nix` and again in `home/users/jonas/linux.nix`. The other
images are not referenced by name.

## opencode skills

| Skill | Topic |
| ----- | ----- |
| flake-parts | flake-parts and dev-flake |
| nix-check | validation commands for this repo |
| nix-coding | Nix style and module patterns |
| nix-config | this repo's structure and conventions |
| git-commit | conventional commits, staging, signing |
| ghq-lookup | reading source via ghq |
| gitlab-cli-tool | glab usage (with `references/commands.md`) |
| repo-wiki | generating a repository wiki with D2 diagrams |
| skill-creator | creating and evaluating skills |
| style | documentation style |
| linkedin-profile-editor | editing a LinkedIn profile through Playwright |

- The first ten are the `local` group of `modules/common/opencode/skills-catalog.nix`;
  `skills.nix` maps each name to `assets/.config/opencode/skills/<name>`.
- `linkedin-profile-editor` is not in the catalog; `opencode/default.nix` adds it when
  `playwright.enable` is set.
- `repo-wiki/SKILL.md` is also copied into the `repo-wiki` package
  (`modules/common/opencode/packages/repo-wiki.nix`), which adds the `repo-wiki-index` and
  `repo-wiki-query` tools. When `repo-wiki` is enabled, opencode points the skill at the
  package output instead of this directory.
- Each `SKILL.md` has `name` and `description` frontmatter; five skills (`flake-parts`,
  `ghq-lookup`, `nix-check`, `nix-coding`, `nix-config`) also set `compatibility: opencode`.
- Adding a local skill means adding `<name>/SKILL.md` here and the name to the catalog's
  `local` list.
- No CI path filter covers `assets/**`, so changes here do not trigger host builds.

## Related pages

- [modules/common](../modules-common/index.md)
- [modules/linux](../modules-linux/index.md)
