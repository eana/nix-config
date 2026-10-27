---
name: ticket-plan
description: Use when turning a feature or an existing implementation plan into tracked tasks (e.g. "ticket-plan", "plan this as tickets", "split the plan into tasks"). Runs the writing-plans skill, pauses for plan review, then splits the plan into a feature folder in the tickets repo with a splitter and a checker subagent.
compatibility: opencode
---

# Ticket Plan

Turn a plan into a feature folder that `ticket-run` and `ticket-task` can execute.
Load the `ticket-task` skill first: its Locations and Format sections are canonical.
Do not invent another location or format.

Invocation: `ticket-plan [<plan-path>] [straight through]`, run from the project repo.

## Steps

1. **Get the plan.**
   - Plan path given: use it.
   - Otherwise invoke the writing-plans skill under whichever name exists:
     `writing-plans`, `superpowers-writing-plans` or `superpowers:writing-plans`.
     Do not modify that skill or its output. When it finishes, note the saved plan
     path (wherever it was saved) and decline its offer to execute the plan;
     continue at step 2.
   - None available: ask the user for a plan path. The plan must have one
     `### Task N: <title>` heading per task.
2. **Review pause.** Unless the user said "straight through", stop and ask the user
   to review the plan. Continue only after they confirm. Edits they make to the plan
   file are the plan.
3. **Write access.** The next steps write files and commit. If your harness
   currently forbids that (for example a plan or read-only mode), STOP and ask the
   user to switch to a mode that allows edits, then continue here.
4. **Locations.** Slug = plan file name without a leading `YYYY-MM-DD-` date and
   without extension. Resolve and sync the tickets repo and compute the feature
   folder as described in `ticket-task` (Locations), using today's date. A folder
   `*-<slug>/` already exists there: stop and ask.
5. **Verification commands.** Look for test, build and lint commands in the
   project's `AGENTS.md`, `README*`, and CI config (`.github/workflows/*`,
   `.gitlab-ci.yml`, `Makefile`, `justfile`, `package.json` scripts, and similar).
   None found: ask the user once and suggest adding them to `AGENTS.md`. Never
   invent a command.
6. **Copy plan and spec.** Copy the plan to `<feature folder>/plan.md`. If the plan
   names a spec/design file, copy it to `spec.md`. The copies are what agents read
   from now on.
7. **Split.** Dispatch a fresh splitter subagent. Give it: the `plan.md` path, the
   feature folder, the verification commands, the `ticket-task` Format section, and
   these rules:
   - One task file `TNN-<kebab-title>.md` per `### Task N`, `NN` zero-padded.
   - `## Task`: the plan's task text copied verbatim, from its heading to the next
     `### Task` heading. Never reword, shorten or merge.
   - `## Acceptance`: the task's own test and verify steps; if it has none, the
     verification commands.
   - `## Scope`: the project files listed in the task (its `Files:` block or
     equivalent), one per line, plus their test files.
   - `Depends on`: tasks whose output this task consumes (its `Interfaces` /
     `Consumes` block or explicit references); otherwise `-`.
   - `Review point`: `yes` if the task text contains `REVIEW POINT`, else `no`.
   - Status `open` for every task. `index.md` header per the Format.
   - A task too large for one agent to finish and commit in one pass: write nothing
     for it, return the reason. Do not cut it up.
8. **Check.** Dispatch a separate fresh checker subagent with `plan.md` and the
   feature folder. It reports, without editing:
   - every `### Task N` has exactly one task file and one `index.md` row;
   - each `## Task` section is identical to the plan text;
   - `## Acceptance` and `## Scope` are non-empty;
   - statuses are valid, every `Depends on` ID exists, no dependency cycle,
     no task depends on a later task in plan order.
   Any finding, or a splitter "too large" report: show the user and stop.
   Do not commit.
9. **Project branch.** Default branch = `git symbolic-ref --short
   refs/remotes/origin/HEAD` without the `origin/` prefix; no remote: `main` if it
   exists, else `master`. If staged changes exist in the project repo, stop and ask.
   If on the default branch, `git switch -c feat/<slug>`.
10. **ADR (only when there is a real decision).** If the spec contains a real choice
    between alternatives (an approaches/options section with a pick and reasons),
    write an ADR in the project repo. Use the project's existing ADR folder and
    format if it has one; otherwise `docs/adr/NNNN-<kebab-title>.md` (next free
    number, `0001` if none) with sections `## Context`, `## Decision`,
    `## Consequences`, taken from the spec. Commit it on `feat/<slug>` and set
    `ADR:` in `index.md`. No real choice, or no spec: no ADR, `ADR: -`.
11. **Commit the feature folder** in the tickets repo, subject
    `chore(tasks): add <slug>`.
12. **Hand off.** Tell the user the feature folder path, that they can edit
    `index.md` there (for example set `Review point` to `yes`), and that the next
    step is `ticket-run <slug>`, or `ticket-task <slug> <ID>` in a fresh session per
    task. Remind them that nothing was pushed.
