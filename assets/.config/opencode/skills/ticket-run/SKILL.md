---
name: ticket-run
description: Use when running the remaining tasks of a feature tracked in the tickets repo (e.g. "ticket-run my-feature", "run the tasks", "continue the feature"). Coordinates one fresh subagent per task, stops on failures, unclear tasks, scope violations and review points, then runs one code review round and presents a PR description.
compatibility: opencode
---

# Ticket Run

You are the coordinator. You keep your context small: you read `index.md`, task
summaries, last checkpoint lines and verdict lines, nothing else. You never read
code or diffs. The only commands you run yourself are the feature's `Verify:`
commands, and you read only their exit status. Every task runs in a fresh
subagent that loads the `ticket-task` skill. Locations and format are defined in
the `ticket-task` skill; load it first.

Human-facing overview and diagram: `../ticket-task/references/workflow.md`.

Invocation: `ticket-run [<slug>]`, run from the project repo.

## Start

0. Load skills now: call the skill tool for `ticket-task` and `git-commit` before
   anything else.
1. Resolve and sync the tickets repo; compute the project's directory in it
   (`ticket-task`, Locations, using its path snippet verbatim).
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
2. No ready task: if all tasks are `done`, go to Review. Otherwise STOP and report
   which tasks are left and what blocks them.
3. Ready task has `Review point` = `yes` and it is not the first task you run in this
   session: STOP before it and report. The user restarts `ticket-run` to continue.
4. Dispatch ONE fresh subagent with exactly this prompt and nothing else:
   `Load the ticket-task skill and run: ticket-task <slug> <ID>`
   Agent: `Complexity` = `low` -> `ticket-builder-light`; `high` (and `R01`) ->
   `ticket-builder`. If the named agent does not exist, use the default subagent.
5. When it returns, re-read `index.md`.
   - Task is `done`: read only its `## Summary`. It must hold a `Project commit:`
     line whose SHA exists (`git cat-file -e <sha>`) and a `Verification:` line
     naming the command that was run and its real result. A missing line, or a SHA
     that does not exist: STOP and report; never start the next task on it.
     Otherwise note the one-line Why and continue.
   - It STOPPED, ran on `ticket-builder-light`, and the reason is a failing test or
     verification (not unclear task, not scope): dispatch the same prompt ONCE to
     `ticket-builder`; it resumes the task. Then apply this step again without
     another retry.
   - Anything else (reply starts with `STOPPED:`, status not `done`): STOP and relay
     the reason, the task's last checkpoint line and the `Recover:` line.

Run tasks one at a time. Never dispatch in parallel, never implement a task
yourself, never edit task files except `index.md` rows and the verify lines in
`review.md` as described here.

## Review (mandatory, once per feature)

If `review.md` already exists in the feature folder, the review was done: run `R01`
if it exists and is not `done`, then run step 4 unless `review.md` already holds a
`Post-review verify:` line, in which case skip straight to Finish. Otherwise do all
steps below.

1. **Request.** Dispatch a fresh reviewer subagent (agent `ticket-planner` if it
   exists): "Load the requesting-code-review
   skill (or superpowers-requesting-code-review). Review the project repo range
   `<merge-base of feat/<slug> and the default branch>..HEAD` against
   `<feature folder>/spec.md` and `plan.md`. Write all findings, each with an ID,
   severity, file:line, problem and suggested fix, to `<feature folder>/review.md`.
   Do not edit project files. Do not commit."
2. **Receive.** Dispatch a separate fresh grading subagent (agent `ticket-planner`
   if it exists): "Load the
   receiving-code-review skill (or superpowers-receiving-code-review) and the
   ticket-task skill. Read `<feature folder>/review.md`, verify each finding against
   the project code, and append under each exactly one of
   `Verdict: accept - <reason>`, `Verdict: reject - <reason>` or
   `Verdict: minor - <reason>`. `accept` means fix it now, in `R01`; `minor` means
   accepted but not worth fixing now and never part of `R01`; `reject` needs a
   concrete reason. If any finding is `accept`, write
   `<feature folder>/R01-review-fixes.md` in the ticket-task format: `## Task` lists
   every accepted finding, `## Acceptance` one failing-then-passing test (or exact
   verification) per finding, `## Scope` the union of affected files; append row
   `| R01 | review fixes | open | <all task IDs> | no | high |` to `index.md`. Do not edit
   project files. Commit the feature folder in the tickets repo via the git-commit
   skill, subject `chore(tasks): review <slug>`."
3. Read only the `Verdict:` lines. `R01` added: run it through the Loop (it is
   exempt from the review-point rule). It fails: STOP as in the Loop.
   One review round only; never review again after `R01`.
4. **Verify the integrated tree.** Skip this step if `review.md` already holds a
   `Post-review verify:` line; go straight to Finish. Otherwise run the `Verify:`
   commands from `index.md` on the project branch HEAD. Non-zero exit, or a command
   that cannot run: STOP and report. Otherwise append one
   `Post-review verify: <command> -> <result>` line per command to `review.md` and
   commit the feature folder via the git-commit skill, subject
   `chore(tasks): verify <slug>`.

## Finish

Precondition: every task is `done` with a `Project commit` that exists and a
`Verification:` line, and `review.md` is committed and holds a
`Post-review verify:` line. If not, go back to the Loop or Review. Never write
`pr.md` without that evidence.

1. Write `<feature folder>/pr.md` from `index.md`, the task summaries and the
   verdict lines:

   ```markdown
   Title: <PR title>

   Description:

   ## Why
   ## What
   ## How
   ## Decision record
   <ADR path, or omit the section when ADR is ->
   ## Open minor findings
   <one line each, or omit the section>
   ```

   The title is one line, at most 72 characters, in the project's commit style.

   Copy every `Verdict: minor - <reason>` from `review.md` as one bullet under
   `## Open minor findings`. Before committing, compare the two: any minor verdict
   missing from the section, or any bullet without a matching verdict, is STOP.

   Describe the change itself: Why = the problem it solves, What = behavior
   added or changed, How = the technical approach in the code. Never link to or
   mention the tickets repo, and never mention reviews, tasks, TDD, commits per
   task or agents. Then run
   `grep -inwE 'tasks?|tdd|test-driven|reviews?|reviewer|agents?|tickets?|T[0-9]{2}|R01' pr.md`
   (the heading `Open minor findings` is fine): any match, rewrite those lines and
   run it again until there is none.
2. Commit `pr.md` in the tickets repo via the git-commit skill, subject
   `chore(tasks): pr description <slug>`.
3. Show the `pr.md` content to the user, plus the project commit range
   `<merge-base>..feat/<slug>`. Do not create a PR, do not merge, do not push: the
   user decides.
