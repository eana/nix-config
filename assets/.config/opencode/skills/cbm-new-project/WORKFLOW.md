# Codebase Memory workflow

Use one OpenCode session per repository root. Bootstrap the index once, then use
the graph for structural questions.

## 1. Start at the repo root

```sh
cd /path/to/repo
opencode
```

Use the git root for monorepos. Git worktrees are separate roots, so each needs
its own index. Keep the session open while a large async index runs.

## 2. Bootstrap a new or unindexed repo

First prompt:

```text
Onboard this repo with codebase-memory. Index it if needed, then report architecture and readiness.
```

Equivalent prompts:

```text
Use the cbm-new-project skill for this repo.
Index this repo with CBM.
Set up codebase-memory here.
```

Do not start with a full-repo grep or ask for an exhaustive impact analysis. The
bootstrap skill loads the native `codebase-memory` skill, resolves the repo root,
finds the exact project by `root_path`, indexes only when needed, verifies the
result, and maps the architecture.

## 3. Read the bootstrap report

Check these fields:

- `Project`: exact CBM project name.
- `Root`: indexed repository root.
- `Readiness`: `ready` means use the graph.
- `Graph`: node and edge counts.
- `Watch`: `watch.watched: false` means manual refresh is needed.
- `Coverage gaps`: files or scopes the index did not cover.
- `Index mode` and `Generation`: use coverage metadata, not guesses.
- `Freshness`: `indexed_at` does not prove the working tree is current.

Handle non-ready outcomes:

- `degraded`: inspect `nodes`, `edges`, and `hint`. If the store was removed or
  no graph was persisted, reindex. Otherwise report gaps and use what exists.
- `empty` or `error`: do not query the graph. Ask before reindexing.
- Async `failed`: report the `error` summary and stop.
- Async `cancelled`: report and ask whether to retry.
- Async `succeeded`: continue to verification and mapping.

Never silently reindex. Never read job state from `index_status`.

## 4. Use graph-shaped questions

Good first questions:

```text
Who calls this function?
What does this handler call?
Trace this path from entry point to side effect.
Map the architecture of this module.
What code is affected by this diff?
Find high fan-out functions in this package.
```

Default tool sequence:

1. `search_graph` to find exact symbols.
1. `trace_path` to follow callers, callees, or both.
1. `get_code_snippet` to read the exact source.
1. `check_index_coverage` for every file or scope relied on.
1. Read or grep reported gaps before making a claim.

Use `get_architecture` for broad structure, `query_graph` for multi-hop
questions, and `detect_changes` for diffs.

CBM is for structure. Use grep and file reads for string literals, config values,
logs, and non-code files.

## 5. Handle later sessions

- If the session context says the repo is indexed, do not bootstrap again. Ask
  the graph question directly.

- If the repo is unindexed, run the bootstrap prompt again.

- If code or branch changed, say:

  ```text
  Refresh this repo index.
  Reindex this repo.
  ```

- If `watch.watched` is false, ask for a refresh instead of assuming the graph is
  current.

- Do not call a ready index stale without evidence.

## 6. Add a feature to an indexed repo

Do not run the bootstrap skill again. The index persists across sessions.

1. Start at the same repo root and attach to the existing project:

   - Use the project named in the session banner, or call `list_projects` and
     match by `root_path`.
   - Call `index_status(project=<exact>)` and require `readiness: ready`.
   - If `watch.watched` is false, or you switched branch or pulled since the
     last index, refresh before relying on impact results.
   - A git worktree is a different root. Onboard or index that worktree
     separately.

1. Ask for discovery before planning:

   ```text
   This repo is already indexed. Do not reindex unless needed. Use
   codebase-memory to find where <feature> belongs: entry points, analogous
   implementations, call flow, tests, config, and likely impact. Check coverage
   for every file you cite. Do not edit yet.
   ```

1. Discover with the graph:

   - `search_graph` for domain names, handlers, services, tests, and config.
   - `get_code_snippet` for the existing implementation.
   - `trace_path(direction="both")` around the change point.
   - `get_architecture(project=<exact>, path="src/feature-area")` for a scoped
     map.
   - `search_code` or grep for literals and config the graph does not model.
   - `check_index_coverage` for every path or scope relied on.

   A new feature has no indexed symbols yet. Use the graph to find the nearest
   analogous feature, entry points, extension patterns, and tests.

1. Plan before editing. Name the files and symbols, interfaces, data contracts,
   affected call paths, new tests, migrations, and coverage limits.

1. Implement in small steps. After each meaningful change, run
   `detect_changes(scope="impact")`, then `detect_changes(scope="tests")`.
   Check coverage before relying on impacted symbols.

   Newly added symbols are absent from the graph until it refreshes. Refresh
   before tracing callers or impact for new code.

1. Verify with focused tests, then lint, typecheck, build, and repo checks. Use
   `check_index_coverage` for changed and impacted files. Reindex after large
   changes if structural analysis will continue.

1. Offer `manage_adr` as an optional follow-up. Do not write an ADR
   automatically.

Core rule:

```text
Graph before edit for discovery.
detect_changes after edit for impact.
Reindex before tracing new symbols.
Read source before making claims.
```

## 7. Choose a confidence tier

- Scout: quick positive lookup. Results are provisional.
- Verify: default for normal work. Search, trace, read snippets, and check
  coverage.
- Auditor: exhaustive or negative claims, dead-code claims, complete impact
  analysis, and high-stakes changes. Verify both call directions and relevant
  pagination.

For partial, skipped, excluded, stale, pending, or unknown coverage, read the
reported ranges directly. A clean coverage check is not proof of completeness.

## 8. Avoid these mistakes

- Starting outside the repo root.
- Reindexing on every session.
- Querying an empty, failed, or cancelled index.
- Treating async `failed` as success.
- Using `index_status` for job state.
- Making absence, dead-code, or complete-impact claims from a bootstrap.
- Assuming `indexed_at` matches the working tree.
- Using the graph for literal text that grep handles better.
