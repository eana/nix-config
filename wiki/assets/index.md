---
generated_commit: 06cd74bc677d19a9e44814ed8572eab31dbcd7f9
generated_at: 2026-10-30T09:19:38Z
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
| `.p10k.zsh` | powerlevel10k config from the wizard (lean, nerdfont-v3, one line, transient prompt, custom `my_git_formatter`) | `modules/common/zsh` (`p10kConfigFile` default) |
| `.config/mimeapps.list` | default apps: firefox for http/https/html; added associations list opera first for web, plus gedit, evince, libreoffice, gthumb, code-oss; chromium for `about`/`unknown` | `modules/linux/sway` |
| `.config/mpv/mpv.conf` | `hwdec=auto`, `audio-device=pipewire`, `ao=pulse`, `save-position-on-quit`, `[benchmark]` profile | `modules/linux/mpv` (`config.mpvConf`) |
| `.config/mpv/input.conf` | mpvDLNA bindings (`ctrl+b`, `;`, `:`), `b apply-profile benchmark` | `modules/linux/mpv` (`config.inputConf`) |
| `.config/snip/config.toml` | `[display] quiet_no_filter = true` | `modules/common/opencode` when `snip.enable` |
| `.local/share/backgrounds/*.jpg` | six wallpapers (binary) | `modules/linux/sway` (whole directory) |
| `.config/opencode/skills/<name>/` | fourteen opencode skills (see below) | `modules/common/opencode` |

The sway default background is `hannah-grace-dSqWwzrLJaQ-unsplash.jpg`, set in
`modules/linux/sway/interface.nix` (`defaultBackground`) and again in
`home/users/jonas/linux.nix`. The other images are not referenced by name.

All text files here are ASCII-only; commit 4133f0f normalized non-ASCII characters. The
`.jpg` wallpapers are binaries and exempt.

## opencode skills

| Skill | Topic |
| ----- | ----- |
| cbm-new-project | bootstrapping codebase-memory for a new or unindexed repo (`SKILL.md` + `WORKFLOW.md`) |
| flake-parts | flake-parts and dev-flake |
| ghq-lookup | reading source via ghq |
| git-commit | conventional commits, staging, signing |
| gitlab-cli-tool | glab usage (with `references/commands.md`) |
| linkedin-profile-editor | editing a LinkedIn profile through Playwright |
| nix-check | validation commands for this repo |
| nix-coding | Nix style and module patterns |
| nix-config | this repo's structure and conventions |
| repo-wiki | generating a repository wiki with D2 diagrams |
| style | documentation style |
| ticket-plan | splitting a plan into tasks in the tickets repo |
| ticket-run | running remaining tasks of a feature, one subagent per task |
| ticket-task | implementing one task (with `references/workflow.md` and `references/diagrams/ticket-workflow.d2` + `.svg`) |

- Twelve skills are the `local` group of `modules/common/opencode/skills-catalog.nix`.
  `skills.nix` maps each local name to `assets/.config/opencode/skills/<name>`, except
  `ticket-task`: that directory is copied by a `runCommand` that substitutes the default
  tickets repo `eana/agent-tickets` with `module.opencode.ticket.ticketsRepo` in
  `SKILL.md` and `references/workflow.md`.
- `local` plus the `superpowers` group is enabled by default in `opencode/default.nix`.
- `cbm-new-project` is not in the catalog; `opencode/default.nix` adds it when
  `codebaseMemory.enable` is set (on by default). It also sets
  `metadata.opencode/slash: "true"`.
- `linkedin-profile-editor` is not in the catalog; `opencode/default.nix` adds it when
  `playwright.enable` is set.
- `repo-wiki/SKILL.md` is also copied into the `repo-wiki` package
  (`modules/common/opencode/packages/repo-wiki`), which adds the `repo-wiki-index` and
  `repo-wiki-query` tools. When `repo-wiki` is enabled, opencode points the skill at the
  package output instead of this directory.
- All fourteen `SKILL.md` files set `compatibility: opencode`.
- The ticket skills also install the `ticket-planner`, `ticket-builder` and
  `ticket-builder-light` agent profiles, using `module.opencode.ticket.models`.
- `ticket-workflow.d2` renders to the sibling `.svg` through the `d2-render` hook; commit
  both files.
- Not in `assets/`: `skill-creator` comes from `anthropics/skills`, `superpowers-*` from
  `obra/superpowers`, `social-*` from `inklate/social-skills`, and `context-mode` skills
  from the context-mode package. All are fetched or built in `skills.nix` and
  `default.nix`.
- Adding a local skill means adding `<name>/SKILL.md` here and the name to the catalog's
  `local` list. Adding an external skill means adding it to the matching catalog group.
- No CI path filter covers `assets/**`, so changes here do not trigger host builds.

## Related pages

- [modules/common](../modules-common/index.md)
- [modules/linux](../modules-linux/index.md)
