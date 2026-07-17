---
name: gitlab-cli-tool
description: >
  Use when interacting with GitLab via glab - creating/reviewing merge requests, checking pipeline status,
  tracing CI job logs, managing CI/CD variables, or authenticating with self-hosted GitLab or gitlab.com.
  Trigger on any mention of GitLab, MR, merge request, pipeline, CI/CD job, or glab.
---

# GitLab CLI (glab)

`glab` is the official GitLab CLI. Use it instead of the web UI for MRs, pipelines, variables, and API access.

## Setup

```bash
# Authenticate once per instance
glab auth login --hostname gitlab.example.com

# Or use env vars
export GITLAB_TOKEN=<token>
export GITLAB_HOST=gitlab.example.com

# Check status
glab auth status
```

Multiple hosts supported. Pass `--hostname` per command or set `GITLAB_HOST`.

## Detecting the active host

```bash
git remote get-url origin
# e.g. git@gitlab.example.com:group/project.git
```

`glab` auto-detects the host from the remote when run inside the repo. Use `-R group/project` to target a different repo.

## Quick Reference

| Task | Command |
|------|---------|
| Create MR | `glab mr create --fill` |
| List MRs | `glab mr list` |
| View MR | `glab mr view 42` |
| Approve MR | `glab mr approve 42` |
| Merge MR | `glab mr merge 42 --squash --delete-source-branch` |
| CI status | `glab ci status` |
| List pipelines | `glab ci list` |
| Trace job log | `glab ci trace <job-id>` |
| Trigger pipeline | `glab ci run` |
| Retry job | `glab ci retry <job-id>` |
| Lint CI config | `glab ci lint` |
| List variables | `glab variable list` |
| Set variable | `glab variable set MY_VAR "value"` |
| Delete variable | `glab variable delete MY_VAR` |
| Raw API call | `glab api projects/:id/releases` |

## Common Flags

| Flag | Purpose |
|------|---------|
| `-R / --repo` | Target specific project (`group/project` or full URL) |
| `--hostname` | Target specific GitLab instance |
| `--output json` | JSON output |
| `--paginate` | Fetch all pages (`glab api` only) |

## Detailed Command Reference

Read `references/commands.md` for full MR, CI/CD, variable, and API commands.

## Tips

- Run commands from inside the repo. Most commands infer the project from `git remote origin`.
- Use `glab <command> --help` for all flags
- `glab mr view --web` and `glab ci view --web` open in browser
- Inside an MR branch, `glab ci status` shows the detached pipeline automatically
