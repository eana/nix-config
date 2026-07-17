---
name: style
description: >
  Use when writing documentation, READMEs, or code comments - enforces
  tense consistency, pronoun usage, technical term precision, and
  structure conventions for this repo
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

## Visual aids

Reference diagrams and screenshots to support explanations when helpful.
