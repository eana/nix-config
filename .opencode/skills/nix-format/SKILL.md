---
name: nix-format
description: Format and lint this Nix config repo correctly before submitting changes
compatibility: opencode
---

## Formatter stack

treefmt orchestrates all formatters via `nix fmt`:

| Language | Formatter | Notes |
| --- | --- | --- |
| Nix | nixfmt | Default rules; avoid manual alignment |
| Lua | stylua | 2-space indent, no tabs |
| Markdown | mdformat | 80-100 columns preferred; tables may flow |
| All | keep-sorted | Sorts marked lists |

## How to format

```bash
# Format everything
nix fmt

# Check a single path without applying changes
nix run .#formatter -- --fail-on-change <path>

# Quick diff after formatting (should be minimal)
git diff
```

## keep-sorted rules

- Lists wrapped in keep-sorted markers are sorted automatically by `nix fmt`
- Do not hand-sort or reorder them manually
- Do not remove keep-sorted markers
- After adding an item to a sorted list, run `nix fmt` to reorder

## Nix style rules

- nixfmt default rules apply; do not manually align attrsets or argument lists
- Lower-case with hyphens for file and module names
- Avoid trailing whitespace; files must end with a newline

## Lua style rules (nixvim)

- stylua output: 2-space indent, no tabs
- Table keys: snake_case
- Prefer local functions over globals

## Markdown style rules

- One top-level heading per document
- Use lists for steps; prefer short lines
- Preserve README brevity

## Pre-commit hooks

The following hooks run automatically on commit and via
`nix develop -c pre-commit run --all-files`:

- `check-json` — validate JSON files
- `check-xml` — validate XML files
- `check-merge-conflict` — detect leftover conflict markers
- `end-of-file-fixer` — ensure files end with a newline
- `deadnix` — flag unused Nix bindings
- `statix check` — Nix linting
- `treefmt --fail-on-change` — enforce formatting

Hook configuration lives in `dev/pre-commit.nix`; do not edit
`.pre-commit-config.yaml` directly (it is generated).
