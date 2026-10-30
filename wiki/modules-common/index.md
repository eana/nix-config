---
generated_commit: 06cd74bc677d19a9e44814ed8572eab31dbcd7f9
generated_at: 2026-10-30T09:19:38Z
source_paths:
  - modules/common
---

# modules/common

Home Manager modules imported on all three hosts through `modulesFromDir`, and exported as
`flake.homeModules.<camelCaseName>` from `flake.nix`. The collected modules are atuin,
custom, git, gpg-agent, kitty, nixvim, opencode, podman, ssh-client, tmux and zsh (11
directories with a `default.nix`). `modulesFromDir` camel-cases the directory name, so the
exports are `gpgAgent` and `sshClient` while the options stay `module.gpg-agent` and
`module.ssh-client`.

Host wiring: `hosts/nixbox/home-manager/default.nix` and
`hosts/macbox/home-manager/default.nix` import
`builtins.attrValues (modulesFromDir ../../../modules/common)` next to their platform module
dirs; `hosts/nasbox/home-manager/default.nix` imports only `modules/common`.
`nix-cache.nix` is a system module imported from `hosts/shared/nix/default.nix` (nixbox,
macbox) and `hosts/nasbox/nix/default.nix`.

## Module pattern

- `<name>/interface.nix` declares `options.module.<name>`.
- `<name>/default.nix` binds `cfg = config.module.<name>`, imports `./interface.nix`, and
  wraps its config in `mkIf cfg.enable`.
- `modulesFromDir` only collects `<name>/default.nix` one level deep. Files in nested
  directories (`nixvim/plugins/*.nix`, `opencode/packages/*/default.nix`) are imported by
  hand.
- `custom/` is the exception: it declares `options.custom.*` directly.

## Modules

### Shell and terminal

- `zsh/` - `programs.zsh` with oh-my-zsh, 10000-line shared history, autosuggestion, syntax
  highlighting, an AWS `ax` helper, a paste-slowness fix and the `zsh-fzf-history-search`
  plugin. `p10kConfigFile` defaults to `assets/.p10k.zsh`; when non-null it is installed as
  `~/.p10k.zsh` and sourced from init content. Keybindings include ctrl+arrows, Home/End
  variants, `\e^?` (backward-kill-word) and `\ed` (kill-word, i.e. alt+d deletes forward).
- `tmux/` - `programs.tmux` plus a platform clipboard (`pbcopy` on Darwin,
  `${pkgs.wl-clipboard}/bin/wl-paste` on Linux, `wl-clipboard` installed on Linux), prefix
  key from `shortcut` (default `a`), resurrect plugin and a large hand-written keybinding
  block.
- `kitty/` - `programs.kitty`; default colors come from `colors/tokyo-night.nix`, font
  defaults from `config.custom.fonts` via `lib.mkDefault`, plus opacity and keybindings.

### Git, SSH, GPG, history

- `git/` - identity plus an `identities` submodule (name, email, key, `pathPatterns`,
  `sshKey`); renders `.gitconfig-<id>` files included with `gitdir:`; adds `sops` and `meld`;
  default identity is `Jonas Eana <jonas@eana.ro>` with key `C01D2E8FCFCB6358`; `ghq`,
  `glab` and `gh` sections each have their own enable option (all default true).
- `gpg-agent/` - `defaultGpgSettings` (all `mkDefault`: cache TTL 86400, `pinentry-tty`)
  merged with `cfg.settings`, plus `home.packages = [ cfg.package ]` (gnupg).
- `ssh-client/` - builds `programs.ssh.settings` from `hosts`/`globalOptions` and a
  provisioning script that copies the decrypted `secretsFile` to `~/.ssh/config.d/ssh-hosts`
  (removes it when missing). Linux uses a `systemd.user.paths` unit keyed on `PathChanged`
  plus a oneshot service; Darwin uses a launchd agent with `RunAtLoad` and `WatchPaths`.
  `enableDefaultConfig` defaults to false.
- `atuin/` - `programs.atuin` (flags `--disable-up-arrow`, `--disable-ctrl-r`), settings
  merged with sync settings, plus a login script run by `systemd.user.services.atuin-login`
  on Linux and `launchd.agents.atuin-login` on Darwin when sync is enabled with a
  credentials file.

### Containers

- `podman/` - `services.podman`; `machine.enable` defaults to `isDarwin` (4096 MB, 2 cpus,
  50 GB disk, `/Users`, `/private`, `/var/folders` mounts); `podman-compose`; `docker` /
  `docker-compose` aliases. On every Linux host it enables the `systemd.user.sockets.podman`
  socket; only the `DOCKER_HOST` session variable depends on `dockerCompat` (default true,
  Linux only).

### custom and colors

- `custom/default.nix` imports `fonts.nix` (`custom.fonts.monospace` default `MesloLGS NF`,
  `custom.fonts.monoSize` default 11) and `theme.nix` (`custom.theme`, enum
  `gruvbox | tokyo-night`, default `gruvbox`).
- Readers of `config.custom`: kitty (`fonts`), `nixvim/colorscheme.nix` (`theme`),
  `opencode/default.nix` (`theme` for `cli.json`), and in `modules/linux` waybar (`theme`)
  and foot (`fonts`). `home/users/jonas/common.nix` sets `custom.theme = "gruvbox"`.
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
  `plugins/d2-grammar-src.nix` (tree-sitter-d2 pinned at revision `7bba282`).
- `copilot.nix` - copilot-lua with telemetry off and suggestions/panel disabled, copilot-chat,
  a `CopilotToggle` command and a `CopilotGitMessage` command whose prompt reads
  `.conform.yml`/`.conform.yaml` when present, enforces lowercase imperative subjects up to
  60 chars, the allowed scopes and ASCII-only output.
- `keymaps.nix` - alt+d deletes the word forward (`"_dw` in normal mode, `<C-o>de` in
  insert); `<M-BS>` deletes the word back, matching kitty's opt+backspace (`ESC DEL`).
- TODO in `treesitter.nix`: hmts.nvim nil-node crash (upstream issue #24).

### opencode

Options (`interface.nix`): `enable`, `package` (default `pkgs.opencode`),
`codebaseMemory.enable` / `package` / `agents.enable` / `plugin.enable` (all default true),
`extraSkills` (`attrsOf path`), `contextMode.package` / `contextMode.runtime` (default
`pkgs.bun`), `snip.enable`, `ponytail.enable`, `playwright.enable`, `garmin.enable`,
`skills.enabled` (list of catalog names and the `superpowers` / `social` group names),
`copilotAutoModel.enable` (default true) / `copilotAutoModel.autos`,
`ticket.ticketsRepo` (default `eana/agent-tickets`), `ticket.models.planner` /
`ticket.models.builder` (default `github-copilot/claude-sonnet-5`) and
`ticket.models.builderLight` (default `github-copilot/claude-haiku-4.5`), and `extraContext`.

`default.nix` imports only `./interface.nix`. `plugins.nix`, `skills.nix`, `mcp.nix`,
`lsp.nix` and `permissions.nix` are called as functions with `import ./x.nix { ... }`.
Under `cfg.enable` it sets:

- `module.opencode.skills.enabled` to the opt-out baseline (see Skills).
- `home.packages`: `cfg.contextMode.runtime`, `pkgs.snip` when snip is enabled, the
  `garmin-mcp` package when garmin is enabled, and the `repo-wiki` package when `repo-wiki`
  is in `skills.enabled`.
- `xdg.configFile."snip/config.toml"` from `assets/` when snip is enabled.
- `xdg.configFile."opencode/cli.json"`: a generated JSON v2 config with `prompt.paste = "full"`, `theme.name` = `gruvbox` when `custom.theme` is gruvbox, `catppuccin` otherwise,
  keybinds `session.export` / `terminal.suspend` = `none`, `session.first` = `ctrl+home`,
  `session.last` = `ctrl+end`, `diffs.wrap = "word"`, `session` sidebar/scrollbar/thinking
  settings and `animations = true`. Terminal settings are not written through
  `programs.opencode.tui`: OpenCode V2 ignores `tui.json`.
- `programs.mcp.enable = true` with servers from `mcp.nix`.
- `programs.opencode`: `enable`, `package`, `enableMcpIntegration = true`,
  `settings` (`autoshare = false`, `autoupdate = false`, `share = "disabled"`, the LSP
  servers, the permission rules, and `plugin` = the plugins from `plugins.nix` plus
  `${codebaseMemoryOpenCode}/share/opencode/plugins/cbm-augment.ts` when codebase-memory is
  enabled with its plugin), and `context` = `base-context.md` + `codebase-memory-context.md`
  (when codebase-memory is enabled) + `extraContext`. Home Manager writes this to
  `~/.config/opencode/AGENTS.md`, so `base-context.md` becomes the user-level agent
  instruction file on every host.
- `programs.opencode.skills`: the catalog result plus `codebase-memory` and
  `cbm-new-project` when codebase-memory is enabled, `repo-wiki` (replaced by the package
  output) when enabled, `linkedin-profile-editor` when playwright is enabled, the eight
  context-mode skills, and `extraSkills`.
- Three ticket agents as `xdg.configFile."opencode/agents/ticket-*.md"` (planner, builder,
  builder-light) rendered from `cfg.ticket.models`, installed only when at least one of
  `ticket-plan`, `ticket-run`, `ticket-task` is enabled.
- Three codebase-memory agents (scout, verify, auditor) installed from the generated package
  when `codebaseMemory.agents.enable`.

#### Plugins

`plugins.nix` takes `enableSnip`, `enableCopilotAutoModel`, `copilotAutoModelAutos` and
`enablePonytail` and returns the plugin entries for `programs.opencode.settings.plugin`:
`opencode-snip`, `opencode-github-copilot-auto-model` (with the autos list) and `ponytail`,
each only when its flag is set.

#### Skills

- `skills.enabled` is set in `config`, not only as an option default:
  `module.opencode.skills.enabled = catalog.local ++ [ "superpowers" ]`. Because list
  definitions merge, a host setting such as `skills.enabled = [ "social" ]`
  (`home/users/jonas/common.nix`) adds to the baseline instead of replacing it. Removing local
  or superpowers skills requires `lib.mkForce`. The code comment says this opt-out baseline is
  intended.
- `skills-catalog.nix` - `local` (12: flake-parts, ghq-lookup, git-commit, gitlab-cli-tool,
  nix-check, nix-coding, nix-config, repo-wiki, style, ticket-plan, ticket-run, ticket-task),
  `anthropic` (1: skill-creator), `superpowers` (14) and `social` (14).
- `skills.nix` maps `local` names to `assets/.config/opencode/skills/<name>` (except
  `ticket-task`, rendered by `runCommand` with `ticketsRepo` substituted into `SKILL.md` and
  `references/workflow.md`), fetches `obra/superpowers` v7.0.1 (installed with a
  `superpowers-` prefix), `inklate/social-skills` v0.1.0 and `anthropics/skills` at revision
  `ca45fc4` (installed as `skill-creator`), and expands group names. Unknown names in the
  option enum fail evaluation.
- The option enum is `catalog.local ++ ["superpowers-<name>"] ++ catalog.social` plus the
  aliases `superpowers` and `social`. `skills.nix` also builds an `anthropic` group and
  `skill-creator`, but neither is in that enum, so they are currently not selectable.

#### MCP servers

`mcp.nix` - eight entries: `context-mode` (`enabled = true`, the bare binary starts its
stdio MCP server), `codebase-memory` (`enabled = true` when enabled), `k8s` (mcp-k8s-go),
`opentofu`, `context7`, `sequential-thinking` (each only if the package exists in nixpkgs),
`playwright` (with `playwright.enable`) and `garmin` (with `garmin.enable`), all `enabled = false`.

#### LSP, permissions

- `lsp.nix` - `nixd` (the command is actually `pkgs.nil`), `jsonls`, `yamlls`, `gopls`,
  `bashls`, `biome`.
- `permissions.nix` - deny: `age *`, `sops *`, agenix/ragenix, `sudo`, `doas`, `git push`,
  `nix profile`, `nix-env`, `systemctl`, `launchctl`, `terraform`/`tofu`/`tf destroy`;
  ask: `darwin-rebuild`, `nixos-rebuild`, `nh`, `home-manager`, `git commit`,
  ssh/scp/sftp/remote rsync, terraform/tofu/tf, docker, podman, kubectl, brew,
  `pip install`, `npm install -g`, and substring matches of age/sops; allow: ssh-keygen,
  ssh-add, ssh-agent. With snip enabled every rule is duplicated with a `snip ` prefix.

#### Packages (`opencode/packages/`)

One directory per package, each with a `default.nix`: `context-mode`,
`garmin-mcp` (built with `uv2nix` / `pyproject-nix` / `pyproject-build-systems`),
`opencode-snip` (3.0.0), `opencode-github-copilot-auto-model` (0.2.0), `ponytail` (5.3.2),
`codebase-memory-mcp` (0.12.1), `codebase-memory-opencode` (generated skill, agents and
plugin from the MCP server's own installer) and `repo-wiki` (plus `repo-wiki-index.py` and
`repo-wiki-query.py`).

- `repo-wiki/default.nix` - a `runCommand` that copies
  `assets/.config/opencode/skills/repo-wiki/SKILL.md` to `$out/SKILL.md`, installs the two
  Python scripts under `$out/share/repo-wiki/` and wraps them as `bin/repo-wiki-index` and
  `bin/repo-wiki-query` with a Python environment (numpy, requests, tree-sitter,
  tree-sitter-language-pack). The tools embed through Ollama (`OLLAMA_URL`, default
  `http://localhost:11434`; model `REPO_WIKI_EMBED_MODEL`, default
  `qwen3-embedding:0.6b`) and store the index in `.wiki-cache/`. The same package is in the
  devshell (`dev/flake-module.nix`).
- `codebase-memory-opencode` runs `codebase-memory-mcp install -y --force --skip-binary --clients=opencode` in a temp HOME and ships only `share/opencode/{skills,agents,plugins}`;
  the installer's `opencode.json` and `AGENTS.md` are discarded because Home Manager owns
  them.

## Non-module files

- `nix-cache.nix` - a system module imported from `hosts/{shared,nasbox}/nix/default.nix`;
  sets `nix.settings.substituters` to `cache.nixos.org`, `eana.cachix.org` and
  `nix-community.cachix.org` with their `trusted-public-keys`.
- `topiary-nushell.nix` - a `callPackage` derivation.

## HACK comments

- `opencode/default.nix` (cli.json): HM's `programs.opencode.tui` writes `tui.json`, which
  OpenCode V2 no longer reads, so `cli.json` is installed via `xdg.configFile` until HM
  exposes a cli option.
- `opencode/default.nix` (agents): `programs.opencode.agents` only treats Nix path values as
  file sources, so generated store paths are installed through `xdg.configFile` instead.
- `opencode/packages/codebase-memory-mcp/default.nix` (0.12.1): mimalloc's global allocator
  override is disabled because glibc 2.44 crashes in `mi_free` during libstdc++ global init.
- `opencode/packages/codebase-memory-opencode/default.nix`: the generated plugin hardcodes
  `~/.local/bin/codebase-memory-mcp`, which is substituted with the store binary.
- `opencode/packages/context-mode/default.nix` (1.0.169): built locally because the nixpkgs
  build (1.0.143) lacks the `build/` adapter entry; zod pin (4.6.7) must track upstream
  `package.json`; `dontInstallAgentSkills=1` because duplicate `**/SKILL.md` breaks the
  build; `build/server.js` re-exports `server.bundle.mjs`; a `plugin-function.mjs` shim
  because opencode may call the default export as a function.
- `opencode/packages/opencode-github-copilot-auto-model/default.nix`:
  `workaroundForOpenCodeOptionalHookLoader` adds `server.mjs`, `tui.mjs` and `rpc.mjs` stubs
  for opencode's optional-entrypoint probe (anomalyco/opencode#48122).
- `opencode/packages/ponytail/default.nix`: `workaroundForOpencodePluginProbe` stubs
  `tui.mjs`/`rpc.mjs` and re-exports the real entry from `server.mjs` for the same loader
  bug.
- `opencode/packages/garmin-mcp/default.nix`: upstream `uv.lock` only has a fitparse sdist, so
  setuptools is declared as a build-system requirement; wheel `sourcePreference` keeps
  pydantic-core and cryptography from building from sdist.

## Related pages

- [assets](../assets/index.md)
- [modules/linux](../modules-linux/index.md)
- [home](../home/index.md)
- [dev](../dev/index.md)
