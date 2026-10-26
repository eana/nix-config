---
name: ticket-run
description: Use when running the remaining tasks of a feature tracked in docs/tasks/<slug>/ (e.g. "ticket-run my-feature", "run the tasks", "continue the feature"). Coordinates one fresh subagent per task and stops on failures, unclear tasks, scope violations and review points.
compatibility: opencode
---

# Ticket Run

You are the coordinator. You keep your context small: you read `index.md` and task
summaries, nothing else. You never read code, diffs or test output. Each task runs
in a fresh subagent that loads the `ticket-task` skill. The task file format is
defined in the `ticket-task` skill; load it if you need the details.

Invocation: `ticket-run [<slug>]`.

## Start

1. Task directory root is `docs/tasks/` unless the project's `AGENTS.md` has a line
   `Task dir: <path>`.
2. No slug given: list task directories whose `index.md` has any task not `done`.
   Exactly one: use it. Otherwise ask the user which one.
3. Run `git status --porcelain --untracked-files=no`. Non-empty output, or any task
   `in_progress`:
   STOP and report what you found (the last checkpoint of the `in_progress` task
   explains why it stopped). Do not clean, stash or reset anything.

## Loop

1. Re-read `index.md`. Pick the first ready task in table order
   (ready = `open` and every `Depends on` ID is `done`).
2. No ready task: if all tasks are `done`, go to Finish. Otherwise STOP and report
   which tasks are left and what blocks them.
3. Ready task has `Review point` = `yes` and it is not the first task you run in this
   session after the user started you: STOP before it and report. The user restarts
   `ticket-run` to continue past it.
4. Dispatch ONE fresh subagent with exactly this prompt and nothing else:
   `Load the ticket-task skill and run: ticket-task <slug> <ID>`
5. When it returns, re-read `index.md`.
   - Task is `done`: read only its `## Summary`, note the one-line Why, continue the
     loop.
   - Anything else (reply starts with `STOPPED:`, status not `done`): STOP and relay
     the subagent's reason and last checkpoint to the user.

Run tasks one at a time. Never dispatch in parallel, never implement a task
yourself, never edit task files except to read them.

## Finish

Report: feature title, each task ID with its one-line Why, and the commit range
(`git log --oneline` limited to this feature's commits).
