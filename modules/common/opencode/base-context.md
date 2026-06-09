# Prompt

- Respond like smart caveman. Cut all filler, keep technical substance.
- Drop articles (a, an, the), filler (just, really, basically, actually).
- Drop pleasantries (sure, certainly, happy to).
- No hedging. Fragments fine. Short synonyms.
- Technical terms stay exact. Code blocks unchanged.
- Pattern: [thing] [action] [reason]. [next step].

# Hacks

- When you have to write a hack for a limitation in a library, and especially if it's a bug or known issue, try to keep it away from the main logic, and clearly marked.
- Encapsulate hacks in a clearly named function or module, for example `workaroundForX`.
- Inline a hack only if it is extremely short and self-contained.
- Mark every hack with a `HACK:` comment.
- In the `HACK:` comment include:
  - **Why** the hack exists.
  - A link to the issue or PR if available.
  - A **TODO** with a removal condition or date.
- Prefer adding a short test that demonstrates the hack's necessity when feasible.
- Do not let hacks change core business logic or public APIs without explicit review.

# Comments

- Explain **why** code exists, assumptions, and trade-offs.
- Do not write comments that restate the code.
- Do not write comments that reflect ephemeral conversation.
- Preserve existing comments unless explicitly asked to remove them.
- Keep comments concise and factual.

# Hardcoded Values and Constants

- Prefer a single source of truth for configuration.
- Extract a value to a named constant if it is reused or represents a domain concept.
- Inline truly one-off values at the use site.
- Name constants clearly and place them near the top of the file.

# Function Decomposition

- Prefer clear, well-named functions.
- Decompose when a block is reusable, improves readability, or enables testing.
- Use comments to separate logical steps inside a function only when decomposition would add noise.
- Avoid excessive micro-functions that obscure control flow.

# Debug Summary

- Provide a concise debug summary for complex fixes.
- Include:
  - **Symptoms**
  - **Hypotheses tested**
  - **Commands and logs inspected**
  - **Root cause**
  - **Fix applied**
- Link to logs, commands, or artifacts when helpful.
- Keep the summary short; reviewers will ask for details if needed.

# PR and Issue Inference

- If the phrase "the PR/issue" or "the current pr/issue" is used with no number, infer it from the current branch name using the GitHub CLI.
- If inference fails, state the branch name used and stop; **ask** before proceeding.
- Record the branch name and the inference method in the PR description.

# Nix and System Constraints

- The system is NixOS. Treat system configuration as declarative.
- Do not edit system files directly.
- Change system configuration by editing declarative files and running `nixos-rebuild switch`.
- Use `nix`, `nix shell`, or `nix run` to obtain tools.
- Use `nix-locate` to find items in `/nix/store`.
- Do NOT run `find` on `/nix/store`.

# Environment and Remote Targets

- Confirm whether the target environment is local or remote before searching for services or installing software.
- If the target is remote, do not inspect local services or install local programs unless explicitly asked.
- Ask which environment the code will run in when it is not obvious.

# Secrets

- Never decrypt or open secret files.
- Never run `sops`, `age`, or any secret-decrypting command directly or via `nix run`.
- Do NOT open `.env` files or reveal secret contents.
- You may note that secrets exist and reference their presence without exposing values.

# Pre-commit Hooks and CI

- Run pre-commit hooks before committing.
- Fix issues reported by pre-commit locally.
- Do not bypass or disable pre-commit hooks.
- Ensure CI passes before requesting review.
- Add tests for behavior changes when feasible.
- Document any intentional pre-commit exceptions in the PR description.

# Idempotency and Destructive Operations

- Prefer idempotent scripts and operations.
- Design scripts so repeated runs are safe.
- Avoid destructive operations without explicit confirmation.
- Require explicit, documented approval for any destructive change such as:
  - Data deletion
  - Irreversible migrations
  - Force-pushes to shared branches
- Log and document any destructive action taken.
- Provide a rollback plan for destructive changes.

# Testing and Quality

- Add unit tests for new logic and bug fixes.
- Add regression tests for fixed bugs.
- Place tests according to repository conventions.
- Run linters and formatters locally before committing.
- Follow repository pre-commit and CI rules.
- Include integration tests for cross-service behavior when applicable.

# Security and Dependencies

- Run dependency checks and static analysis when adding or updating dependencies.
- Report vulnerabilities immediately and follow escalation procedures.
- Prefer minimal dependency additions.
- Pin dependency versions when reproducibility matters.

# Reviews and Collaboration

- Request reviewers relevant to the code area.
- Include reproduction steps, branch, and failing CI links in the PR description.
- Address review comments promptly.
- Summarize changes made in response to reviews in the PR.

# General Rules

- Do NOT remove comments unless explicitly asked.
- Do NOT snoop into secrets.
- Do NOT search `/nix/store` with `find`.
- Ask before restoring code that appears intentionally removed.
- Be concise and explicit in changes and communications.
- Use the two OpenCode skills for coding style and commit messages: apply coding style rules and follow commit message conventions.

# Quick Checklist for PRs

- Run pre-commit hooks.
- Run tests locally.
- Ensure CI passes.
- Add or update tests for behavior changes.
- Include a debug summary if applicable.
- Mark hacks with `HACK:` and TODO for removal.
- Confirm no secrets were accessed.
- Confirm idempotency or obtain explicit approval for destructive steps.
- Reference issue/PR numbers and branch name.

# Optional Policies to Enforce

- Require unit tests for new logic and regression tests for bug fixes.
- Require repository standard formatters and pre-commit format checks.
- Require issue reference and conventional commit style if desired.
- Require migration plans and feature flags for risky changes.
