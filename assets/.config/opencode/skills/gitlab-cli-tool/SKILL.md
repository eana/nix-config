---
name: gitlab-cli-tool
description: >
  Use this skill whenever the user wants to interact with GitLab from the
  command line using glab — including creating or reviewing merge requests,
  checking pipeline status, tracing CI job logs, managing CI/CD variables,
  or authenticating with a self-hosted GitLab instance or gitlab.com. Trigger
  this skill whenever the user mentions GitLab, MR, merge request, pipeline,
  CI/CD job, GitLab variable, or glab, even if they don't explicitly ask for
  CLI help. Also trigger when the user is in a git repo that has a GitLab
  remote and wants to do anything with that repo's hosting.
---

# GitLab CLI (glab)

`glab` is the official GitLab CLI. It mirrors the `gh` (GitHub CLI) experience
but targets GitLab, including self-hosted instances. Use it instead of the
web UI for anything covered below.

## Setup and authentication

### First-time login

For each GitLab instance you use, authenticate once:

```bash
# Self-hosted instance
glab auth login --hostname gitlab.example.com

# gitlab.com
glab auth login --hostname gitlab.com
```

`glab` will prompt for a personal access token (PAT) with the required scopes
(`api`, `read_user`, `write_repository`). Alternatively, export the token as an
environment variable before running any command — `glab` picks it up
automatically:

```bash
export GITLAB_TOKEN=<your-token>
# For a specific host:
export GITLAB_HOST=gitlab.example.com
```

### Check authentication status

```bash
glab auth status
# Show all configured hosts:
glab auth status --show-token
```

### Switch between instances

`glab` supports multiple authenticated hosts simultaneously. Use `--hostname`
on any command to target a specific instance, or set `GITLAB_HOST` in the
environment for the duration of a session.

## Detecting the active host

Before running commands, determine which GitLab instance the current repo
belongs to:

```bash
git remote get-url origin
# e.g. git@gitlab.example.com:group/project.git
#   or https://gitlab.com/group/project.git
```

Extract the hostname from that URL and pass it as `--hostname` only when
needed — `glab` auto-detects it from the remote in most cases when you're
inside the repo directory.

To target a repo that is not the current directory's remote, use the `-R` /
`--repo` flag:

```bash
glab mr list -R group/other-project
glab mr list -R gitlab.example.com/group/project   # cross-host explicit form
```

---

## Merge requests

### Create

```bash
# Auto-fill title and description from branch name and commits
glab mr create --fill

# Common options
glab mr create --fill \
  --draft \
  --label "bugfix,needs-review" \
  --assignee @me \
  --milestone "v2.0" \
  --target-branch main
```

`--fill` pulls the MR title from the last commit message and the description
from the commit body. Use `--draft` when the MR is not yet ready for review.

### List and find

```bash
glab mr list                        # open MRs authored by you
glab mr list --all                  # all open MRs in the project
glab mr list --label bugfix         # filter by label
glab mr list --reviewer @me         # MRs awaiting your review
glab mr list --output json          # machine-readable output
```

### View and diff

```bash
glab mr view                        # view current branch's MR
glab mr view 42                     # view by MR ID
glab mr diff 42                     # show diff in terminal
glab mr diff 42 --per-file          # one file at a time
```

### Approve and merge

```bash
glab mr approve 42
glab mr merge 42
glab mr merge 42 --squash --delete-source-branch
glab mr merge 42 --rebase
```

### Other MR operations

```bash
glab mr checkout 42                 # check out the MR branch locally
glab mr rebase 42                   # rebase source branch onto target
glab mr note 42 -m "Please fix X"  # leave a comment
glab mr update 42 --label "approved" --unassign @me
glab mr close 42
glab mr reopen 42
```

---

## CI/CD pipelines and jobs

### View pipeline status

```bash
glab ci status                      # latest pipeline on current branch
glab ci status --branch main        # specific branch
glab ci view                        # interactive TUI for the pipeline
```

### List pipelines

```bash
glab ci list                        # recent pipelines
glab ci list --status failed        # filter by status (running|pending|success|failed|canceled)
glab ci list --output json
```

### Trigger and retry

```bash
glab ci run                         # trigger a new pipeline on current branch
glab ci run --branch main           # trigger on a specific branch
glab ci run --variables KEY=VALUE   # pass runtime variables
glab ci retry <pipeline-id>         # retry a failed pipeline
glab ci trigger <job-id>            # trigger a manual job
glab ci retry <job-id>              # retry a specific failed job
```

### Trace job logs

This is the most useful command when debugging failures:

```bash
glab ci trace                       # interactively pick a job to tail
glab ci trace <job-id>              # tail a specific job's log
glab ci trace <job-name>            # match by job name (e.g. "build", "test")
```

The log streams in real time. Press `Ctrl-C` to detach without cancelling the job.

### Validate `.gitlab-ci.yml`

```bash
glab ci lint                        # lint the file in the current directory
glab ci lint path/to/.gitlab-ci.yml
```

### Download artifacts

```bash
glab ci artifact main build         # download artifacts from job "build" on branch "main"
```

---

## CI/CD variables

Variables can be scoped to a project or a group. Always check scope before
setting to avoid accidentally overwriting a group-level variable.

### List and inspect

```bash
glab variable list                  # project variables
glab variable list --group mygroup  # group variables
glab variable get MY_VAR
glab variable get MY_VAR --group mygroup
```

### Create and update

```bash
# Create a plain variable
glab variable set MY_VAR "some-value"

# Create a masked variable (value hidden in job logs)
glab variable set MY_VAR "secret" --masked

# Create a protected variable (only available on protected branches/tags)
glab variable set MY_VAR "secret" --protected

# Scope to a specific environment
glab variable set MY_VAR "prod-value" --scope production

# Update an existing variable
glab variable update MY_VAR "new-value"

# Group-level variable
glab variable set MY_VAR "value" --group mygroup
```

### Delete

```bash
glab variable delete MY_VAR
glab variable delete MY_VAR --group mygroup
```

### Export all variables

```bash
glab variable export                # prints all project variables as KEY=VALUE
glab variable export --output json
```

---

## Raw API access

When no subcommand covers your need, use `glab api` to make authenticated
requests directly against the GitLab REST API:

```bash
# GET request (default)
glab api projects/:id/releases

# POST with a JSON body
glab api projects/:id/issues \
  --method POST \
  -f title="Bug: something is broken" \
  -f labels="bug"

# Paginate through all results automatically
glab api projects/:id/merge_requests --paginate

# Target a specific host explicitly
glab api --hostname gitlab.example.com projects/:id/pipelines
```

`:id` is automatically substituted with the current project's ID when run
inside a repo. For cross-project calls, supply the full numeric project ID or
`namespace%2Fproject` (URL-encoded slash).

The GraphQL endpoint is also available:

```bash
glab api graphql -f query='{ currentUser { name } }'
```

---

## Common flags reference

| Flag | Purpose |
|---|---|
| `-R / --repo` | Target a specific project (`group/project` or full URL) |
| `--hostname` | Target a specific GitLab instance |
| `--output json` | JSON output (most commands) |
| `--output text` | Plain text (default) |
| `--paginate` | Fetch all pages (`glab api` only) |

---

## Tips

- Most commands infer the project from `git remote origin`. Run commands from
  inside the repo whenever possible.
- Use `glab <command> --help` to see all flags — the CLI is well-documented and
  flags change between versions.
- For pipelines on MRs, `glab ci status` inside the MR branch shows the
  detached pipeline automatically.
- `glab mr view --web` and `glab ci view --web` open the item in the browser
  if you need the full UI.
