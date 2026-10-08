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
- Repo has no `wiki/` yet, or has one from a prior run

## Output Location

`wiki/` - all wiki files go to the `/wiki` directory at the repository root, unless the user specifies otherwise. Directory structure:

```
wiki/
├── index.md                          # architecture overview
├── diagrams/                         # ALL diagrams here (source + rendered)
│   ├── architecture.d2               # D2 source
│   └── architecture.svg              # rendered SVG
├── unit-a/
│   └── index.md
└── unit-b/
    └── index.md
```

Key rules:

- All diagrams (`.d2` source and `.svg` output) go in `wiki/diagrams/` only
- Unit pages go in `wiki/<unit-slug>/index.md` (see slugification rule below)
- Never place diagrams alongside markdown files

### Slugification

Unit names are directory paths (for example `modules/linux` or `assets/.config/opencode/skills/repo-wiki`). For the page directory, slugify the unit name by replacing `/` with `-`, so unit `modules/linux` becomes `wiki/modules-linux/index.md`. This keeps every unit page at depth 1 instead of creating intermediate directories that are not themselves units.

- The unslugified path stays in the link text (e.g. `[modules/linux](modules-linux/index.md)`) and in the `source_paths` frontmatter.
- If two unit names collide after slugification (e.g. `skills/demo` and `skills-demo` both slug to `skills-demo`), append `-2`, `-3`, etc. to the later page and note the collision in `wiki/index.md`.

### Root unit

The root unit (unit name `.`, detected from top-level files like `README.md`) does NOT get its own page. Fold its content into `wiki/index.md` alongside the architecture overview.

## Cache Location (optional semantic index)

`.wiki-cache/` at the repository root. This is separate from `wiki/` and MUST be gitignored. It holds the embedding index used by Phase 0. If the index tools are unavailable, this directory simply does not exist and everything below degrades gracefully.

```
.wiki-cache/
├── index.json           # chunk metadata: unit, file, line range, content hash
├── vectors.bin          # raw float32 embeddings (or sqlite-vec / LanceDB file)
├── manifest.json        # owned by repo-wiki-index: last commit, model, dim
└── skill-config.json    # owned by this skill: tunables like the semantic-skip threshold
```

`manifest.json` is written by `repo-wiki-index` and never by this skill. Skill-level tunables go in `skill-config.json`, which the indexer does not read or write. Do NOT store skill state in `manifest.json` - Phase 0 overwrites it on every run.

Never commit `.wiki-cache/`. If `.gitignore` already contains entries matching `.wiki-cache*`, leave them alone. Otherwise append the glob `.wiki-cache*` (no trailing slash) so it also catches a symlinked `.wiki-cache` and multi-model variants like `.wiki-cache-8b`. Only append - never replace existing entries; other ignore rules are almost certainly there for a reason.

## Temporary Files

Store all temporary files (scratch work, intermediate D2 sources before rendering, etc.) in `/tmp`. Clean up `/tmp` after wiki generation completes. Do NOT confuse `/tmp` scratch with the persistent `.wiki-cache/` index - the index survives across runs by design.

## Running the Tooling

Both `repo-wiki-index` and `repo-wiki-query` are installed on PATH alongside this skill (they ship in the same package). Invoke them directly from the repo root:

```bash
repo-wiki-index --repo .
repo-wiki-query --list-units --repo .
repo-wiki-query --unit <unit> --top-k 30 "<query>" --repo .
```

The tools talk to an Ollama endpoint (default `http://localhost:11434`, override with `OLLAMA_URL`) serving the embedding model (default `qwen3-embedding:0.6b`, override with `REPO_WIKI_EMBED_MODEL`). If the tools are not on PATH, or Ollama is unreachable, skip the semantic index and run the skill without it - Phases 1-4 still work.

## Phase 0: Optional Semantic Index

Before Phase 1, check whether the indexing tools are available (see "Running the Tooling" above).

- If available: run `repo-wiki-index --repo .` from the repo root. First run performs a full index into `.wiki-cache/`. Subsequent runs are incremental (content-hash based, skips unchanged chunks). The tool prints the top-10 units by file count so you can eyeball unit boundaries.
- If unavailable: skip this phase entirely. Phases 1-4 still work; only the enhancements below are lost:
  - Top-K retrieval in Phase 2 subagents
  - Cross-unit similarity on `index.md`
  - Semantic (rather than pure git-diff) refresh in Phase 4

If `manifest.json` exists but the model name differs from the currently configured embedding model, treat the index as stale and re-index fully before proceeding.

## Phase 1: Identify Units

A "unit" is a structural piece worth its own page (service, package, module, app). Detect generically:

1. Look for directories containing a manifest: `go.mod`, `package.json`, `Cargo.toml`, `pyproject.toml`, `flake.nix`, `SKILL.md`, `*.csproj`
2. Fall back to conventional root directories: `services/`, `packages/`, `apps/`, `libs/`, `cmd/`
3. Only consider files tracked by git (use `git ls-files` to list tracked files). Ignore untracked files and directories.
4. If a conventional root has 15+ children that are structurally similar (e.g. all thin Terraform wrappers), group them into a table on one page instead of one page each - one-page-per-unit degrades fast past a couple dozen units. Use judgment: deep-dive the 2-3 richest/most representative units, table the rest.
   - If the semantic index from Phase 0 exists, use it to group more defensibly: cluster unit embeddings and let the clusters define the table groups. Fall back to judgment when the index is absent.

**Never infer a unit's purpose from its directory name alone.** If the unit has no README and its source wasn't read, write the page but explicitly flag the entry as unverified (e.g. "purpose inferred from directory name only - not verified against source"). Guessing silently produces a wiki users can't trust.

## Phase 2: Explore in Parallel

**REQUIRED SUB-SKILL:** Use `dispatching-parallel-agents` to dispatch one `explore` subagent per unit (or per unit-group for tabled units), not sequential tool calls. Sequential batching for an N-unit repo costs N rounds; parallel dispatch costs 1.

**Trivial-repo exception:** if there are fewer than 4 units, or every unit fits comfortably in the dispatching agent's context, read the files directly and skip dispatch. Dispatching subagents to read a handful of tiny files is pure overhead. Use judgment: if you can read the whole repo in one or two `cat` calls, do that instead.

When exploring a unit, ignore all binary files (images, .svg files, PDFs, compiled binaries, etc). Only send text-based files to the LLM (source code, markdown, YAML, JSON, config files, etc). This keeps context clean and reduces token waste.

If `.wiki-cache/` exists, the dispatching agent MUST run `repo-wiki-query --list-units --repo .` once before dispatch and pass each subagent its exact unit name (unit names are directory paths, e.g. `assets/.config/opencode/skills/repo-wiki`).

The dispatch list is the union of two sources: (a) the units detected in Phase 1, and (b) the units reported by `--list-units`. A unit that appears in (a) but not (b) simply has no indexable chunks - files below the chunker's minimum size, or content types the indexer skips. Dispatch it anyway and instruct its subagent to read files directly rather than querying the index. Do NOT silently drop units just because the index omits them.

Each subagent then:

- Runs `repo-wiki-query --unit <exact-unit-name> --top-k 30 "<query>" --repo .` where the query reflects what the subagent is trying to learn (e.g. "purpose and entry points", "external dependencies", "data flow and persistence"). Use `--path <substring>` instead of `--unit` when the query crosses unit boundaries or when the unit is too broad (e.g. `modules` with 86 chunks - narrow to `--path modules/linux`).
- Reads the returned chunk text as the primary context for its report.
- Falls back to direct file reading for any unit the index does not cover, or when the query returns nothing useful. Retrieval is an optimization, not a replacement for judgment.

If the query tool is not available, skip retrieval entirely and read files directly.

Each subagent returns: purpose (verified against actual source/config, not just file names), key files, dependencies, data flow, notable patterns.

## Phase 3: Synthesize

Assemble subagent results into markdown and diagrams. IMPORTANT: All generated content MUST use only ASCII characters - no emdashes, emojis, or non-ASCII characters. Use hyphens (-) instead of emdashes, spell out symbols, and keep all text ASCII-safe.

- `wiki/index.md`: one paragraph overview, reference to architecture diagram at `diagrams/architecture.svg`, link table to all unit pages, plus any content folded in from the root unit
- Per-unit pages: `wiki/<unit-slug>/index.md`, each starting with YAML frontmatter

If the semantic index from Phase 0 exists, compute pairwise similarity between unit embeddings and mention the 2-3 strongest cross-unit couplings in `index.md` (for example: "unit-a and unit-c share the config loader pattern", "unit-b and unit-d both wrap the same HTTP client"). This is often the most valuable content on the overview page because it surfaces couplings that local exploration misses. Only state a coupling if the similarity is high AND a subagent confirmed a concrete shared artifact - do not list raw cosine scores.

### Working tree state

Before writing any page, check `git status --porcelain`. If the output is non-empty, the generated wiki will reflect the working tree, not `HEAD`. In that case:

1. Warn the user in the summary: "Wiki generated from a dirty working tree - uncommitted changes to <paths> are included."
2. Add `generated_dirty: true` to the YAML frontmatter of every generated page.
3. Still set `generated_commit` to the current `HEAD` (that is the commit the working tree was diffed against).

If the working tree is clean, omit `generated_dirty` entirely. Do NOT write `generated_dirty: false` - absence is the signal for "clean".

A page with `generated_dirty: true` cannot be trusted to correspond to any commit, so Phase 4 must regenerate it unconditionally (see Phase 4 step 1) rather than relying on the git-log check.

### Page Structure

Every generated page MUST follow this structure (order is critical):

1. YAML frontmatter at top
2. Page title and content
3. Related pages section at bottom (optional)

Frontmatter format - `source_paths` as block list, one path per line, not flow style:

```yaml
---
generated_commit: 4dabfa9664ac5bd1da568fe5fdc940097102b60a
generated_at: 2026-10-07T14:32:11Z
source_paths:
  - .
  - cmd
  - internal
---
```

Optional keys:

- `generated_dirty: true` - set only when the working tree was dirty at generation time (see "Working tree state" above).

Set `generated_at` to the actual generation time in UTC ISO 8601 format (`date -u +%Y-%m-%dT%H:%M:%SZ`), not a hardcoded midnight value. Real timestamps make it possible to tell when a page was regenerated versus when it was last edited manually.

### Diagram Generation

Generate D2 diagrams and render them to SVG:

1. Create `.d2` source file (e.g. `wiki/diagrams/architecture.d2`). Prefer standard D2 shapes (`rectangle`, `circle`, `diamond`, `cylinder`, `queue`, `package`, `document`, `cloud`). Some intuitive names are not supported (e.g. `note`), so if a shape fails to compile, fall back to `rectangle` or omit the shape and retry.
2. Render to SVG using the d2 command:
   - If `d2` command is available: `d2 --layout elk --sketch --theme 1 <diagram.d2>`
   - If not available, use Nix: `nix run nixpkgs#d2 -- --layout elk --sketch --theme 1 <diagram.d2>`
3. Run `chmod 644 <diagram.svg>` after rendering. d2 writes SVGs with mode `0600` by default, which shows up as an uncommitted permission change on some systems and confuses git status.
4. Reference the generated SVG in markdown: `![Architecture](diagrams/architecture.svg)`
5. Commit both the `.d2` source and generated `.svg` to the repo

Keep diagram source in `wiki/diagrams/` and rendered SVGs in the same directory. Reference them from markdown via relative image links.

### First-run staging

On a first run (no `wiki/` existed), the `.gitignore` change and the `wiki/` tree belong in the same commit. Do not commit `wiki/` without the ignore rule, or the next run's `.wiki-cache/` will appear as untracked noise in git status.

## Phase 4: Refresh Mode (existing `wiki/`)

Default behavior when `wiki/` already exists - do not blindly regenerate everything:

1. For each existing page, read `source_paths`, `generated_commit`, and `generated_dirty` from frontmatter. If `generated_dirty: true`, skip the git-log check and regenerate the page unconditionally - the previous run captured a working tree that no longer corresponds to any commit, so `git log` cannot tell you whether the page is stale.
2. Otherwise run `git log <generated_commit>..HEAD -- <source_paths>` - if empty, the unit is unchanged, **leave the page untouched** (preserves any manual edits the user made after review)
3. If non-empty AND `.wiki-cache/` exists, apply the semantic skip: re-embed the changed unit's current content, compare to its cached embedding, and if cosine similarity to the previous version is above the semantic-skip threshold, treat the change as cosmetic and skip regeneration. Log skipped units in a "Cosmetic changes ignored" section at the end of the refresh output.
4. If non-empty and the semantic skip did not fire (or the index is unavailable), re-dispatch the explore subagent for that unit only and resynthesize that page
5. Re-run Phase 1 unit detection against current repo state:
   - New unit, no matching page -> generate it
   - Existing page, unit's `source_paths` no longer exist -> do not delete silently; list it under a "Stale - possibly removed" section in `index.md` for the user to confirm

The semantic-skip threshold defaults to 0.97. Before applying the skip, read `.wiki-cache/skill-config.json` if it exists and use its `semantic_skip_threshold` value. If the user complains that real changes are being skipped, lower the threshold; if cosmetic churn keeps regenerating pages, raise it. When the user changes the threshold, write the new value to `.wiki-cache/skill-config.json` (create the file if needed). Do NOT write it to `manifest.json` - Phase 0 overwrites that file on every run.

Sidecar format:

```json
{
  "semantic_skip_threshold": 0.97
}
```

## Quick Reference

| Situation                                     | Action                                                                     |
| --------------------------------------------- | -------------------------------------------------------------------------- |
| No `wiki/` yet                                | Full generation, all phases                                                |
| `wiki/` exists, user says "refresh"           | Phase 4: diff-aware, only regenerate changed units                         |
| Working tree has uncommitted changes          | Warn user; set `generated_dirty: true` in all pages                        |
| Page has `generated_dirty: true`              | Phase 4 regenerates unconditionally, ignores git-log check                 |
| Index tooling not available                   | Skip Phase 0; run Phases 1-4 without retrieval or semantic skip            |
| Tools on PATH but Ollama unreachable          | Index/query fail; skip Phase 0 and read files directly                     |
| `.wiki-cache/` missing during refresh         | Fall back to pure git-diff refresh (Phase 4 step 4)                        |
| Unit has no README, source unread             | Flag as unverified, don't guess silently                                   |
| Unit too broad for `--unit` (e.g. 80+ chunks) | Use `--path <subdir>` to narrow instead                                    |
| Repo is trivial (< 4 units, small files)      | Skip parallel dispatch; read files directly                                |
| Unit in Phase 1 but not in `--list-units`     | Dispatch anyway; instruct subagent to read files directly                  |
| >15 structurally similar units                | Group into a table, deep-dive only the representative few                  |
| User flags one page as wrong after review     | Edit that page directly - don't regenerate the whole wiki for one bad page |
| D2 command not available                      | Use `nix run nixpkgs#d2 -- <file.d2> <file.svg>` to render diagrams        |

## Common Mistakes

- **Sequential exploration instead of parallel subagents** - costs N rounds instead of 1 for N units (except on trivial repos, where direct reading is correct).
- **Dispatching subagents on a 6-file repo** - pure overhead. The trivial-repo exception in Phase 2 exists for this case.
- **Ignoring a dirty working tree** - if `git status --porcelain` is non-empty, `HEAD` no longer describes what the wiki was generated from. Set `generated_dirty: true` and warn, or the next Phase 4 refresh will wrongly report the pages as unchanged.
- **Writing `generated_dirty: false`** - absence of the key is the clean signal. Do not write the false case.
- **Name-based guessing presented as fact** - write "likely handles X based on directory name" only when actually true; otherwise explicitly flag as unverified.
- **Full regeneration on every refresh** - destroys manual corrections the user made to previous pages. Always diff first (except for pages already marked dirty).
- **One page per unit in a 35-service monorepo** - produces 35 shallow pages nobody reads. Group and table past a certain scale.
- **Dropping units absent from `--list-units`** - the index omits units whose files are all under the chunker's minimum size. Dispatch them anyway and read files directly.
- **Inlining D2 code in markdown instead of separate files** - prevents rendering and makes diagrams hard to edit. Create `.d2` files in `wiki/diagrams/`, render them to SVG using `d2 <file.d2> <file.svg>` (or `nix run nixpkgs#d2`), and reference via image embeds.
- **Forgetting `chmod 644` on rendered SVGs** - d2 writes mode `0600` by default, which git flags as a permission change. Fix the mode immediately after rendering.
- **Using non-ASCII characters in generated content** - Use only ASCII (no emdashes, emojis, or special unicode). Replace emdashes with hyphens (-), spell out symbols, keep all text ASCII-compatible.
- **Using `grep -P` for the ASCII check** - BSD grep (the default on macOS) does not support `-P`. Use `rg '[^\x00-\x7F]' wiki/` instead; it is portable and matches the same character class.
- **Including untracked files in the wiki** - Only analyze files tracked by git. Use `git ls-files` to filter. Untracked files (build artifacts, .gitignore'd content, temporary files) should be completely ignored.
- **Sending binary files to the LLM** - Ignore all binary files: images (.svg, .png, .jpg, etc), PDFs, compiled binaries, archives. Only send text-based files (source code, markdown, YAML, JSON, config) to subagents. This keeps context clean and reduces token waste.
- **Committing `.wiki-cache/`** - the embedding index is a local artifact. Add it to `.gitignore` and never commit it. Only `wiki/` goes in git.
- **Replacing `.gitignore` entries instead of appending** - if `.gitignore` already matches `.wiki-cache*`, leave it. Only append when no matching rule exists.
- **Re-embedding the whole repo on every refresh** - the indexer must be incremental (content-hash based). Full reindex is a Phase 0 first-run cost only.
- **Storing skill state in `manifest.json`** - Phase 0 overwrites it on every run. Skill tunables like the semantic-skip threshold belong in `.wiki-cache/skill-config.json`.
- **Treating the semantic skip as authoritative** - the threshold is a heuristic. If a user reports a page is stale after a refresh that skipped it, the threshold is wrong for that repo; surface the skip in the output so it is visible.
- **Forgetting `--repo .`** - `repo-wiki-index` and `repo-wiki-query` default to the current directory, but if the shell's cwd drifts, pass `--repo .` explicitly.
- **Guessing unit names from the tree instead of asking the index** - always run `--list-units` first. Unit names are full directory paths and rarely match intuition (e.g. `assets/.config/opencode/skills/repo-wiki`, not `repo-wiki`).
- **Using a hardcoded midnight timestamp for `generated_at`** - use `date -u +%Y-%m-%dT%H:%M:%SZ` so the frontmatter reflects when the page was actually regenerated.
- **Inconsistent slugification across runs** - slugify `/` to `-` so `skills/demo` always becomes `wiki/skills-demo/index.md`. Non-deterministic page paths break Phase 4's refresh matching.
- **Giving the root unit its own page** - the root unit (`.` from top-level files) folds into `wiki/index.md`, not `wiki/root/index.md` or similar.
- **Committing `wiki/` without the `.gitignore` change** - on a first run, stage both in the same commit or `.wiki-cache/` will show as untracked on every subsequent run.

## Optional Tooling

This skill optionally uses two external tools. Neither is required.

- `repo-wiki-index` - walks `git ls-files`, chunks text files by logical unit (function/class for Go/TS/Python; file-level for Nix/Terraform), embeds each chunk, and writes `.wiki-cache/`. Incremental on re-run via content hashes. Prints the top-10 units by file count on each run. Owns `manifest.json`.
- `repo-wiki-query` - takes a natural-language query plus optional `--unit`, `--path`, `--top-k`, `--max-chars`, `--files-only`, `--json`, `--list-units`, and `--cache-dir` flags; returns the most similar chunks from `.wiki-cache/`.

Both tools ship in the `repo-wiki` Nix package (defined in the config repo that installs this skill) and are placed on PATH together with the skill, so no devshell prefix is needed. Ollama with a code-oriented model (`nomic-embed-text`, `mxbai-embed-large`, or `qwen3-embedding`) works well and keeps everything offline. A cloud embedding API (OpenRouter, Mistral) is a drop-in alternative if local compute is limited.

If neither tool is present, this skill behaves exactly as it did before Phase 0 existed.
