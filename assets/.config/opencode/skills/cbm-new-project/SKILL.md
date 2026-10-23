---
name: cbm-new-project
description: Bootstrap codebase-memory (CBM, codebase memory) for a new or unindexed repo. Loads the native codebase-memory skill, indexes, verifies status and coverage, maps architecture, and reports readiness. Use on "initiate project", "onboard this repo", "index this repo", "set up CBM", "repo is not indexed", or "first time using the graph here". Not for normal graph queries.
compatibility: opencode
metadata:
  opencode/slash: "true"
---

# CBM new project bootstrap

Thin orchestrator. The native `codebase-memory` skill owns CBM tool semantics and evidence rules. This skill only sequences bootstrap.

## Step 0: load native skill

Before any CBM tool call:

```text
skill({ name: "codebase-memory" })
```

If the native skill is unavailable, stop and tell the user to enable
`module.opencode.codebaseMemory`. If CBM MCP is unavailable, stop and tell the
user to check `opencode mcp list`. Do not invent CBM semantics.

## Step 1: establish context

- Resolve the repo root. Use the git root when present, otherwise the current directory.
- Check for git. If absent, warn that `detect_changes` is unavailable. Do not run `git init`.
- Call `list_projects` with `limit=50` and `offset`. Follow `has_more` and `next_offset` until every page is read.
- Choose the project whose `root_path` contains the repo root. Prefer an exact root match, then the longest matching root. If roots tie, ask for the exact project name.
- Never invent a project name. Use the exact indexed `name`.

## Step 2: index

- No matching project: start `index_repository(repo_path=<repo root>, mode="full")`.
- Large repo: start with `async: true`. Async needs a live MCP session or a permanent daemon; a one-shot CLI temporary daemon refuses it.
- Capture the start response:
  - Sync `status`: `indexed`, `degraded`, `error`, `aborted_previous_preserved`, or `persist_failed`.
  - Async `state`: `queued`, `running`, `succeeded`, `failed`, or `cancelled`.
  - Poll async with `index_repository(repo_path=<repo root>, status=true)`. Add `name=<exact>` only when the start call passed `name`.
  - Async status exposes job state, not the sync `degraded` status; failed jobs return an `error` summary. Use `index_status` and coverage after success.
  - Async terminal state: `succeeded` continues to Step 3; `failed` reports `error` and stops; `cancelled` reports and asks.
  - Never read job state from `index_status`.
- After a timeout, call `index_repository(repo_path=<repo root>, status=true)` plus the same `name` if the start call passed one, before starting another job.
- Existing project: call `index_repository(repo_path=<repo root>, name=<exact>, status=true)` for job state, then `index_status(project=<exact>, diagnostics="summary")` for graph readiness.
  - Job `queued`, `running`, or `cancelling`: poll the job instead of asking.
  - `ready`: use the index. If `watch.watched` is false, say it is not auto-refreshed; do not call it stale.
  - `empty` or `error`: ask before reindexing. If the user declines, stop and report no usable index.
  - `no_project`: index as above.
  - User said "refresh" or "reindex": call `index_repository(repo_path=<repo root>, name=<exact>, mode="full")`.
- Capture the exact `project` from `list_projects` or the index response.
- `degraded`: partial result. Inspect `nodes`, `edges`, and `hint`. If the store was removed or no graph was persisted, ask to reindex; if declined, stop. Otherwise report gaps and use what exists. `error`: stop. `aborted_previous_preserved` or `persist_failed`: report the failure and verify whether a previous graph still serves.
- If the user declines reindex on a `ready` graph, continue and report working-tree freshness not verified.
- Never silently reindex.

## Step 3: verify

Call `index_status` once after any index run; otherwise reuse the Step 2 result. Call it again only when the graph changed.

Report readiness, counts, `root_path`, `indexed_at`, `watch`, and coverage gaps. Report the index run outcome separately. Mode and generation come only from `check_index_coverage.metadata` (`index_mode`, `generation`, `generation_matches`). Working-tree freshness is not directly available; do not invent it.

## Step 4: map

1. Call `get_graph_schema(project=<exact>)`.
2. Call `get_architecture(project=<exact>, aspects=["overview", "structure", "dependencies", "entry_points", "packages", "hotspots"])`.
3. After selecting evidence paths, call `check_index_coverage(project=<exact>, paths=[...])`.
   - Max 128 paths and 32 scopes per call. Provide at least one path or scope.
   - `path_limit` and `path_offset` page path rows; follow `path_has_more` and `path_next_offset`.
   - `scope_limit` and `scope_offset` page flattened scope coverage rows; follow root `has_more` and `next_offset`.
   - Use `metadata.index_mode`, `metadata.generation`, and `metadata.generation_matches`.
4. Read or grep reported gap ranges before relying on them.

## Step 5: report

Use this shape:

- Project:
- Root:
- Index run: indexed | degraded | error | aborted_previous_preserved | persist_failed | unknown
- Index mode: from coverage metadata, else unknown
- Generation: from coverage metadata, else unknown
- Readiness: ready | empty | error | no_project
- Job: idle | queued | running | cancelling | succeeded | failed | cancelled | not checked
- Graph: nodes and edges
- Watch: watched or reason
- Coverage gaps: source and counts
- Freshness: indexed_at; working-tree freshness not verified
- Entry points:
- Main packages:
- Hotspots:
- Risks:
- Suggested next query:

## Guardrails

- Do not duplicate the native CBM tool matrix.
- Do not run `git init` or create commits.
- Do not call `delete_project`.
- Do not claim absence, dead code, or complete impact from bootstrap.
- Do not call a ready index stale without evidence.
- Do not write an ADR automatically. Offer `manage_adr` as a next step.
- Keep all output ASCII.
