---
name: ticket-task
description: Use when implementing exactly one task of a feature tracked in the tickets repo, by slug and ID (e.g. "ticket-task my-feature T03"), in a fresh session or as a subagent of ticket-run. Also the reference for the tickets repo location and the task file format used by ticket-plan and ticket-run.
compatibility: opencode
---

# Ticket Task

Implement ONE task. Stay inside that task. The files in the feature folder are the
only memory: what is not written there does not exist for the next agent.

Invocation: `ticket-task <slug> <ID>`, run from the project repo.

## Locations (canonical)

- **Project repo:** the current git repo. Code, tests and ADRs live here.
- **Tickets repo:** default `eana/agent-tickets`. A line
  `Tickets repo: <org/repo | absolute path>` in the project's `AGENTS.md` overrides
  it. Resolve an `org/repo` with the `ghq-lookup` skill (find, clone if missing).
  Not found or not clonable: STOP. Never create repositories.
- **Sync before writing:** in the tickets repo, on `master`, run
  `git pull --ff-only` (skip if it has no upstream). Failure (divergence): STOP and
  report. Never merge, rebase or push; the user pushes.
- **Feature folder:** `<tickets repo>/<host>/<owner>/<repo>/<YYYY-MM-DD>-<slug>/`.
  `<host>/<owner>/<repo>` comes from the project's `git remote get-url origin`
  (`git@github.com:o/r.git` and `https://github.com/o/r` both give
  `github.com/o/r`); no origin: `local/<project dir name>`. Find an existing
  feature by globbing `*-<slug>/` in that directory.
- **Commits:** every commit, in either repo, goes through the `git-commit` skill.
  The user has authorized committing directly on `master` of the tickets repo; that
  is the permission the git-commit skill asks for, for this repo only. Tickets
  commits stage only the feature folder.

## Format (canonical)

Feature folder contents: `index.md`, `plan.md`, `spec.md` (optional), `TNN-*.md`,
`R01-review-fixes.md` (optional), `review.md` (optional), `pr.md` (at the end).

`index.md`:

```markdown
# <Feature title>

- Project: <host>/<owner>/<repo>, branch `feat/<slug>`
- Spec: spec.md | -
- Plan: plan.md
- ADR: <project-relative path> | -
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

Task file `TNN-<kebab-name>.md` (or `R01-review-fixes.md`), sections in order:

```markdown
# TNN: <Title>

## Task
<plan text for this task, verbatim>

## Acceptance
<tests that must fail first and then pass, or exact verification commands>

## Scope
<one project-relative path or glob per line: the only project files this task may
change. `*` also matches `/`, so `src/*` covers the whole subtree. No spaces in paths.>

## Checkpoints

## Summary
```

Summary, when done:

```markdown
## Summary
- Why: <one or two lines>
- What: <what changed>
- Files touched: <project files>
- Verification: <command> -> <result>
- Project commit: <full sha>
```

## Procedure

1. **Preconditions.** Resolve and sync the tickets repo, locate the feature folder,
   read `index.md`. In the project repo run
   `git status --porcelain --untracked-files=no`; in the tickets repo run
   `git status --porcelain -- <feature folder>`.
   - The requested task is `in_progress` and no other task is: RESUME. Uncommitted
     changes are allowed (they are this task's). Skip step 2. If its `## Summary`
     has a `Project commit` that exists (`git cat-file -e <sha>`), the code is
     committed: go straight to the tickets commit in step 7. Otherwise continue
     from the last checkpoint.
   - Otherwise, any uncommitted change in either place, or any task `in_progress`:
     STOP and report. Do not clean, stash or reset anything.
   - Task not ready (status not `open`, or a dependency not `done`): STOP and report.
   - Project repo is not on the branch named in `index.md`: STOP and report.
2. **Claim.** Set the task's status to `in_progress` in `index.md`. Commit only
   that file in the tickets repo, subject `chore(tasks): start <slug> <ID>`.
3. **Read only what you need:** the task file, the matching section of `plan.md`,
   and the `## Summary` of each task it depends on. Do not read other task files,
   do not reload the whole plan or spec unless the task text is ambiguous without them.
4. **Implement** in the project repo.
   - TDD when a test can express the acceptance: write the failing test, run it
     and confirm it fails for the expected reason, implement the minimum, run it
     and confirm it passes.
   - Otherwise run the verification commands from `## Acceptance` (or `Verify:`
     in `index.md`) and confirm they pass. Never mark done on your own judgment.
   - If the task is unclear or contradicts the code, STOP: add a checkpoint
     describing the question, leave status `in_progress`, report.
5. **Checkpoint.** After each meaningful step (test written, test red, green,
   refactor, verification), append one short line under `## Checkpoints`:
   `- <YYYY-MM-DD HH:MM> <what happened>`. Checkpoints are committed with the task
   at the end, or with the STOP.
6. **Scope check (mandatory, before the project commit).** In the project repo,
   stage exactly the files you intend to commit: modified tracked files plus new
   files you created on purpose. Never stage generated artifacts (caches, build
   output). Then run this check verbatim from the project root, with the real task
   file path; do not judge scope yourself, the output decides:

   ```sh
   TASK_FILE=<absolute path to the task file> sh -fs <<'EOF'
   scope=$(sed -n '/^## Scope/,/^## /{/^## /d;/^[[:space:]]*$/d;p;}' "$TASK_FILE")
   { git diff HEAD --name-only; git diff --cached --name-only; } | sort -u |
   while read -r f; do
     ok=out
     for p in $scope; do case $f in $p) ok=in;; esac; done
     echo "$ok $f"
   done
   EOF
   ```

   Append a checkpoint `- <time> Scope check: <output, one line>`. Any `out` line:
   STOP, leave the changes in place, leave status `in_progress`, commit the task
   file (checkpoints) in the tickets repo, report the `out` files. Do not revert,
   do not edit `## Scope`.
7. **Finish.**
   - Project repo: one commit with the staged code. The message describes what the
     change does (for `R01`: what was fixed), never the process ("address review
     comments", "implement task T03" are wrong).
   - Write `## Summary` including `Project commit: <sha>`, set status `done` in
     `index.md`, commit the feature folder in the tickets repo, subject
     `chore(tasks): done <slug> <ID>`.
   - Afterwards both clean-tree checks from step 1 must be empty; if not, STOP.

## Recovering from a STOP

The task stays `in_progress` with its changes in place. The user (or an agent they
ask) does one of:
- Fix the cause (answer the question, extend `## Scope`, fix the code), then rerun
  `ticket-task <slug> <ID>`: it resumes.
- Drop the attempt: revert the task's project changes, set status `open`, commit
  the tickets repo with `chore(tasks): reset <slug> <ID>`, rerun.
- Park it: revert the project changes, set status `blocked`, add a checkpoint with
  the reason, commit the tickets repo. `ticket-run` reports blocked tasks.

## Reply

On success reply with the `## Summary` block only. On any STOP reply with
`STOPPED: <reason>` followed by the last checkpoint and the line
`Recover: see "Recovering from a STOP" in the ticket-task skill.` No other narration.
