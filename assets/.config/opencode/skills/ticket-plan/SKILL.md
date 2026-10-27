---
name: ticket-plan
description: Use when turning a feature or an existing implementation plan into tracked tasks (e.g. "ticket-plan", "plan this as tickets", "split the plan into tasks"). Runs the writing-plans skill, pauses for plan review, then splits the plan into docs/tasks/<slug>/ with a splitter and a checker subagent.
compatibility: opencode
---

# Ticket Plan

Turn a plan into a task directory that `ticket-run` and `ticket-task` can execute.
The task file format is defined in the `ticket-task` skill: load it before step 5
and pass its Format section to the subagents. Do not invent another format.

Invocation: `ticket-plan [<plan-path>] [straight through]`.

## Steps

1. **Get the plan.**
   - Plan path given: use it.
   - Otherwise invoke the writing-plans skill under whichever name exists:
     `writing-plans`, `superpowers-writing-plans` or `superpowers:writing-plans`.
     Do not modify that skill or its output. When it finishes, note the saved plan
     path and decline its offer to execute the plan; continue at step 2.
   - None available: ask the user for a plan path. The plan must have one
     `### Task N: <title>` heading per task.
2. **Review pause.** Unless the user said "straight through", stop and ask the user
   to review the plan. Continue only after they confirm. Edits they make to the plan
   file are the plan.
3. **Slug and location.** Slug = plan file name without a leading `YYYY-MM-DD-`
   date and without extension. Task directory = `docs/tasks/<slug>/`, or
   `<path>/<slug>/` if the project's `AGENTS.md` has a line `Task dir: <path>`.
   Directory already exists: stop and ask.
4. **Verification commands.** Look for test, build and lint commands in `AGENTS.md`,
   `README*`, and CI config (`.github/workflows/*`, `.gitlab-ci.yml`, `Makefile`,
   `justfile`, `package.json` scripts, and similar). None found: ask the user once
   and suggest adding them to `AGENTS.md`. Never invent a command.
5. **Split.** Dispatch a fresh splitter subagent. Give it: the plan path, the task
   directory, the verification commands, the Format section from `ticket-task`, and
   these rules:
   - One task file `TNN-<kebab-title>.md` per `### Task N`, `NN` zero-padded.
   - `## Task`: the plan's task text copied verbatim, from its heading to the next
     `### Task` heading. Never reword, shorten or merge.
   - `## Acceptance`: the task's own test and verify steps; if it has none, the
     verification commands.
   - `## Scope`: the files listed in the task (its `Files:` block or equivalent),
     one per line, plus their test files.
   - `Depends on`: tasks whose output this task consumes (its `Interfaces` /
     `Consumes` block or explicit references); otherwise `-`.
   - `Review point`: `yes` if the task text contains `REVIEW POINT`, else `no`.
   - Status `open` for every task. `index.md` header lists spec (if the plan names
     one), plan path and verification commands.
   - A task too large for one agent to finish and commit in one pass: write nothing
     for it, return the reason. Do not cut it up.
6. **Check.** Dispatch a separate fresh checker subagent with the plan path and the
   task directory. It reports, without editing:
   - every `### Task N` has exactly one task file and one `index.md` row;
   - each `## Task` section is identical to the plan text;
   - `## Acceptance` and `## Scope` are non-empty;
   - statuses are valid, every `Depends on` ID exists, no dependency cycle,
     no task depends on a later task in plan order.
   Any finding, or a splitter "too large" report: show the user and stop.
   Do not commit.
7. **Commit.** Default branch = `git symbolic-ref --short refs/remotes/origin/HEAD`
   without the `origin/` prefix; no remote: `main` if it exists, else `master`.
   If staged changes exist outside the task directory, stop and ask. If on the
   default branch, `git switch -c feat/<slug>` first. Commit
   only the task directory: `chore(tasks): add <slug> tasks` (follow the project's
   commit convention if it differs).
8. **Hand off.** Tell the user the task directory path, that they can edit
   `index.md` (for example set `Review point` to `yes`), and that the next step is
   `ticket-run <slug>`, or `ticket-task <slug> <ID>` in a fresh session per task.
