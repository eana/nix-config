---
name: repo-wiki
description: Use when the user asks to generate, create, or refresh a wiki/architecture documentation for a repository - covers identifying structural units, parallel exploration, and incremental updates that preserve manually-edited pages.
---

# Repo Wiki

Generate or refresh markdown wiki pages documenting a repository's architecture. Generic - works on any repo (Go, Node, Nix, Terraform, monorepo or single-package), no hardcoded assumptions about structure.

## When to Use

- "generate a wiki for this repo"
- "create architecture docs for this project"
- "refresh the wiki" / "update the wiki, some pages are outdated"
- Repo has no `docs/wiki/` yet, or has one from a prior run

## Output Location

`docs/wiki/` at the repo root, unless the user specifies otherwise:

- `docs/wiki/index.md` - architecture overview with link to architecture diagram and links to all unit pages
- `docs/wiki/<unit-name>/index.md` - one page per unit, each in its own subdirectory
- `docs/wiki/<unit-name>/diagram.svg` - optional diagram for that unit (generated from `.d2` source)
- `docs/wiki/diagrams/` - directory of generated SVG diagrams referenced by markdown files

## Phase 1: Identify Units

A "unit" is a structural piece worth its own page (service, package, module, app). Detect generically:

1. Look for directories containing a manifest: `go.mod`, `package.json`, `Cargo.toml`, `pyproject.toml`, `flake.nix`, `*.csproj`
2. Fall back to conventional root directories: `services/`, `packages/`, `apps/`, `libs/`, `cmd/`
3. Only consider files tracked by git (use `git ls-files` to list tracked files). Ignore untracked files and directories.
4. If a conventional root has 15+ children that are structurally similar (e.g. all thin Terraform wrappers), group them into a table on one page instead of one page each - one-page-per-unit degrades fast past a couple dozen units. Use judgment: deep-dive the 2-3 richest/most representative units, table the rest.

**Never infer a unit's purpose from its directory name alone.** If the unit has no README and its source wasn't read, write the page but explicitly flag the entry as unverified (e.g. "purpose inferred from directory name only - not verified against source"). Guessing silently produces a wiki users can't trust.

## Phase 2: Explore in Parallel

**REQUIRED SUB-SKILL:** Use `dispatching-parallel-agents` to dispatch one `explore` subagent per unit (or per unit-group for tabled units), not sequential tool calls. Sequential batching for an N-unit repo costs N rounds; parallel dispatch costs 1.

When exploring a unit, ignore all binary files (images, .svg files, PDFs, compiled binaries, etc). Only send text-based files to the LLM (source code, markdown, YAML, JSON, config files, etc). This keeps context clean and reduces token waste.

Each subagent returns: purpose (verified against actual source/config, not just file names), key files, dependencies, data flow, notable patterns.

## Phase 3: Synthesize

Assemble subagent results into markdown and diagrams. IMPORTANT: All generated content MUST use only ASCII characters - no emdashes, emojis, or non-ASCII characters. Use hyphens (-) instead of emdashes, spell out symbols, and keep all text ASCII-safe.

- `docs/wiki/index.md`: one paragraph overview, reference to architecture diagram at `diagrams/architecture.svg`, link table to all unit pages
- Per-unit pages: `docs/wiki/<unit-name>/index.md`, each starting with YAML frontmatter

### Page Structure

Every generated page MUST follow this structure (order is critical):

1. YAML frontmatter at top
2. Page title and content
3. Related pages section at bottom (optional)

### Diagram Generation

Generate D2 diagrams and render them to SVG:

1. Create `.d2` source file (e.g. `docs/wiki/diagrams/architecture.d2`)
2. Render to SVG using the d2 command:
   - If `d2` command is available: `d2 --layout elk --sketch --theme 1 <diagram.d2>`
   - If not available, use Nix: `nix run nixpkgs#d2 -- --layout elk --sketch --theme 1 <diagram.d2>`
3. Reference the generated SVG in markdown: `![Architecture](diagrams/architecture.svg)`
4. Commit both the `.d2` source and generated `.svg` to the repo

Keep diagram source in `docs/wiki/diagrams/` and rendered SVGs in the same directory. Reference them from markdown via relative image links.

## Phase 4: Refresh Mode (existing `docs/wiki/`)

Default behavior when `docs/wiki/` already exists - do not blindly regenerate everything:

1. For each existing page, read `source_paths` and `generated_commit` from frontmatter
2. Run `git log <generated_commit>..HEAD -- <source_paths>` - if empty, the unit is unchanged, **leave the page untouched** (preserves any manual edits the user made after review)
3. If non-empty, re-dispatch the explore subagent for that unit only and resynthesize that page
4. Re-run Phase 1 unit detection against current repo state:
   - New unit, no matching page → generate it
   - Existing page, unit's `source_paths` no longer exist -> do not delete silently; list it under a "Stale - possibly removed" section in `index.md` for the user to confirm

## Quick Reference

| Situation                                 | Action                                                                     |
| ----------------------------------------- | -------------------------------------------------------------------------- |
| No `docs/wiki/` yet                       | Full generation, all phases                                                |
| `docs/wiki/` exists, user says "refresh"  | Phase 4: diff-aware, only regenerate changed units                         |
| Unit has no README, source unread         | Flag as unverified, don't guess silently                                   |
| >15 structurally similar units            | Group into a table, deep-dive only the representative few                  |
| User flags one page as wrong after review | Edit that page directly - don't regenerate the whole wiki for one bad page |
| D2 command not available                  | Use `nix run nixpkgs#d2 -- <file.d2> <file.svg>` to render diagrams        |

## Common Mistakes

- **Sequential exploration instead of parallel subagents** - costs N rounds instead of 1 for N units.
- **Name-based guessing presented as fact** - write "likely handles X based on directory name" only when actually true; otherwise explicitly flag as unverified.
- **Full regeneration on every refresh** - destroys manual corrections the user made to previous pages. Always diff first.
- **One page per unit in a 35-service monorepo** - produces 35 shallow pages nobody reads. Group and table past a certain scale.
- **Inlining D2 code in markdown instead of separate files** - prevents rendering and makes diagrams hard to edit. Create `.d2` files in `docs/wiki/diagrams/`, render them to SVG using `d2 <file.d2> <file.svg>` (or `nix run nixpkgs#d2`), and reference via image embeds.
- **Using non-ASCII characters in generated content** - Use only ASCII (no emdashes, emojis, or special unicode). Replace emdashes with hyphens (-), spell out symbols, keep all text ASCII-compatible.
- **Including untracked files in the wiki** - Only analyze files tracked by git. Use `git ls-files` to filter. Untracked files (build artifacts, .gitignore'd content, temporary files) should be completely ignored.
- **Sending binary files to the LLM** - Ignore all binary files: images (.svg, .png, .jpg, etc), PDFs, compiled binaries, archives. Only send text-based files (source code, markdown, YAML, JSON, config) to subagents. This keeps context clean and reduces token waste.
