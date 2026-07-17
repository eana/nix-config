# GitLab CLI Command Reference

## Merge requests

### Create

```bash
glab mr create --fill                              # auto-fill from branch + commits
glab mr create --fill --draft --label "bugfix"     # common options
glab mr create --fill --assignee @me --milestone "v2.0" --target-branch main
```

`--fill` pulls title from last commit, description from commit body. `--draft` for WIP.

### List

```bash
glab mr list                        # open MRs authored by you
glab mr list --all                  # all open MRs
glab mr list --label bugfix         # filter by label
glab mr list --reviewer @me         # MRs awaiting your review
glab mr list --output json          # machine-readable
```

### View and diff

```bash
glab mr view                        # current branch's MR
glab mr view 42                     # by ID
glab mr diff 42                     # show diff
glab mr diff 42 --per-file          # one file at a time
```

### Approve, merge, close

```bash
glab mr approve 42
glab mr merge 42 --squash --delete-source-branch
glab mr merge 42 --rebase
glab mr checkout 42                 # checkout MR branch locally
glab mr rebase 42                   # rebase onto target
glab mr note 42 -m "Fix X"         # comment
glab mr update 42 --label "approved" --unassign @me
glab mr close 42
glab mr reopen 42
```

## CI/CD pipelines and jobs

### Status and list

```bash
glab ci status                      # latest on current branch
glab ci status --branch main
glab ci view                        # interactive TUI
glab ci list                        # recent pipelines
glab ci list --status failed        # filter: running|pending|success|failed|canceled
glab ci list --output json
```

### Trigger and retry

```bash
glab ci run                         # trigger on current branch
glab ci run --branch main
glab ci run --variables KEY=VALUE
glab ci retry <pipeline-id>
glab ci trigger <job-id>
glab ci retry <job-id>
```

### Trace logs

```bash
glab ci trace                       # interactively pick job
glab ci trace <job-id>              # specific job
glab ci trace <job-name>            # match by name
```

Log streams in real time. Ctrl-C to detach.

### Validate and artifacts

```bash
glab ci lint                        # lint .gitlab-ci.yml
glab ci lint path/to/.gitlab-ci.yml
glab ci artifact main build         # download artifacts from job "build" on "main"
```

## CI/CD variables

### List and inspect

```bash
glab variable list                  # project variables
glab variable list --group mygroup  # group variables
glab variable get MY_VAR
glab variable get MY_VAR --group mygroup
```

### Create and update

```bash
glab variable set MY_VAR "value"                    # plain
glab variable set MY_VAR "secret" --masked          # hidden in logs
glab variable set MY_VAR "secret" --protected       # protected branches only
glab variable set MY_VAR "prod" --scope production  # environment-scoped
glab variable update MY_VAR "new-value"
glab variable set MY_VAR "value" --group mygroup    # group-level
```

### Delete and export

```bash
glab variable delete MY_VAR
glab variable delete MY_VAR --group mygroup
glab variable export                # KEY=VALUE format
glab variable export --output json
```

## Raw API access

```bash
glab api projects/:id/releases                                # GET (default)
glab api projects/:id/issues --method POST -f title="Bug"     # POST
glab api projects/:id/merge_requests --paginate               # all pages
glab api --hostname gitlab.example.com projects/:id/pipelines  # specific host
glab api graphql -f query='{ currentUser { name } }'         # GraphQL
```

`:id` auto-substitutes current project ID. For cross-project, use numeric ID or `namespace%2Fproject`.

## Tips

- Most commands infer the project from `git remote origin`
- Use `glab <command> --help` to see all flags
- For pipelines on MRs, `glab ci status` inside the MR branch shows the detached pipeline
- `glab mr view --web` and `glab ci view --web` open items in browser
