---
name: git-commit
description: Use when writing commit messages, staging changes for commit, or rebasing - enforces conventional commits format, branch protection, staging hygiene, and atomic commits
---

## Branching rules

- **Check current branch:** Always determine the current branch (`git branch --show-current`) before writing or executing a commit.
- **Protect main/master:** If the current branch is `main` or `master`, halt and explicitly ask the user for permission before proceeding.
- **Prefer feature branches:** When asked to commit on `main` or `master`, actively suggest creating a new feature branch (`git checkout -b <type>/<brief-description>`).

## Commit message structure

```
<type>(<optional scope>): <description>

[optional body]

[optional footer]
```

## Types

Use exactly one of: `build`, `chore`, `ci`, `docs`, `feat`, `fix`, `perf`, `refactor`, `style`, `test`

## Subject line rules

- Type and description are required; scope is optional
- Description must immediately follow the type/scope prefix
- Write in imperative mood: `add`, `fix`, `update`, `remove`, `rename`
- Limit to 60 characters
- Lowercase the entire subject line
- Do not end with punctuation
- ASCII only: no emojis, dashes, or other non-standard characters

## Scope rules

- Use the name of the most directly affected component: module name, host name, or directory
- Use `deps` for dependency or flake input updates
- Use `flake` for structural changes to `flake.nix`
- Omit scope when a change is genuinely cross-cutting (touches three or more unrelated areas)

## Body rules

- Leave one blank line between subject and body
- Use bullet points starting with `- `
- Capitalise the first letter of each bullet point
- Write each bullet in imperative mood
- Keep bullet points short and clear
- ASCII only: no emojis, dashes, or other non-standard characters
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

## Rebase rules

- Always pass `--committer-date-is-author-date` when rebasing

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
- Deploy each skill to ~/.config/opencode/skills/<name>/SKILL.md
- Use last-writer-wins on name collision to allow overrides
```

```
feat(api)!: remove legacy configuration format

- Drop support for the v1 config schema
- Require migration to the v2 format before upgrading

BREAKING CHANGE: v1 config files are no longer read; run
`migrate-config` to convert them to v2 format before upgrading.
```
