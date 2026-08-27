---
name: git-commit
description: Use when writing commit messages, staging changes for commit, or rebasing - enforces conventional commits format, branch protection, staging hygiene, and atomic commits
---

## Branching rules

- **Check current branch:** Always determine the current branch (`git branch --show-current`) before writing or executing a commit.
- **Protect main/master:** If the current branch is `main` or `master`, halt and explicitly ask the user for permission before proceeding.
- **Prefer feature branches:** When asked to commit on `main` or `master`, actively suggest creating a new feature branch (`git checkout -b <type>/<brief-description>`).

## Conform file

At the start of any commit workflow, check for `.conform.yml` or `.conform.yaml` in the repo root. If found, read it and extract the allowed types and scopes defined there — those replace the hardcoded defaults below. Obey whatever the conform file specifies; it is the source of truth for this repo.

## Commit message structure

```
<type>(<optional scope>): <description>

[optional body]

[optional footer]
```

## Types

Default (used when no `.conform.yml` is present):

`build`, `chore`, `ci`, `docs`, `feat`, `fix`, `perf`, `refactor`, `style`, `test`

## Subject line rules

- Type and description are required; scope is optional
- Description must immediately follow the type/scope prefix
- Write in imperative mood: `add`, `fix`, `update`, `remove`, `rename`
- Limit to 60 characters
- Lowercase the entire subject line
- Do not end with punctuation
- ASCII only: no emojis, no non-ASCII characters whatsoever

## Scope rules

- Use the name of the most directly affected component: module name, host name, or directory
- Use `deps` for dependency or flake input updates
- Use `flake` for structural changes to `flake.nix`
- Omit scope when a change is genuinely cross-cutting (touches three or more unrelated areas)
- If `.conform.yml` defines allowed scopes, use only those

## Body rules

- Leave one blank line between subject and body
- Use bullet points starting with `- `
- Capitalise the first letter of each bullet point
- Write each bullet in imperative mood
- Keep bullet points short and clear
- ASCII only: no emojis, no non-ASCII characters whatsoever
- Omit the body entirely if it adds no useful detail beyond the subject

## Breaking changes

- Append `!` to the type/scope: `feat!:` or `feat(scope)!:`
- Add a `BREAKING CHANGE: <description>` footer separated from the body by a blank line
- The footer must describe what breaks and how to migrate

## Atomicity

- Each commit must represent one logical change
- If unrelated changes are present in the working tree, split them into separate commits before staging

## Staging hygiene

Before writing the commit message:
1. Stage only files that were explicitly changed during the session; never stage unrelated pre-existing modifications
2. Avoid `git add .` or `git add -A` unless every change in the working tree is intentional and part of this commit
3. Run `git diff --staged` and confirm the staged diff matches the intended change before proceeding

## Pre-commit hooks

Pre-commit hooks exist for a reason — always run them before committing. Never bypass with `--no-verify`.

1. If `pre-commit` is available, run `pre-commit run` against the staged files before committing
2. If hooks fail, fix the issues, re-stage, and re-run before proceeding
3. In Nix repos (presence of `flake.nix`), ensure hooks are up to date before running them:
   - Run `nix run .#pre-commit-install` to regenerate hooks, or enter the dev shell (`nix develop`) which installs them via `shellHook`

## Signing commits

Always sign commits with `-S`. This applies to every `git commit` and `git commit --amend` invocation. If signing fails because the key is locked, unlock the key and retry — do not fall back to unsigned.

## Amending commits

`git commit --amend` follows all the same rules as a new commit: conventional format, ASCII only, imperative mood, signed (`-S`), pre-commit hooks passing.

## Rebase rules

Rebase can invoke `$EDITOR` for commit messages and the todo list, which may open vim/nvim and block. Prevent this by setting both editor env vars to `true` (the Unix no-op binary) for every rebase command:

```bash
GIT_EDITOR=true GIT_SEQUENCE_EDITOR=true git rebase --committer-date-is-author-date <target>
```

Always pass `--committer-date-is-author-date` to preserve original author timestamps.

### Pre-commit hooks during rebase

Run pre-commit hooks after each replayed commit using `--exec`. Only check files changed by that specific commit — not the entire tree — so pre-existing issues in unrelated files don't block the rebase:

```bash
GIT_EDITOR=true GIT_SEQUENCE_EDITOR=true git rebase --committer-date-is-author-date \
  --exec 'files=$(git diff-tree --no-commit-id -r --name-only HEAD | tr "\n" " "); [ -z "$files" ] || pre-commit run --files $files' \
  <target>
```

The guard `[ -z "$files" ]` skips hook execution when a commit touches no files (e.g., empty or merge commits).

If hooks fail mid-rebase, fix the issues, re-stage, then run `git rebase --continue`.

### Nix repos and hook regeneration

In repos with `flake.nix`, regenerate pre-commit hooks before starting the rebase:

```bash
nix run .#pre-commit-install
# or: nix develop (hooks install via shellHook)
```

Then proceed with the rebase command above.

## Examples

```
feat(opencode): add declarative skills support
fix(zsh): correct PATH ordering for homebrew on darwin
chore(deps): update flake inputs
refactor(nixvim): extract keymap definitions into separate file
```

```
feat(opencode): add declarative skills support

- Add skills.enable toggle for built-in skills bundled with the config
- Add skills.extraSkillsDirs for external skill directories
- Keep skill source in assets/.config/opencode/skills/<name>/SKILL.md and wire it through modules/common/opencode/default.nix
- Use last-writer-wins on name collision to allow overrides
```

```
feat(api)!: remove legacy configuration format

- Drop support for the v1 config schema
- Require migration to the v2 format before upgrading

BREAKING CHANGE: v1 config files are no longer read; run
`migrate-config` to convert them to v2 format before upgrading.
```
