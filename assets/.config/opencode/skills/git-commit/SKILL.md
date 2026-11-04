---
name: git-commit
description: Use when writing commit messages, staging changes, or rebasing in a Git repository - enforcing conventional commits format, branch protection, staging hygiene, and atomic commits.
compatibility: opencode
---

## Branching rules

- **Check current branch:** Always determine the current branch (`git branch --show-current`) before writing or executing a commit.
- **Protect main/master:** If the current branch is `main` or `master`, halt and explicitly ask the user for permission before proceeding.
- **Prefer feature branches:** When asked to commit on `main` or `master`, actively suggest creating a new feature branch (`git checkout -b <type>/<brief-description>`).

## Non-interactive git

Every git command must run without opening an editor, prompt, or interactive UI - you must be able to complete the operation unattended. This applies to all git operations, not only rebase.

Prefer explicit non-interactive flags first, and use a no-op editor as the fallback for anything that could still spawn one:

```bash
GIT_EDITOR=true GIT_SEQUENCE_EDITOR=true git <command>
# equivalent: git -c core.editor=true -c sequence.editor=true <command>
```

`true` is the Unix no-op binary: git accepts the pre-filled message or todo list unchanged instead of blocking.

| Operation                     | Non-interactive form                                 |
| ----------------------------- | ---------------------------------------------------- |
| commit                        | `git commit -m "<message>"`                          |
| amend                         | `git commit --amend --no-edit` (or `-m "<message>"`) |
| merge                         | `git merge --no-edit` (or `GIT_MERGE_AUTOEDIT=no`)   |
| revert                        | `git revert --no-edit`                               |
| annotated tag                 | `git tag -a <tag> -m "<message>"`                    |
| cherry-pick / revert continue | `GIT_EDITOR=true git <command> --continue`           |
| rebase                        | see [Rebase rules](#rebase-rules)                    |

Never run interactive-only commands on your own initiative: `git add -i`, `git add -p`, `git rebase -i`, `git commit --interactive`, `git config -e`. If the user explicitly asks for one, let them drive it.

If a message must differ from the auto-filled one, pass it explicitly with `-m` or `-c`. Never open an editor to change it.

## Conform file

At the start of any commit workflow, check for `.conform.yml` or `.conform.yaml` in the repo root. If found, read it and extract the allowed types and scopes defined there - those replace the hardcoded defaults below. Obey whatever the conform file specifies; it is the source of truth for this repo.

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
- ASCII only: no emdashes, emojis, or other non-ASCII characters. Use hyphens (-) instead of emdashes

## Scope rules

Determine the scope from the repo, never from a fixed list baked into this skill:

1. If the repo defines scopes (`.conform.yaml`, `.conform.yml`, `commitlint.config.*`, `.commitlintrc*`, `CONTRIBUTING*`), use those verbatim - for example `.conform` policies define an explicit scope list.
2. Otherwise derive the scope from the repo itself: the dominant scope vocabulary in `git log`, or the top-level directory, package, or module the change lives in.
3. Use one scope per commit, matching the area the change touches. Keep it short, lowercase, and matching `[a-z0-9-]+`.
4. Omit the scope when the change is genuinely cross-cutting (touches three or more unrelated areas) or when the repo has no scope convention and no obvious area. Omission is always valid; inventing a scope is not.
5. When the repo's commit linter matches scopes as substrings, a shorter canonical name is accepted for longer variants - prefer the canonical one.

## Body rules

- Leave one blank line between subject and body
- Use bullet points starting with `- `
- Capitalise the first letter of each bullet point
- Write each bullet in imperative mood
- Keep bullet points short and clear
- ASCII only: no emdashes, emojis, or other non-ASCII characters. Use hyphens (-) instead of emdashes
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

Pre-commit hooks exist for a reason - always run them before committing. Never bypass with `--no-verify`.

1. If `prek` is available, run `prek run` against the staged files before committing
2. If hooks fail, fix the issues, re-stage, and re-run before proceeding
3. In Nix repos (presence of `flake.nix`), ensure hooks are up to date before running them:
   - Run `nix run .#pre-commit-install` to regenerate hooks, or enter the dev shell (`nix develop`) which force-installs them via `prek`

## Signing commits

Always sign commits with `-S`. This applies to every `git commit` and `git commit --amend` invocation. If signing fails because the key is locked, unlock the key and retry - do not fall back to unsigned.

## Amending commits

`git commit --amend` follows all the same rules as a new commit: conventional format, ASCII only, imperative mood, signed (`-S`), pre-commit hooks passing.

## Rebase rules

All rebase commands are non-interactive. Prefix every rebase invocation - start, `--continue`, `--skip`, `--abort` - with both editor variables so git never blocks on vim/nvim:

```bash
GIT_EDITOR=true GIT_SEQUENCE_EDITOR=true git rebase --committer-date-is-author-date <target>
```

`--committer-date-is-author-date` is **mandatory on every rebase start** - never omit it. It preserves the original author timestamps; a rebase without it silently rewrites commit dates. Do not run a bare `git rebase <target>`.

Never use `--interactive` on your own initiative. With `GIT_SEQUENCE_EDITOR=true` the proposed todo list is accepted as-is, so `-i` gives no editing power - only the user can drive an interactive rebase.

### Pre-commit hooks during rebase

Run pre-commit hooks after each replayed commit using `--exec`. Only check files changed by that specific commit - not the entire tree - so pre-existing issues in unrelated files don't block the rebase:

```bash
GIT_EDITOR=true GIT_SEQUENCE_EDITOR=true git rebase --committer-date-is-author-date \
  --exec 'files=$(git diff-tree --no-commit-id -r --name-only HEAD | tr "\n" " "); [ -z "$files" ] || <hook-runner> run --files $files' \
  <target>
```

Replace `<hook-runner>` with the repo's hook runner: `prek` or `pre-commit` when present, otherwise the command the repo documents (for example `lefthook run pre-commit`).

The guard `[ -z "$files" ]` skips hook execution when a commit touches no files (e.g., empty or merge commits).

If hooks fail mid-rebase, fix the issues, re-stage, then run `GIT_EDITOR=true git rebase --continue`.

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
