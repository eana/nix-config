---
name: ticket-plan
description: Use when turning a feature or an existing implementation plan into tracked tasks (e.g. "ticket-plan", "plan this as tickets", "split the plan into tasks"). Runs the writing-plans skill, pauses for plan review, then splits the plan into a feature folder in the tickets repo with a splitter and a checker subagent.
compatibility: opencode
---

# Ticket Plan

Turn a plan into a feature folder that `ticket-run` and `ticket-task` can execute.

Invocation: `ticket-plan [<plan-path>] [straight through]`, run from the project repo.

## Steps

Do every step in order. Do not skip or merge steps.

0. **Load skills now:** call the skill tool for `ticket-task` and for `git-commit`
   before anything else. `ticket-task` defines the tickets repo, the folder layout
   and the file format (sections Locations and Format); they are binding. Every
   commit below goes through `git-commit`.
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
4. **Project branch (before any project write).** Default branch =
   `git symbolic-ref --short refs/remotes/origin/HEAD` without the `origin/` prefix;
   if that fails, `main` if it exists, else `master`. If staged changes exist in the
   project repo, stop and ask. If the current branch is the default branch, run
   `git switch -c feat/<slug>` (slug from step 5).
5. **Locations.** Slug = plan file name without a leading `YYYY-MM-DD-` date and
   without extension. Resolve and sync the tickets repo (`ticket-task`, Locations).
   Compute the project path by running, in the project repo, exactly:

   ```sh
   sh -c 'u=$(git remote get-url origin 2>/dev/null) && [ -n "$u" ] &&
     printf "%s\n" "$u" | sed -E "s#^[a-z+]+://##; s#^[^@/]*@##; s#^([^/:]+):#\1/#; s#\.git\$##" ||
     echo "local/$(basename "$(git rev-parse --show-toplevel)")"'
   ```

   Feature folder = `<tickets repo>/<output>/<today YYYY-MM-DD>-<slug>/`. The output
   always has at least two path segments; a folder directly under the tickets repo
   root is wrong. A folder `*-<slug>/` already exists in `<tickets repo>/<output>/`:
   stop and ask.
6. **Verification commands.** Look for test, build and lint commands in the
   project's `AGENTS.md`, `README*`, and CI config (`.github/workflows/*`,
   `.gitlab-ci.yml`, `Makefile`, `justfile`, `package.json` scripts, and similar).
   None found: ask the user once and suggest adding them to `AGENTS.md`. Never
   invent a command.
7. **Copy plan and spec.** Copy the plan to `<feature folder>/plan.md`. If the plan
   names a spec/design file, copy it to `spec.md`.
8. **Split.** Dispatch a fresh splitter subagent (agent `ticket-planner` if it
   exists, otherwise the default subagent) with this instruction: "Load the
   ticket-task skill and follow its Format section exactly. Split `<feature
   folder>/plan.md` into that folder. Project: `<project path>`, branch
   `feat/<slug>`. Verification commands: `<commands>`." plus these rules:
   - One task file `TNN-<kebab-title>.md` per `### Task N`, numbered from `T01`.
   - `## Task`: the plan's task text copied verbatim, from its heading to the next
     `### Task` heading. Never reword, shorten or merge.
   - `## Acceptance`: the task's own test and verify steps; if it has none, the
     verification commands. When no behavioral test applies (docs, config, skill
     text), start `## Acceptance` with one line naming why, then the commands.
   - `## Scope`: the project files listed in the task (its `Files:` block or
     equivalent), one per line, plus their test files.
   - `Depends on`: tasks whose output this task consumes (its `Interfaces` /
     `Consumes` block or explicit references); otherwise `-`.
   - `Review point`: `yes` if the task text contains `REVIEW POINT`, else `no`.
   - `Complexity`: `low` or `high` per the Format's rule; when unsure, `high`.
   - Status `open` for every task. `index.md` header and table exactly as in the
     Format, with `Spec: spec.md` (or `-`), `Plan: plan.md`, `ADR: -`.
   - A task too large for one agent to finish and commit in one pass: write nothing
     for it, return the reason. Do not cut it up.
9. **Check.** Dispatch a separate fresh checker subagent (agent `ticket-planner`
   if it exists): "Load the ticket-task
   skill. Compare `<feature folder>` against its `plan.md` and report, without
   editing:" 
   - every `### Task N` has exactly one task file and one `index.md` row, IDs
     `T01`, `T02`, ... in plan order;
   - `index.md` header lines and table columns match the Format exactly;
   - each task file has the Format's sections in order; `## Task` is identical to
     the plan text; `## Acceptance` and `## Scope` are non-empty;
   - statuses and complexities are valid, every `Depends on` ID exists, no dependency cycle,
     no task depends on a later task in plan order;
   - every task whose `## Scope` has more than 3 lines is `high`.
   Any finding, or a splitter "too large" report: show the user and stop.
   Do not commit.
10. **ADR (only when there is a real decision).** Trigger, decided mechanically:
    `spec.md` exists and has a heading containing `Approach`, `Option`,
    `Alternative` or `Decision` under which two or more alternatives are listed.
    Trigger met: write an ADR in the project repo on `feat/<slug>`. Use the
    project's existing ADR folder and format if it has one; otherwise
    `docs/adr/NNNN-<kebab-title>.md` (next free number, `0001` if none) with
    sections `## Context`, `## Decision`, `## Consequences`, taken from the spec.
    Commit it, and set `ADR: <path>` in `index.md`. Trigger not met: no ADR, keep
    `ADR: -`.
11. **Commit the feature folder** in the tickets repo, staging only that folder,
    subject `chore(tasks): add <slug>`.
12. **Hand off.** Tell the user the feature folder path, the project branch, that
    they can edit `index.md` there (for example set `Review point` to `yes`), and
    that the next step is `ticket-run <slug>`, or `ticket-task <slug> <ID>` in a
    fresh session per task. Remind them that nothing was pushed.
