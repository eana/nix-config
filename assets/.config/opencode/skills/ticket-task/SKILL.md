---
name: ticket-task
description: Use when implementing exactly one task from a docs/tasks/<slug>/ task directory, by ID (e.g. "ticket-task my-feature T03"), in a fresh session or as a subagent of ticket-run. Also the reference for the task file format used by ticket-plan and ticket-run.
compatibility: opencode
---

# Ticket Task

Implement ONE task from a task directory. Stay inside that task. The task files
are the only memory: what is not written there does not exist for the next agent.

Invocation: `ticket-task <slug> <ID>`.

## Format (canonical)

Task directory: `docs/tasks/<slug>/`. If the project's `AGENTS.md` has a line
`Task dir: <path>`, use `<path>/<slug>/` instead.

`index.md`:

```markdown
# <Feature title>

- Spec: <path>
- Plan: <path>
- Verify: `<command>` [, `<command>`]

| ID | Title | Status | Depends on | Review point |
|----|-------|--------|------------|--------------|
| T01 | ... | open | - | no |
| T02 | ... | open | T01 | yes |
```

- Status values, nothing else: `open`, `in_progress`, `done`, `blocked`.
- `Depends on`: comma-separated IDs or `-`.
- Ready = status `open` and every `Depends on` ID is `done`.
- `index.md` is the single source of truth for status and dependencies.

Task file `TNN-<kebab-name>.md`, sections in this order:

```markdown
# TNN: <Title>

## Task
<plan text for this task, verbatim>

## Acceptance
<tests that must fail first and then pass, or exact verification commands>

## Scope
<one path or glob per line: the only files this task may change>

## Checkpoints

## Summary
```

Summary, when done:

```markdown
## Summary
- Why: <one or two lines>
- What: <what changed>
- Files touched: <list>
- Verification: <command> -> <result>
```

## Procedure

1. **Preconditions.** Run `git status --porcelain --untracked-files=no`. If output
   is non-empty, or any
   task in `index.md` is `in_progress`, STOP and report what you found. Do not
   clean, stash or reset anything. If the task is not ready (status not `open`
   or a dependency not `done`), STOP and report.
2. **Claim.** Set the task's status to `in_progress` in `index.md`. Commit only
   that file: `chore(tasks): start <slug> <ID>`.
3. **Read only what you need:** the task file, the plan section it came from
   (path in `index.md`), and the `## Summary` of each task it depends on.
   Do not read other task files, do not reload the whole plan or spec unless the
   task text is ambiguous without them.
4. **Implement.**
   - TDD when a test can express the acceptance: write the failing test, run it
     and confirm it fails for the expected reason, implement the minimum, run it
     and confirm it passes.
   - Otherwise run the verification commands from `## Acceptance` (or `Verify:`
     in `index.md`) and confirm they pass. Never mark done on your own judgment.
   - If the task is unclear or contradicts the code, STOP: add a checkpoint
     describing the question, leave status `in_progress`, report.
5. **Checkpoint.** After each meaningful step (test written, test red, green,
   refactor, verification), append one short line under `## Checkpoints`:
   `- <YYYY-MM-DD HH:MM> <what happened>`.
6. **Scope check (mandatory, before any status change or commit).** Stage exactly
   the files you intend to commit: modified tracked files plus new files you created
   on purpose. Never stage generated artifacts (caches, build output). Then run this
   check verbatim, replacing `TASK_FILE` and `TASK_DIR`; do not judge scope yourself,
   the output decides:

   ```sh
   TASK_FILE=docs/tasks/<slug>/<ID>-<name>.md TASK_DIR=docs/tasks/<slug> sh -fs <<'EOF'
   scope=$(sed -n '/^## Scope/,/^## /{/^## /d;/^[[:space:]]*$/d;p;}' "$TASK_FILE")
   git diff --cached --name-only | while read -r f; do
     ok=out; case $f in "$TASK_DIR"/*) ok=in;; esac
     for p in $scope; do case $f in $p) ok=in;; esac; done
     echo "$ok $f"
   done
   EOF
   ```

   Append a checkpoint `- <time> Scope check: <output, one line>`. Any `out` line:
   STOP, unstage nothing, leave the changes in place, leave status `in_progress`,
   report the `out` files. Do not revert, do not edit `## Scope`.
7. **Finish.** Write `## Summary`, set status `done` in `index.md`, then make ONE
   commit with the code changes and the task files, using the project's commit
   convention (conventional commits if none is stated).

## Reply

On success reply with the `## Summary` block only. On any STOP reply with
`STOPPED: <reason>` followed by the last checkpoint. No other narration.
