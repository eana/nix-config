---
name: ticket-run
description: Use when running the remaining tasks of a feature tracked in the tickets repo (e.g. "ticket-run my-feature", "run the tasks", "continue the feature"). Coordinates one fresh subagent per task, stops on failures, unclear tasks, scope violations and review points, then runs one code review round and presents a PR description.
compatibility: opencode
---

# Ticket Run

You are the coordinator. You keep your context small: you read `index.md`, task
summaries, last checkpoint lines and verdict lines, nothing else. You never read
code, diffs or test output. Every task runs in a fresh subagent that loads the
`ticket-task` skill. Locations and format are defined in the `ticket-task` skill;
load it first.

Invocation: `ticket-run [<slug>]`, run from the project repo.

## Start

1. Resolve and sync the tickets repo; compute the project's directory in it
   (`ticket-task`, Locations).
2. No slug given: list feature folders there whose `index.md` has any task not
   `done`, or that have no `pr.md`. Exactly one: use it. Otherwise ask the user.
3. Check both repos are clean (`ticket-task`, Procedure step 1) and read `index.md`.
   - Exactly one task `in_progress`: it stopped earlier and the user restarted you
     after dealing with it. Dispatch it first (loop step 4); `ticket-task` resumes it.
   - More than one `in_progress`, or uncommitted changes with none `in_progress`:
     STOP and report what you found. Do not clean, stash or reset anything.

## Loop

1. Re-read `index.md`. Pick the first ready task in table order
   (ready = `open` and every `Depends on` ID is `done`).
2. No ready task: if all tasks are `done`, go to Review (or to Finish if `R01`
   exists and is `done`). Otherwise STOP and report which tasks are left and what
   blocks them.
3. Ready task has `Review point` = `yes` and it is not the first task you run in this
   session: STOP before it and report. The user restarts `ticket-run` to continue.
4. Dispatch ONE fresh subagent with exactly this prompt and nothing else:
   `Load the ticket-task skill and run: ticket-task <slug> <ID>`
5. When it returns, re-read `index.md`.
   - Task is `done`: read only its `## Summary`, note the one-line Why, continue.
   - Anything else (reply starts with `STOPPED:`, status not `done`): STOP and relay
     the reason, the task's last checkpoint line and the `Recover:` line.

Run tasks one at a time. Never dispatch in parallel, never implement a task
yourself, never edit task files except `index.md` rows as described here.

## Review (once per feature, skip if `review.md` exists)

1. **Request.** Dispatch a fresh reviewer subagent: "Load the requesting-code-review
   skill (or superpowers-requesting-code-review). Review the project repo range
   `<merge-base of feat/<slug> and the default branch>..HEAD` against
   `<feature folder>/spec.md` and `plan.md`. Write all findings, each with an ID,
   severity, file:line, problem and suggested fix, to `<feature folder>/review.md`.
   Do not edit project files. Do not commit."
2. **Receive.** Dispatch a separate fresh grading subagent: "Load the
   receiving-code-review skill (or superpowers-receiving-code-review) and the
   ticket-task skill. Read `<feature folder>/review.md`, verify each finding against
   the project code, and append under each a line
   `Verdict: accept | reject - <reason> | minor`. If any finding is accepted, write
   `<feature folder>/R01-review-fixes.md` in the ticket-task format: `## Task` lists
   every accepted finding, `## Acceptance` one failing-then-passing test (or exact
   verification) per finding, `## Scope` the union of affected files; append row
   `| R01 | review fixes | open | <all task IDs> | no |` to `index.md`. Do not edit
   project files. Commit the feature folder in the tickets repo via the git-commit
   skill, subject `chore(tasks): review <slug>`."
3. Read only the `Verdict:` lines. `R01` added: run it through the Loop (it is
   exempt from the review-point rule). It fails: STOP as in the Loop.
   One review round only; never review again after `R01`.

## Finish

1. Write `<feature folder>/pr.md` from `index.md`, the task summaries and the
   verdict lines:

   ```markdown
   # <Feature title>

   ## Why
   ## What
   ## How
   ## Decision record
   <ADR path, or omit the section when ADR is ->
   ## Open minor findings
   <one line each, or omit the section>
   ```

   Describe the change itself. Never link to or mention the tickets repo, and never
   mention reviews, tasks or agents.
2. Commit `pr.md` in the tickets repo via the git-commit skill, subject
   `chore(tasks): pr description <slug>`.
3. Show the `pr.md` content to the user, plus the project commit range. Do not
   create a PR, do not merge, do not push: the user decides.
