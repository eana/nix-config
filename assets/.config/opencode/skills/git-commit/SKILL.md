---
name: git-commit
description: Write clear, conventional Git commit messages following a consistent structure and ruleset
compatibility: opencode
---

## What I do

Help write well-structured Git commit messages following the Conventional
Commits specification.

## Commit message structure

```
<type>(<optional scope>): <description>

[optional body]

[optional footer]
```

## Types

Use exactly one of: `build`, `chore`, `ci`, `docs`, `feat`, `fix`, `perf`,
`refactor`, `style`, `test`

- `feat` — adds a new feature
- `fix` — fixes a bug
- All other types — use the one that best describes the change

## Subject line rules

- Type and description are required; scope is optional
- Description must immediately follow the type/scope prefix
- Write in imperative mood: `add`, `fix`, `update`, `remove`, `rename`
- Limit to 60 characters
- Lowercase the entire subject line
- Do not end with punctuation
- ASCII only: no emojis, em dashes, or other non-standard characters

## Scope rules

- Use the name of the most directly affected component: module name, host
  name, or directory (e.g. `nixvim`, `nixbox`, `zsh`)
- Use `deps` for dependency or flake input updates
- Use `flake` for structural changes to `flake.nix`
- Omit scope when a change is genuinely cross-cutting (touches three or more
  unrelated areas)

## Body rules

- Leave one blank line between subject and body
- Use bullet points starting with `- `
- Capitalise the first letter of each bullet point
- Write each bullet in imperative mood
- Keep bullet points short and clear
- ASCII only: no emojis, em dashes, or other non-standard characters
- Omit the body entirely if it adds no useful detail beyond the subject

## Breaking changes

- Append `!` to the type/scope for breaking changes: `feat!:` or
  `feat(scope)!:`
- Add a `BREAKING CHANGE: <description>` footer separated from the body by a
  blank line
- The footer must describe what breaks and how to migrate

## Atomicity

- Each commit must represent one logical change
- If unrelated changes are present in the working tree, split them into
  separate commits before staging

## Staging hygiene

Before writing the commit message:

1. Run `git status` to see all modified files
2. Stage only files that were explicitly changed during the session; never
   stage unrelated pre-existing modifications
3. Avoid `git add .` or `git add -A` unless every change in the working tree
   is intentional and part of this commit
4. Run `git diff --staged` and confirm the staged diff matches the intended
   change before proceeding

## Rebase rules

- Always pass `--committer-date-is-author-date` when rebasing

## Examples

Good subject lines:

```
feat(opencode): add declarative skills support
fix(zsh): correct PATH ordering for homebrew on darwin
chore(deps): update flake inputs
refactor(nixvim): extract keymap definitions into separate file
```

Good commit with body:

```
feat(opencode): add declarative skills support

- Add skills.enable toggle for built-in skills bundled with the config
- Add skills.extraSkillsDirs for external skill directories
- Deploy each skill to ~/.config/opencode/skills/<name>/SKILL.md
- Use last-writer-wins on name collision to allow overrides
```

Breaking change commit:

```
feat(api)!: remove legacy configuration format

- Drop support for the v1 config schema
- Require migration to the v2 format before upgrading

BREAKING CHANGE: v1 config files are no longer read; run
`migrate-config` to convert them to v2 format before upgrading.
```

Body-less commit (body would add no value):

```
chore(deps): update flake inputs
```
