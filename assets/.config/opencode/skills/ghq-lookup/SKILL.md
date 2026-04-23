---
name: ghq-lookup
description: "Use when you need to read, explore, or reference source code from any Git repository. Use before cloning manually or asking the user for a path."
compatibility: opencode
---

# ghq Lookup

ghq manages remote repository clones under a single root, organized as
`<root>/<host>/<org>/<repo>`. Use it to find and fetch source code instead
of cloning manually.

## When to Use

- You need to read or explore source code of a dependency, library, or tool
- The user references a repo by org/name without providing a path
- You need the local path to an already-cloned repo
- Do **not** use ghq for repos that must live at a specific non-ghq path

## Procedure

### 1 - Check if the repo is already available

```bash
ghq list -p <query>    # partial match, prints full paths
```

If the query returns a match, use that path directly. No fetch needed.

### 2 - Fetch if not available

```bash
ghq get <host>/<org>/<repo>       # e.g. ghq get github.sebank.se/s2450g/config
ghq get <org>/<repo>              # defaults to github.com
ghq get -p <org>/<repo>           # clone via SSH
ghq get --shallow <org>/<repo>    # shallow clone for large repos
```

Then use `ghq list -p <query>` to get the full path.

### 3 - Update if freshness matters

```bash
ghq get -u <org>/<repo>    # runs git remote update on existing clone
```

## Quick Reference

| Task                            | Command                          |
| ------------------------------- | -------------------------------- |
| Check if repo exists / get path | `ghq list -p <query>`            |
| Fetch a repo                    | `ghq get <host>/<org>/<repo>`    |
| Fetch via SSH                   | `ghq get -p <org>/<repo>`        |
| Shallow clone                   | `ghq get --shallow <org>/<repo>` |
| Update existing repo            | `ghq get -u <org>/<repo>`        |
