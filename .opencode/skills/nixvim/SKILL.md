---
name: nixvim
description: Conventions for editing the declarative nixvim Neovim configuration in this repo
compatibility: opencode
---

## Two Neovim configs — do not confuse them

| Path | Purpose | Active by default |
| --- | --- | --- |
| `modules/common/nixvim/` | Primary declarative config via nixvim module | Yes (all hosts) |
| `assets/.config/nvim/` | Standalone LazyVim config used by the `neovim` module | No (disabled by default) |

Always edit `modules/common/nixvim/` unless explicitly working on the LazyVim config.

## Lua style (stylua)

- 2-space indent, no tabs
- Table keys: snake_case
- Prefer `local` functions over globals
- When adding keymaps, always include a concise `desc` field

## Embedding Lua in nixvim Nix files

Use these patterns — do not create standalone `.lua` files inside `modules/`:

```nix
# Keymap action with raw Lua function
action.__raw = ''
  function()
    -- lua code here
  end
'';

# Module-level init code
extraConfigLua = ''
  -- lua code here
'';

# Post-init code
extraConfigLuaPost = ''
  -- lua code here
'';
```

## LSP servers

Currently enabled: `bashls`, `docker*`, `helm_ls`, `terraformls`, `tflint`,
`gopls`, `pyright`, `lua_ls`, `jsonls`, `yamlls`, `nixd`, `marksman`

When adding a new language server:

- Add it to the same attrset as existing servers
- Keep sorted grouping (by language family)
- Formatting is disabled on LSP attach — do not re-enable unless intentional

## Plugin enable/disable

- Respect existing `enable = true/false` flag patterns
- Keep LSP/server configs declarative
- Avoid runtime side effects in `onAttach` beyond keymaps and formatting toggles
