#!/usr/bin/env python3
"""Scan and update hardcoded version pins in Nix files."""

import argparse
import concurrent.futures
import json
import os
import re
import subprocess
import sys
import urllib.request
import urllib.error
from dataclasses import dataclass
from pathlib import Path


@dataclass
class Source:
    kind: str  # "github-release", "github-commit", "npm"
    owner: str = ""
    repo: str = ""
    package: str = ""
    current: str = ""
    file: str = ""
    line: int = 0


@dataclass
class CheckResult:
    source: Source
    latest: str = ""
    status: str = ""  # "ok", "outdated", "error"
    error: str = ""


EXCLUDES = [
    ("anomalyco", "opencode"),
]

SCAN_DIRS = ["modules", "home", "configurations", "hosts"]

HASH_RE = re.compile(r"sha256-[A-Za-z0-9+/=]+")
GITHUB_FETCH_BLOCK_RE = re.compile(r"fetchFromGitHub\s*\{[^}]*\}", re.DOTALL)
FETCHURL_BLOCK_RE = re.compile(r"fetchurl\s*\{[^}]*\}", re.DOTALL)

# fetchFromGitHub { owner = "..."; repo = "..."; rev = "..."; hash = "..."; }
GITHUB_BLOCK_RE = re.compile(
    r"fetchFromGitHub\s*\{[^}]*"
    r'owner\s*=\s*"([^"]+)"[^}]*'
    r'repo\s*=\s*"([^"]+)"[^}]*'
    r'rev\s*=\s*"([^"]+)"',
    re.DOTALL,
)

# fetchurl { url = "https://registry.npmjs.org/<pkg>/-/<pkg>-<ver>.tgz"; ... version = "..."; }
NPM_URL_RE = re.compile(
    r'registry\.npmjs\.org/([^/"]+)/-/[^"]+-(\$\{version\}|[^"]+)\.tgz'
)
NPM_VERSION_RE = re.compile(r'version\s*=\s*"([^"]+)"')
PNAME_RE = re.compile(r'pname\s*=\s*"([^"]+)"')


def _line_for_offset(text: str, offset: int) -> int:
    return text[:offset].count("\n") + 1


def _select_nearest_span(text: str, spans: list[tuple[int, int]], target_line: int) -> tuple[int, int] | None:
    if not spans:
        return None
    return min(spans, key=lambda span: abs(_line_for_offset(text, span[0]) - target_line))


def _replace_in_span(text: str, span: tuple[int, int], old: str, new: str) -> tuple[str, bool]:
    start, end = span
    chunk = text[start:end]
    if old not in chunk:
        return text, False
    chunk = chunk.replace(old, new, 1)
    return text[:start] + chunk + text[end:], True


def _github_block_spans(text: str, src: Source) -> list[tuple[int, int]]:
    spans = []
    for match in GITHUB_FETCH_BLOCK_RE.finditer(text):
        block = match.group(0)
        if f'owner = "{src.owner}"' not in block:
            continue
        if f'repo = "{src.repo}"' not in block:
            continue
        if f'rev = "{src.current}"' not in block:
            continue
        spans.append((match.start(), match.end()))
    return spans


def _npm_block_spans(text: str, _src: Source) -> list[tuple[int, int]]:
    return [match.span() for match in FETCHURL_BLOCK_RE.finditer(text)]


def _git_ls_remote(url: str, ref: str = "") -> str:
    """Run git ls-remote, return first SHA or empty string."""
    cmd = ["git", "ls-remote"]
    if ref and ref != "HEAD":
        cmd.append("--refs")
    cmd.append(url)
    if ref:
        cmd.append(ref)
    try:
        out = subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL, timeout=15)
        for line in out.splitlines():
            sha, name = line.split("\t", 1)
            return sha
    except (subprocess.CalledProcessError, ValueError):
        pass
    return ""


def _git_ls_remote_tags(url: str) -> list[str]:
    """Run git ls-remote --tags, return list of tag names sorted by version."""
    try:
        out = subprocess.check_output(
            ["git", "ls-remote", "--tags", url],
            text=True, stderr=subprocess.DEVNULL, timeout=15,
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        return []
    tags = []
    for line in out.splitlines():
        _, ref = line.split("\t", 1)
        tag = ref.removeprefix("refs/tags/").removesuffix("^{}")
        if tag and "^{}" not in ref:
            tags.append(tag)
    tags.sort(reverse=True)
    return tags


def _api_get(url: str) -> dict | list | None:
    """GET a JSON URL, return parsed response or None on error."""
    req = urllib.request.Request(url, headers={"User-Agent": "version-check/1.0"})
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read())
    except (urllib.error.URLError, urllib.error.HTTPError, json.JSONDecodeError):
        return None


def git_root() -> Path:
    out = subprocess.check_output(
        ["git", "rev-parse", "--show-toplevel"], text=True, stderr=subprocess.DEVNULL
    )
    return Path(out.strip())


def scan_file(path: Path, rel: str) -> list[Source]:
    """Extract version pins from a single .nix file."""
    text = path.read_text()
    sources = []

    for m in GITHUB_BLOCK_RE.finditer(text):
        owner, repo, rev = m.group(1), m.group(2), m.group(3)

        # Skip excludes
        if any(owner == ex[0] and repo == ex[1] for ex in EXCLUDES):
            continue

        # Skip comment-only revs
        if rev.startswith("#"):
            continue

        line = text[: m.start()].count("\n") + 1

        if re.match(r"^v[0-9]", rev) or rev.startswith("release-"):
            sources.append(Source("github-release", owner=owner, repo=repo, current=rev, file=rel, line=line))
        elif re.match(r"^[0-9a-f]{40}$", rev):
            sources.append(Source("github-commit", owner=owner, repo=repo, current=rev, file=rel, line=line))

    for m in NPM_URL_RE.finditer(text):
        package_from_url, version_from_url = m.group(1), m.group(2)

        # Handle ${pname} and ${version} Nix interpolation
        if package_from_url.startswith("${"):
            pm = PNAME_RE.search(text)
            package = pm.group(1) if pm else package_from_url
        else:
            package = package_from_url

        if version_from_url.startswith("${"):
            # version attribute is typically before the fetchurl block
            vm = NPM_VERSION_RE.search(text[max(0, m.start() - 500) : m.start()])
            version = vm.group(1) if vm else version_from_url
        else:
            version = version_from_url

        line = text[: m.start()].count("\n") + 1
        sources.append(Source("npm", package=package, current=version, file=rel, line=line))

    return sources


def check_source(src: Source) -> CheckResult:
    """Query upstream for latest version, return CheckResult."""
    url = f"https://github.com/{src.owner}/{src.repo}.git"

    if src.kind == "github-release":
        tags = _git_ls_remote_tags(url)
        if not tags:
            return CheckResult(src, status="error", error="no tags found")
        latest = tags[0]
    elif src.kind == "github-commit":
        latest = _git_ls_remote(url, "HEAD")
        if not latest:
            return CheckResult(src, status="error", error="no commits found")
    elif src.kind == "npm":
        data = _api_get(f"https://registry.npmjs.org/{src.package}/latest")
        if not data or "version" not in data:
            return CheckResult(src, status="error", error="npm lookup failed")
        latest = data["version"]
    else:
        return CheckResult(src, status="error", error=f"unknown kind: {src.kind}")

    if src.current == latest:
        return CheckResult(src, latest=latest, status="ok")

    return CheckResult(src, latest=latest, status="outdated")


def compute_hash_github(owner: str, repo: str, rev: str) -> str | None:
    """Run nix-prefetch-github, return hash or None."""
    try:
        out = subprocess.check_output(
            ["nix-prefetch-github", owner, repo, "--rev", rev, "--json"],
            text=True,
            stderr=subprocess.DEVNULL,
        )
        return json.loads(out).get("hash")
    except (subprocess.CalledProcessError, json.JSONDecodeError):
        return None


def compute_hash_npm(package: str, version: str) -> str | None:
    """Run nix-prefetch-url for npm tarball, return hash or None."""
    url = f"https://registry.npmjs.org/{package}/-/{package}-{version}.tgz"
    try:
        out = subprocess.check_output(
            ["nix-prefetch-url", "--type", "sha256", url],
            text=True,
            stderr=subprocess.DEVNULL,
        )
        return out.strip()
    except subprocess.CalledProcessError:
        return None


def update_file(repo_root: Path, result: CheckResult) -> bool:
    """Update a single source in-place. Returns True on success."""
    src = result.source
    file_path = repo_root / src.file
    text = file_path.read_text()

    # Compute new hash
    if src.kind in ("github-release", "github-commit"):
        new_hash = compute_hash_github(src.owner, src.repo, result.latest)
    elif src.kind == "npm":
        new_hash = compute_hash_npm(src.package, result.latest)
    else:
        return False

    if not new_hash:
        print(f"    Failed to compute hash for {src.owner or src.package}")
        return False

    updated = False

    # Replace rev/version/hash in targeted span
    if src.kind == "npm":
        npm_span = _select_nearest_span(text, _npm_block_spans(text, src), src.line)
        if npm_span:
            start, end = npm_span
            chunk = text[start:end]

            replaced_url = False
            if f"-{src.current}.tgz" in chunk:
                chunk = chunk.replace(f"-{src.current}.tgz", f"-{result.latest}.tgz", 1)
                replaced_url = True
            updated = updated or replaced_url

            if not replaced_url:
                version_pattern = re.compile(rf'version\s*=\s*"{re.escape(src.current)}"')
                version_spans = [m.span() for m in version_pattern.finditer(text)]
                version_span = _select_nearest_span(text, version_spans, src.line)
                if version_span:
                    text, replaced_version = _replace_in_span(
                        text,
                        version_span,
                        f'version = "{src.current}"',
                        f'version = "{result.latest}"',
                    )
                    updated = updated or replaced_version

            hash_match = HASH_RE.search(chunk)
            if hash_match:
                chunk = chunk[: hash_match.start()] + new_hash + chunk[hash_match.end() :]
                updated = True

            text = text[:start] + chunk + text[end:]
    else:
        gh_span = _select_nearest_span(text, _github_block_spans(text, src), src.line)
        if gh_span:
            start, end = gh_span
            chunk = text[start:end]

            replaced_rev = False
            if f'rev = "{src.current}"' in chunk:
                chunk = chunk.replace(f'rev = "{src.current}"', f'rev = "{result.latest}"', 1)
                replaced_rev = True
            updated = updated or replaced_rev

            hash_match = HASH_RE.search(chunk)
            if hash_match:
                chunk = chunk[: hash_match.start()] + new_hash + chunk[hash_match.end() :]
                updated = True

            text = text[:start] + chunk + text[end:]

    if not updated:
        print(f"    Failed to update target block in {src.file}:{src.line}")
        return False

    file_path.write_text(text)
    print(f"    Hash: {new_hash}")
    return True


def format_label(src: Source) -> str:
    if src.kind == "npm":
        return src.package
    return f"{src.owner}/{src.repo}"


def format_version(src: Source) -> str:
    if src.kind == "github-commit":
        return src.current[:7]
    return src.current


def format_latest(result: CheckResult) -> str:
    if result.source.kind == "github-commit":
        return result.latest[:7]
    return result.latest


def parse_args(argv: list[str] | None = None):
    parser = argparse.ArgumentParser(
        description="Scan and update hardcoded version pins in .nix files",
    )
    parser.add_argument(
        "-n", "--dry-run",
        action="store_true",
        help="Report only, don't modify files",
    )
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument(
        "--hook",
        action="store_true",
        help="Pre-push mode: update files, exit 1 if anything was updated",
    )
    mode.add_argument(
        "--check",
        action="store_true",
        help="Check-only: never write, exit 1 if any pin is outdated",
    )
    return parser.parse_args(argv)


def hook_failure(updated: int, hook_enabled: bool) -> int:
    """Exit code for pre-push hook mode: 1 if files were updated, else 0.

    Query errors never block the push — they are indistinguishable from
    offline/transient failures and are reported as WARN, not gated here.
    """
    if hook_enabled and updated:
        return 1
    return 0


def main():
    args = parse_args()
    dry = args.dry_run or args.check

    root = git_root()
    sources = []

    for dir_name in SCAN_DIRS:
        dir_path = root / dir_name
        if not dir_path.is_dir():
            continue
        for nix_file in sorted(dir_path.rglob("*.nix")):
            rel = str(nix_file.relative_to(root))
            sources.extend(scan_file(nix_file, rel))

    if not sources:
        print("No hardcoded version pins found.")
        sys.exit(0)

    print()
    with concurrent.futures.ThreadPoolExecutor(max_workers=min(16, max(1, len(sources)))) as executor:
        results = list(executor.map(check_source, sources))
    ok = outdated = errors = 0
    updated = 0

    rows = []
    for r in results:
        if r.status == "ok":
            arrow = f"{format_version(r.source)} == {format_latest(r)}"
        elif r.status == "error":
            arrow = r.error
        else:
            arrow = f"{format_version(r.source)} -> {format_latest(r)}"
        rows.append((r, arrow))

    status_w = max(len(r.status) for r in results)
    arrow_w = max(len(arrow) for _, arrow in rows)

    for r, arrow in rows:
        loc = f"{r.source.file}:{r.source.line}"
        print(f"  {r.status.upper():<{status_w}s}  {arrow:<{arrow_w}s}  {loc}")

        if r.status == "ok":
            ok += 1
        elif r.status == "error":
            errors += 1
        elif r.status == "outdated":
            outdated += 1

            if not dry:
                label = format_label(r.source)
                cur, lat = format_version(r.source), format_latest(r)
                print(f"    Updating {label}: {cur} -> {lat}")
                if update_file(root, r):
                    updated += 1

    print()
    print(f"Summary: {ok} OK, {outdated} outdated, {errors} errors")
    if dry and outdated:
        print(f"(dry run — {outdated} would be updated)")
    if errors and not dry:
        print(f"(note: {errors} query errors reported — commit not blocked)")
    if args.check and outdated:
        sys.exit(1)
    sys.exit(hook_failure(updated, args.hook))


if __name__ == "__main__":
    main()
