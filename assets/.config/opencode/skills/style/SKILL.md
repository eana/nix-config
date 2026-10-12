---
name: style
description: Use for writing or reviewing documentation and prose in any project: READMEs, wiki pages, guides, doc comments, release notes, and code comments. It enforces a consistent house style - verb tense rules (present for descriptions, imperative for commands and steps, past for completed actions), pronoun preference (second person for guidance, third person for system behavior), and precise technical terminology. Load it whenever the user wants new writing to stay consistent with existing docs, a draft reviewed for tone, tense, or terminology, a section rewritten or normalized, or docstrings and comments checked against project conventions. Use it even when the user just says 'make this read like the rest of the docs'. Not for translating, summarizing, ad or social copy, API doc generation, or fixing code.
compatibility: opencode
---

## Verb tense

- Present tense for general descriptions and instructions
- Imperative mood for commands and step-by-step instructions
- Past tense only for completed actions or historical context
- Future tense for expected outcomes or planned actions

## Pronouns

- Second person ("you") for instructions and guidance
- Avoid first person ("I", "we") unless providing author notes
- Third person for system behaviors or features

## Technical terms

- Use precise tool names and domain-specific vocabulary consistently
- Introduce uncommon terms with a brief explanation
- Capitalise Nix-specific terms correctly: NixOS, nix-darwin, home-manager, nixvim

## Structure

- Clear sections with headings
- Step-by-step guides, prerequisites, configuration details
- Code blocks, command examples for clarity
- Reproducibility, automation, security best practices
- Consistent terminology and formatting

## Nix doc conventions

- Module option descriptions in `lib.mkOption`: state what the option controls, not how it's used
- Module `description` field: one-line summary, imperative mood
- Use `lib.mkEnableOption` for boolean toggles - it generates the description automatically

## Markdown conventions (this repo)

- One top-level heading (`#`) per document
- Use lists for sequences of steps
- Prefer short lines (80-100 columns); tables may exceed
- No trailing whitespace; files must end with newline
- Code fences with language tags for commands and config

## Character set

- All generated content MUST use only ASCII characters - no emdashes, emojis, or other non-ASCII characters.
- Use hyphens (-) instead of emdashes, spell out symbols, and keep all text ASCII-safe.
- Applies to markdown, diagrams, commit messages, code comments, and any file you write.
- To check, search for the non-ASCII range with `rg '[^\x00-\x7F]' <path>` (BSD grep on macOS lacks `-P`).

## Visual aids

Reference diagrams and screenshots to support explanations when helpful.
