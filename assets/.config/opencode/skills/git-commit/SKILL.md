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

## Body rules

- Leave one blank line between subject and body
- Use bullet points starting with `- `
- Capitalise the first letter of each bullet point
- Write each bullet in imperative mood
- Keep bullet points short and clear
- Omit the body entirely if it adds no useful detail beyond the subject

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

Body-less commit (body would add no value):

```
chore(deps): update flake inputs
```
