______________________________________________________________________

title: modules/common
generated_commit: b9ee706915c5dfd42b98ba9de6c553e1df8a2c8d
source_paths:

- modules/common/
- lib.nix

______________________________________________________________________

# modules/common

Shared Home Manager modules, auto-imported on all three hosts and exported as
`flake.homeModules` (flake.nix:91). `lib.eana.modulesFromDir` (lib.nix:8-18) only
collects top-level `modules/common/*/default.nix`; nested dirs such as
`nixvim/plugins/` are imported by hand. Consumers:
`hosts/nixbox/home-manager/default.nix:19`, `hosts/macbox/home-manager/default.nix:21`,
`hosts/nasbox/home-manager/default.nix:10`.

Convention: each module directory has `interface.nix` (declares
`options.module.<name>`) and `default.nix` (imports interface, gates behavior on
`cfg.enable`).

## Module inventory

| Module | Purpose |
| --- | --- |
| atuin | Shell history sync client; systemd/launchd login jobs for credentials (platform split) |
| git | Identities with gitdir patterns + GPG signing, delta, ghq (default on), glab, gh |
| gpg-agent | `services.gpg-agent` + gnupg package |
| kitty | Terminal config: font, size, opacity, colors, keybindings; imports `../colors/tokyo-night.nix` |
| nixvim | Full neovim config (see below) |
| ollama | Server: NixOS `services.ollama` on Linux, launchd agent on Darwin |
| opencode | AI coding agent config (see below) |
| podman | Rootless container engine; DOCKER_HOST compat (Linux), podman machine (Darwin) |
| ssh-client | `programs.ssh` hosts, secret provisioning via systemd/launchd |
| tmux | Prefix/index/history/plugins (resurrect) |
| zsh | powerlevel10k config file, `programs.zsh` setup |
| custom/ | Not interface-split: `custom.fonts.{monospace,monoSize}` and `custom.theme` enum (gruvbox/tokyo-night) consumed by nixvim/colorscheme.nix:10, kitty, foot, waybar |

Not modules: `colors/tokyo-night.nix` is a raw palette (no `default.nix`),
imported ad hoc (kitty/interface.nix:16, modules/linux/foot/default.nix:11).

## nixvim (2434 LOC)

- `default.nix`: opts (wrap column, numbers, undo file, search, indent), clipboard
  providers, ~25 extraPackages (LSPs, linters, formatters incl. d2 and topiary),
  WSL clipboard post-hook, soft-wrap Lua.
- `keymaps.nix` (891 LOC, ~111 mappings): Tabs, Buffers, Explorer, Search/Snacks
  picker, Toggles, Diffview, Gitsigns, Sessions, Todos, Editing, Terminal, Resize,
  Diagnostics, Copilot Chat, Theme.
- `autocmds.nix` (310): auto mkdir, checktime, git rebase single-key maps, yank
  highlight, LspAttach buffer keymaps (gd/gr/K/rn/ca), spell.
- `plugins/`: blink-cmp, bufferline, conform-nvim (format_on_save; nu formatter =
  topiary), copilot, gitsigns, lint, lsp (14 servers, onAttach disables formatting),
  lualine, mini, snacks, themery, treesitter (~40 grammars), which-key, plus inline
  indent-blankline, trim, grug-far, persistence, diffview, trouble, lz-n.
- D2 grammar: `plugins/d2-grammar-src.nix` pins ravsii/tree-sitter-d2;
  `d2.nix` builds d2-vim + queries plugins and sets `filetype.extension.d2`.

## opencode (877 LOC)

- `default.nix` gates on `cfg.enable`: `programs.opencode` settings (autoshare/
  autoupdate off), TUI theme derived from `custom.theme`, \`context = baseContext.md
  - extraContext\`.
- `interface.nix`: package, skills.enabled (default `catalog.local ++ ["superpowers"]`), context-mode (bun runtime), snip/playwright/garmin toggles,
  copilotAutoModel, extraContext, extraSkills.
- `skills-catalog.nix`: groups `local` (10 vendored), `superpowers`
  (obra/superpowers v6.4.2), `social` (inklate/social-skills v0.1.0);
  `skills.nix` maps enabled names to asset paths.
- `plugins.nix`: context-mode plugin (HACK comment re loader), opencode-snip,
  copilot-auto-model. `packages/`: context-mode, garmin-mcp (uv2nix), snip, auto-model.
- `mcp.nix`: k8s, opentofu, playwright, context7, sequential-thinking, garmin - all
  `enabled = false` baseline.
- `permissions.nix`: deny age/sops/agenix/sudo/git push; ask on git commit, ssh/scp/sftp.
- `lsp.nix`: nil/nixd, jsonls, yamlls, gopls, bashls, biome.
- `base-context.md`: global agent instruction file (Prompt, Hacks, PR/Issue
  inference, Nix constraints, Secrets, Testing/CI).

## Flat files

- `nix-cache.nix`: system module (not HM), substituters + trusted-public-keys,
  keep-sorted. Imported by `hosts/shared/nix/default.nix:8` and
  `hosts/nasbox/nix/default.nix:4`.
- `topiary-nushell.nix`: `callPackage` derivation pinning
  blindFS/topiary-nushell; consumed at `nixvim/plugins/conform-nvim.nix:11` as the
  `topiary_nu` nushell formatter.

## Notable patterns

- interface/default split: `imports = [ ./interface.nix ]`, `config = mkIf cfg.enable ...`.
- Platform gating inside config via `pkgs.stdenv.hostPlatform.isLinux/isDarwin`
  (systemd vs launchd; atuin:78/111, ollama:48/56, ssh-client:90/110).
- keep-sorted markers on import lists (nixvim/default.nix:11-17, nix-cache.nix).
- Shared data via plain imports (colors), not module options.

## Related pages

- [modules-linux](../modules-linux/index.md)
- [assets](../assets/index.md)
