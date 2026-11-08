# 0001: Automated wiki refresh in CI

## Context

The `repo-wiki` skill is useful but only runs manually from an interactive
opencode session. Keeping `wiki/` current therefore depends on the user
remembering to run it. Local runs work well with Ollama embeddings and whatever
chat model the opencode session uses. CI has no Ollama and needs a hosted model.

Gemini offers a free tier for both chat (`gemini-3.8-flash`) and embeddings
(`gemini-embedding-2`). The bundled `repo-wiki-index` and `repo-wiki-query`
tools only speak the Ollama API, so they need a backend switch before CI can use
Gemini.

## Decision

- Add `REPO_WIKI_EMBED_BACKEND` to both tools, defaulting to `ollama`.
- Support a `gemini` backend using the native `batchEmbedContents` and
  `embedContent` endpoints.
- Run the refresh weekly and on demand in GitHub Actions with the pinned Nix
  packages, Gemini chat and embeddings, and a persisted `.wiki-cache`.
- Open a PR with only `wiki/` changes. Never push to `master` directly.
- Leave local interactive use unchanged: Ollama embeddings and the configured
  opencode model.
- Defer the Phase 4 semantic skip until the indexer can supply previous vectors
  for changed chunks.

## Consequences

- CI depends on Gemini free-tier quotas; incremental refreshes keep request
  counts low, and quota exhaustion fails the job without a PR.
- Index caches are valid only for one backend, model, and dimension, so a
  mismatch forces a full reindex.
- Manual wiki edits survive refreshes through the existing git-diff logic.
- Local runs gain no automation and no new commands.
