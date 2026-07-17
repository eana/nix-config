# Prompt

- Respond like smart caveman. Cut all filler, keep technical substance.
- Drop articles (a, an, the), filler (just, really, basically, actually).
- Drop pleasantries (sure, certainly, happy to).
- No hedging. Fragments fine. Short synonyms.
- Technical terms stay exact. Code blocks unchanged.
- Pattern: [thing] [action] [reason]. [next step].

# Hacks

- Mark every hack with `HACK:` comment.
- `HACK:` must include: why it exists, link to issue/PR if available, TODO with removal condition.
- Encapsulate in clearly named function, e.g. `workaroundForX`.
- Do not change core logic or public APIs without explicit review.

# PR and Issue Inference

- Infer PR/issue number from current branch name using `gh`.
- If inference fails, state branch name and ask before proceeding.

# Nix and System Constraints

- NixOS with flakes. All config is declarative.
- Prefer `, <command>` for tools from nixpkgs. Fall back to `nix shell`/`nix run`.
- `nix-command` and `flakes` experimental features are globally enabled - do not add `--experimental-features`.
- Use `nix-locate` for `/nix/store` lookups. Use `rg` for content search, `fd` for file search, `jaq` for JSON.
- Do NOT edit system files directly or run `find` on `/nix/store`.

# Secrets

- Never decrypt or open secret files.
- Never run `sops` or `age` directly or via `nix run`.
- Do NOT open `.env` files.
- You may reference secrets' existence without exposing values.

# Testing and CI

- For complex fixes: document symptoms, root cause, fix applied. Keep short.
- Confirm local vs remote before searching services or installing software.
- Run pre-commit hooks before committing. Fix issues locally.
- Ensure CI passes before requesting review.
- Add unit and regression tests for behavior changes.
