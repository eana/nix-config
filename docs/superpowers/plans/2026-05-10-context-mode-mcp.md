# context-mode MCP Server Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Package `mksglu/context-mode` v1.0.111 as a Nix derivation and wire it into the opencode module as both an MCP server and an OpenCode plugin (with hooks).

**Architecture:** The npm tarball ships pre-built (`cli.bundle.mjs` / `server.bundle.mjs` for the MCP server, `build/` for the plugin entry point). The MCP server command is wrapped with `bun` (not `node`) so that `globalThis.Bun` is truthy at runtime — this causes `db-base.js` to use the built-in `bun:sqlite` on all platforms, avoiding any need for the `better-sqlite3` native addon. The OpenCode plugin (`build/opencode-plugin.js`) is loaded via `import()` inside the running OpenCode process, which is already a bun single-file executable, so `bun:sqlite` is used there too. No patching of upstream code is required.

**Tech Stack:** Nix `stdenv.mkDerivation`, `fetchurl`, `makeWrapper`, `bun` (runtime wrapper), home-manager `programs.opencode`.

______________________________________________________________________

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Create | `modules/common/opencode/packages/context-mode.nix` | Derivation: fetch npm tarball, install package files, provide `context-mode` binary (bun-wrapped) and node module layout |
| Modify | `modules/common/opencode/default.nix` | Wire derivation: add `callPackage`, add `mcp.context-mode` entry, add `plugin` entry |

______________________________________________________________________

## SQLite runtime — why bun everywhere

`db-base.js` inside `context-mode` has this driver selection:

```js
if (globalThis.Bun) {
    // bun:sqlite — no native addon
} else if (process.platform === "linux") {
    // node:sqlite (Node >= 22.5 built-in)
} else {
    // better-sqlite3 — native addon, not in nixpkgs
}
```

- **Plugin code** runs inside the OpenCode bun single-file executable → `globalThis.Bun` is true → `bun:sqlite`. No issue.
- **MCP server** (`server.bundle.mjs`) is spawned as a child process. Its shebang is `#!/usr/bin/env node` but we override the runtime in `makeWrapper` to use `bun` explicitly. With bun as the runtime, `globalThis.Bun` is true → `bun:sqlite`. Works on all platforms, no patching.

______________________________________________________________________

## Task 1: Write the context-mode derivation

**Files:**

- Create: `modules/common/opencode/packages/context-mode.nix`

- [ ] **Step 1: Compute the npm tarball sha256**

```bash
nix-prefetch-url https://registry.npmjs.org/context-mode/-/context-mode-1.0.111.tgz --type sha256
```

Record the output hash (base32). It will be used in the next step.

- [ ] **Step 2: Write the derivation**

Create `modules/common/opencode/packages/context-mode.nix`:

```nix
{
  lib,
  stdenv,
  fetchurl,
  bun,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "context-mode";
  version = "1.0.111";

  src = fetchurl {
    url = "https://registry.npmjs.org/context-mode/-/context-mode-${finalAttrs.version}.tgz";
    hash = "sha256-<HASH-FROM-STEP-1-CONVERTED-TO-SRI>";
  };

  nativeBuildInputs = [
    bun
    makeWrapper
  ];

  dontBuild = true;
  dontUnpack = false;

  installPhase = ''
    runHook preInstall

    # The npm tarball unpacks into a "package/" subdirectory.
    mkdir -p $out/lib/context-mode
    cp -r package/. $out/lib/context-mode/

    mkdir -p $out/bin
    # Use bun as the runtime so globalThis.Bun is set, which causes db-base.js
    # to use bun:sqlite instead of better-sqlite3 (unavailable in nixpkgs).
    makeWrapper ${bun}/bin/bun $out/bin/context-mode \
      --add-flags "$out/lib/context-mode/server.bundle.mjs"

    runHook postInstall
  '';

  meta = {
    description = "Context window optimization MCP server for AI coding agents";
    homepage = "https://github.com/mksglu/context-mode";
    # Elastic License v2 — source-available, not OSI open source
    license = lib.licenses.elastic20;
    mainProgram = "context-mode";
  };
})
```

> **Hash format:** `nix-prefetch-url` outputs a base32 hash. Convert to SRI format with:
> `nix hash to-sri --type sha256 <base32-hash>`
> or use `nix-prefetch-url --print-path` and compute with `nix hash file`.

- [ ] **Step 3: Verify the elastic20 license attribute**

```bash
nix-instantiate --eval -E '(import <nixpkgs> {}).lib.licenses ? elastic20'
```

Expected: `true`. If `false`, check `lib.licenses.unfree` as a fallback and add a `# FIXME:` comment.

- [ ] **Step 4: Build**

```bash
nix-build -E '(import <nixpkgs> {}).callPackage ./modules/common/opencode/packages/context-mode.nix {}'
```

Expected: a store path symlinked as `result/` containing:

- `result/bin/context-mode`

- `result/lib/context-mode/server.bundle.mjs`

- `result/lib/context-mode/build/opencode-plugin.js`

- `result/lib/context-mode/package.json`

- [ ] **Step 5: Smoke-test the binary**

```bash
./result/bin/context-mode --version
```

Expected: prints a version string (`1.0.111` or similar) without errors.

- [ ] **Step 6: Commit**

```bash
git add modules/common/opencode/packages/context-mode.nix
git commit -m "feat(opencode): add context-mode Nix derivation (bun-wrapped)"
```

______________________________________________________________________

## Task 2: Wire context-mode into the opencode module

**Files:**

- Modify: `modules/common/opencode/default.nix`

- [ ] **Step 1: Add the callPackage call**

In the `let` block near line 23 (after the `opentofu-mcp-server` line), add:

```nix
  context-mode = pkgs.callPackage ./packages/context-mode.nix { };
```

- [ ] **Step 2: Add the MCP entry**

In the `mcp` attrset (around line 289), add:

```nix
          "context-mode" = {
            type = "local";
            command = [ "${context-mode}/bin/context-mode" ];
          };
```

- [ ] **Step 3: Research the plugin entry**

Check what value the `plugin` key in `programs.opencode.settings` accepts. Fetch the opencode config schema:

```bash
curl -s https://opencode.ai/config.json | python3 -m json.tool | grep -A10 '"plugin"'
```

Also check what the context-mode docs say:

```bash
curl -sL https://raw.githubusercontent.com/mksglu/context-mode/main/configs/opencode/opencode.json
```

Expected: `"plugin": ["context-mode"]` — a bare package name. OpenCode resolves this via Node module resolution. Since our derivation puts the module at `$out/lib/context-mode`, we need to either:

- **Option A** (preferred): pass the absolute store path: `plugin = [ "${context-mode}/lib/context-mode" ]`
- **Option B**: set `NODE_PATH` in the wrapper and use `"context-mode"` as the name

Try Option A first. If OpenCode rejects absolute paths, fall back to Option B by adding `--set NODE_PATH "${context-mode}/lib"` to the `makeWrapper` call in `context-mode.nix` and using `plugin = [ "context-mode" ]`.

- [ ] **Step 4: Add the plugin entry**

In `programs.opencode.settings`, add (using whichever option from Step 3 works):

```nix
        plugin = [ "${context-mode}/lib/context-mode" ];
```

- [ ] **Step 5: Evaluate**

```bash
nix-instantiate --eval -E '
  let
    pkgs = import <nixpkgs> {};
    lib = pkgs.lib;
    hm = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  in "ok"
' 2>&1 | head -5
```

Simpler check — just verify the module evaluates without errors by doing a flake check:

```bash
nix flake check --no-build 2>&1 | head -30
```

- [ ] **Step 6: Commit**

```bash
git add modules/common/opencode/default.nix
git commit -m "feat(opencode): wire context-mode as MCP server and plugin"
```

______________________________________________________________________

## Task 3: Build and smoke-test the full configuration

- [ ] **Step 1: Build the home configuration**

On nixbox:

```bash
nixos-rebuild build --flake .#nixbox
```

On macbox:

```bash
darwin-rebuild build --flake .#macbox
```

- [ ] **Step 2: Switch**

```bash
# nixbox
sudo nixos-rebuild switch --flake .#nixbox
# or macbox
darwin-rebuild switch --flake .#macbox
```

- [ ] **Step 3: Verify generated opencode.json**

```bash
cat ~/.config/opencode/opencode.json | python3 -m json.tool | grep -A5 'context-mode\|plugin'
```

Expected: `mcp.context-mode` with a store path command, and a `plugin` array.

- [ ] **Step 4: Test in an opencode session**

Start opencode and type:

```
ctx stats
```

Expected: context-mode responds with a stats table.

- [ ] **Step 5: Commit any fixups**

```bash
git add -A
git commit -m "fix(opencode): fixup context-mode wiring"
```

______________________________________________________________________

## Contingency: plugin resolution fails

If `plugin` cannot be resolved, fall back to MCP-only:

1. Remove the `plugin` entry from `programs.opencode.settings`
1. Keep only `mcp.context-mode`
1. Add a comment documenting the limitation
1. Append the content of `configs/opencode/AGENTS.md` from the context-mode tarball into the `baseContext` string in `default.nix` so the model knows to use the sandbox tools

MCP-only gives all 11 tools without automatic routing enforcement.
