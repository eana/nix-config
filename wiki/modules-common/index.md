---
generated_commit: ef4c8823581f45a9dadf2046c37c739f96352523
generated_at: 2026-10-11T08:44:01Z
source_paths:
  - modules/common
---

# modules/common

Home Manager modules imported on all three hosts through `modulesFromDir`, and exported as
`flake.homeModules.<camelCaseName>` from `flake.nix`. The collected modules are atuin,
custom, git, gpg-agent, kitty, nixvim, opencode, podman, ssh-client, tmux and zsh.

## Module pattern

- `<name>/interface.nix` declares `options.module.<name>`.
- `<name>/default.nix` binds `cfg = config.module.<name>`, imports `./interface.nix`, and
  wraps its config in `mkIf cfg.enable`.
- `modulesFromDir` only collects `<name>/default.nix` one level deep. Files in nested
  directories (`nixvim/plugins/*.nix`) are imported by hand.
- `custom/` is the exception: it declares `options.custom.*` directly.

## Modules

### Shell and terminal

- `zsh/` - `programs.zsh` with oh-my-zsh, history, autosuggestion, syntax highlighting, an
  AWS `ax` helper and a paste-slowness fix. `p10kConfigFile` defaults to `assets/.p10k.zsh`;
  when non-null it is installed with `home.file` and sourced from zshrc.
- `tmux/` - `programs.tmux` plus a platform clipboard (`pbcopy` on Darwin, `wl-clipboard` on
  Linux).
- `kitty/` - `programs.kitty`; colors from `colors/tokyo-night.nix`, font defaults from
  `config.custom.fonts` via `lib.mkDefault`.

### Git, SSH, GPG, history

- `git/` - identity plus an `identities` submodule (name, email, key, `pathPatterns`,
  `sshKey`); renders `.gitconfig-<id>` files included with `gitdir:`; adds `sops` and `meld`;
  `ghq`, `glab` and `gh` sections each have their own enable option.
- `gpg-agent/` - `defaultGpgSettings` (all `mkDefault`: cache TTL 86400, `pinentry-tty`)
  merged with `cfg.settings`.
- `ssh-client/` - builds `programs.ssh.settings` and a provisioning script that copies the
  decrypted `secretsFile` to `~/.ssh/config.d/ssh-hosts`.
- `atuin/` - `programs.atuin` plus a login script, run by `systemd.user.services.atuin-login`
  on Linux and `launchd.agents.atuin-login` on Darwin when sync is enabled with a
  credentials file.

### Containers

- `podman/` - `services.podman`; `machine.enable` defaults to `isDarwin` (memory, cpus,
  disk size, volume mounts); `podman-compose`; `docker` / `docker-compose` aliases. On every
  Linux host it enables the `systemd.user.sockets.podman` socket; only the `DOCKER_HOST`
  session variable depends on `dockerCompat` (default true, Linux only).

### custom and colors

- `custom/default.nix` imports `fonts.nix` (`custom.fonts.monospace` default `MesloLGS NF`,
  `custom.fonts.monoSize` default 11) and `theme.nix` (`custom.theme`, enum
  `gruvbox | tokyo-night`, default `gruvbox`).
- Readers of `config.custom`: kitty, `nixvim/colorscheme.nix`, `opencode/default.nix`, and in
  `modules/linux` waybar and foot.
- `colors/tokyo-night.nix` - plain color data (`hex`, `withHash`), not a module.

### nixvim

- `nixvim/default.nix` imports `autocmds.nix`, `colorscheme.nix`, `interface.nix`,
  `keymaps.nix` and `./plugins`; under `cfg.enable` it configures `programs.nixvim` (options,
  globals, highlights, clipboard, LSP/lint/format packages).
- `nixvim/interface.nix` - `enable`, `wrapColumn` (80), `softWrapEnabled` (false).
- `plugins/default.nix` imports 15 plugin files (blink-cmp, bufferline, conform-nvim,
  copilot, d2, gitsigns, lint, lsp, lualine, mini, render-markdown, snacks-nvim,
  themery-nvim, treesitter, which-key) and enables indent-blankline, trim, web-devicons,
  nvim-autopairs, grug-far, persistence, diffview, trouble and lz-n inline, with undotree as
  an extra plugin.
- `conform-nvim.nix` uses `topiary-nushell.nix`; `d2.nix` and `treesitter.nix` use
  `plugins/d2-grammar-src.nix`.
- TODO in `treesitter.nix`: hmts.nvim nil-node crash (upstream issue #24).

### opencode

Options (`interface.nix`): `enable`, `package`, `extraSkills` (`attrsOf path`),
`contextMode.package` / `contextMode.runtime` (default `pkgs.bun`), `snip.enable`,
`playwright.enable`, `garmin.enable`, `skills.enabled` (list of catalog names and the
`superpowers` / `social` group names), `copilotAutoModel` (`enable` default true, `autos`
with three defaults), `extraContext`.

`default.nix` imports only `./interface.nix`. `plugins.nix`, `skills.nix`, `mcp.nix`,
`lsp.nix` and `permissions.nix` are called as functions with `import ./x.nix { ... }`.
Under `cfg.enable` it sets:

- `programs.opencode.settings`: `autoshare = false`, `autoupdate = false`,
  `share = "disabled"`, `experimental.disable_paste_summary = true`, the LSP servers, the
  permission rules and the plugins.
- `programs.opencode.tui`: theme `gruvbox` when `custom.theme` is gruvbox, `catppuccin`
  otherwise; keybinds `session_export`, `session_share`, `session_unshare` and
  `terminal_suspend` set to `none`, `messages_first = ctrl+home`, `messages_last = ctrl+end`.
- `programs.opencode.context`: `base-context.md` + `extraContext`. Home Manager writes this to
  `~/.config/opencode/AGENTS.md`, so `base-context.md` becomes the user-level agent
  instruction file on every host.
- Packages: the context-mode runtime, `pkgs.snip` with snip, `garmin-mcp` with garmin, and
  the `repo-wiki` package when `repo-wiki` is in `skills.enabled`.
- `snip/config.toml` from `assets/` when snip is enabled.

#### Skills

- `skills.enabled` is set in `config`, not only as an option default:
  `module.opencode.skills.enabled = catalog.local ++ [ "superpowers" ]`. Because list
  definitions merge, a host setting such as `skills.enabled = [ "social" ]`
  (`home/users/jonas/common.nix`) adds to the baseline instead of replacing it. Removing local
  or superpowers skills requires `lib.mkForce`. The code comment says this opt-out baseline is
  intended.
- `skills-catalog.nix` - `local` (10), `superpowers` (14), `social` (14). `skills.nix` maps
  `local` names to `assets/.config/opencode/skills/<name>`, fetches `obra/superpowers`
  v6.4.2 (installed with a `superpowers-` prefix) and `inklate/social-skills` v0.1.0, and
  expands group names. Unknown names fail evaluation (enum type).
- Installed skills: the enabled catalog skills; `repo-wiki` replaced by the `repo-wiki`
  package output (which contains the same `SKILL.md`) when enabled;
  `linkedin-profile-editor` when `playwright.enable`; eight context-mode skills from the
  context-mode package; and `extraSkills`.

#### MCP, LSP, permissions

- `mcp.nix` - six servers, all with `enabled = false`: `k8s` (mcp-k8s-go), `opentofu`,
  `context7`, `sequential-thinking` (each only if the package exists in nixpkgs),
  `playwright` (with `playwright.enable`) and `garmin` (with `garmin.enable`).
- `lsp.nix` - `nixd` (the command is actually `pkgs.nil`), `jsonls`, `yamlls`, `gopls`,
  `bashls`, `biome`.
- `permissions.nix` - deny: `age *`, `sops *`, agenix/ragenix, `sudo`, `doas`, `git push`,
  `nix profile`, `nix-env`, `systemctl`, `launchctl`, `terraform`/`tofu`/`tf destroy`;
  ask: `darwin-rebuild`, `nixos-rebuild`, `nh`, `home-manager`, `git commit`,
  ssh/scp/sftp/remote rsync, terraform/tofu/tf, docker, podman, kubectl, brew,
  `pip install`, `npm install -g`, and substring matches of age/sops; allow: ssh-keygen,
  ssh-add, ssh-agent. With snip enabled every rule is duplicated with a `snip ` prefix.

#### Packages (`opencode/packages/`)

- `context-mode.nix`, `garmin-mcp.nix` (built with `uv2nix` / `pyproject-nix` /
  `pyproject-build-systems`), `opencode-snip.nix`, `opencode-github-copilot-auto-model.nix`.
- `repo-wiki.nix` - a `runCommand` that copies `assets/.config/opencode/skills/repo-wiki/SKILL.md`
  to `$out/SKILL.md` and wraps `repo-wiki/repo-wiki-index.py` and `repo-wiki-query.py` as
  `bin/repo-wiki-index` and `bin/repo-wiki-query` with a Python environment (numpy, requests,
  tree-sitter, tree-sitter-language-pack). The tools embed through Ollama (`OLLAMA_URL`,
  default `http://localhost:11434`; model `REPO_WIKI_EMBED_MODEL`, default
  `qwen3-embedding:0.6b`) and store the index in `.wiki-cache/`. The same package is in the
  devshell (`dev/flake-module.nix`).

## Non-module files

- `nix-cache.nix` - a system module imported from `hosts/{shared,nasbox}/nix/default.nix`;
  sets `nix.settings.substituters` to `cache.nixos.org`, `eana.cachix.org` and
  `nix-community.cachix.org` with their `trusted-public-keys`.
- `topiary-nushell.nix` - a `callPackage` derivation.

## HACK comments

- `opencode/packages/context-mode.nix` (version 1.0.169): built locally because the nixpkgs
  build (1.0.143) lacks the `build/` plugin entry; the zod pin (4.6.5) must track upstream
  `package.json`; `dontInstallAgentSkills=1` because duplicate `**/SKILL.md` breaks the build;
  a `plugin-function.mjs` shim because opencode may call the default export as a function.
- `opencode/packages/garmin-mcp.nix`: upstream `uv.lock` only has a fitparse sdist, so
  setuptools is declared as a build-system requirement; wheel `sourcePreference` keeps
  pydantic-core and cryptography from building from sdist.

## Related pages

- [assets](../assets/index.md)
- [modules/linux](../modules-linux/index.md)
- [home](../home/index.md)
- [dev](../dev/index.md)
