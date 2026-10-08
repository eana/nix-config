#!/usr/bin/env python3
"""
repo-wiki-index: build a semantic index of a git repository.

Walks git-tracked text files, chunks them by AST (when a tree-sitter
grammar is available) or by file (for Nix/Terraform), embeds each chunk
via Ollama, and writes .wiki-cache/.

Incremental: only re-embeds chunks whose content hash changed.

Environment:
  OLLAMA_URL              default http://localhost:11434
  REPO_WIKI_EMBED_MODEL   default qwen3-embedding:0.6b
  REPO_WIKI_MANIFESTS     comma-separated extra manifest filenames,
                          added to the defaults used for unit detection
"""

import argparse
import hashlib
import json
import os
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

import numpy as np
import requests

# ---------- configuration ----------

OLLAMA_URL = os.environ.get("OLLAMA_URL", "http://localhost:11434")
EMBED_MODEL = os.environ.get("REPO_WIKI_EMBED_MODEL", "qwen3-embedding:0.6b")
CACHE_DIR = Path(".wiki-cache")
BATCH_SIZE = 32          # chunks per /api/embed request
MAX_CHUNK_CHARS = 8000   # ~2K tokens, well within 32K context
MIN_CHUNK_CHARS = 40     # skip tiny chunks

# Extensions we treat as text and index.
TEXT_EXTS = {
    ".py", ".go", ".rs", ".ts", ".tsx", ".js", ".jsx",
    ".nix", ".tf", ".hcl",
    ".md", ".mdx", ".rst",
    ".yaml", ".yml", ".toml", ".json",
    ".sh", ".bash", ".zsh",
    ".c", ".h", ".cpp", ".hpp",
    ".java", ".kt", ".scala",
    ".rb", ".php", ".lua", ".ex", ".exs",
}

# Extensions chunked at file level (already small, structured units).
FILE_LEVEL_EXTS = {".nix", ".tf", ".hcl"}

# Tree-sitter language mapping (ext -> language name).
TREE_SITTER_LANGS = {
    ".py": "python",
    ".go": "go",
    ".rs": "rust",
    ".ts": "typescript", ".tsx": "tsx",
    ".js": "javascript", ".jsx": "javascript",
    ".c": "c", ".h": "c",
    ".cpp": "cpp", ".hpp": "cpp",
}


@dataclass
class Chunk:
    unit: str          # unit name from Phase 1 detection
    file: str          # path relative to repo root
    start_line: int
    end_line: int
    content_hash: str  # sha256 of chunk text
    text: str          # the chunk text (kept out of index.json; see below)


# ---------- git + file walking ----------

def git_tracked_files() -> list[str]:
    out = subprocess.check_output(["git", "ls-files"], text=True)
    return [line for line in out.splitlines() if line]


def is_binary(path: Path) -> bool:
    try:
        chunk = path.read_bytes()[:8192]
    except OSError:
        return True
    return b"\x00" in chunk


# ---------- unit detection (mirrors Phase 1) ----------

# Manifest filenames that mark a directory as a self-contained unit.
# Any repo can extend this list via REPO_WIKI_MANIFESTS without editing
# this file (comma-separated, e.g. "BUILD.bazel,plugin.yaml").
MANIFESTS = [
    "go.mod",
    "package.json",
    "Cargo.toml",
    "pyproject.toml",
    "flake.nix",
    ".csproj",
    "SKILL.md",
]
_extra_manifests = os.environ.get("REPO_WIKI_MANIFESTS", "")
if _extra_manifests:
    MANIFESTS.extend(m.strip() for m in _extra_manifests.split(",") if m.strip())

CONVENTIONAL_ROOTS = ["services", "packages", "apps", "libs", "cmd"]


def detect_units(files: list[str]) -> dict[str, list[str]]:
    """Return {unit_name: [file paths]}. Unit name is a directory path."""
    units: dict[str, list[str]] = {}

    for f in files:
        p = Path(f)
        # Walk up from the file to find the nearest manifest directory.
        for parent in [p.parent, *p.parent.parents]:
            if parent == Path("."):
                # Root not treated as manifest dir. continue (not break) so
                # the for-else below runs when no manifest was found; break
                # would skip the else and silently drop the file.
                continue
            for m in MANIFESTS:
                if (parent / m).exists():
                    units.setdefault(str(parent), []).append(f)
                    break
            else:
                continue
            break
        else:
            # Fall back: top-level dir, or conventional root child.
            parts = p.parts
            if len(parts) > 1:
                if parts[0] in CONVENTIONAL_ROOTS and len(parts) > 2:
                    units.setdefault(f"{parts[0]}/{parts[1]}", []).append(f)
                else:
                    units.setdefault(parts[0], []).append(f)
            else:
                units.setdefault(".", []).append(f)

    return units


# ---------- chunking ----------

def chunk_file(path: Path, unit: str) -> list[Chunk]:
    ext = path.suffix
    text = path.read_text(errors="replace")
    lines = text.splitlines()

    if ext in FILE_LEVEL_EXTS:
        return [_make_chunk(unit, str(path), 1, len(lines), text)]

    # Try tree-sitter if available for this language.
    lang_name = TREE_SITTER_LANGS.get(ext)
    if lang_name:
        try:
            return _chunk_with_tree_sitter(path, unit, lang_name, text, lines)
        except Exception as e:
            print(f"  tree-sitter failed for {path}: {e}; falling back",
                  file=sys.stderr)

    # Fallback: line-based with overlap.
    return _chunk_by_lines(unit, str(path), lines)


def _make_chunk(unit, file, start, end, text) -> Chunk:
    h = hashlib.sha256(text.encode()).hexdigest()[:16]
    return Chunk(unit=unit, file=file, start_line=start, end_line=end,
                 content_hash=h, text=text)


def _chunk_by_lines(unit, file, lines, window=200, overlap=40):
    chunks = []
    i = 0
    while i < len(lines):
        end = min(i + window, len(lines))
        body = "\n".join(lines[i:end])
        if len(body) >= MIN_CHUNK_CHARS:
            chunks.append(_make_chunk(unit, file, i + 1, end, body))
        if end == len(lines):
            break
        i = end - overlap
    return chunks


def _chunk_with_tree_sitter(path, unit, lang_name, text, lines):
    """Split at top-level function/class boundaries."""
    from tree_sitter import Parser
    from tree_sitter_language_pack import get_language

    try:
        lang = get_language(lang_name)
    except Exception:
        # Fall back to line chunking if grammar isn't installed.
        return _chunk_by_lines(unit, str(path), lines)

    parser = Parser(lang)
    tree = parser.parse(text.encode())
    root = tree.root_node

    # Collect top-level definitions and group adjacent small ones.
    boundaries: list[tuple[int, int]] = []
    for node in root.children:
        if node.type in ("function_definition", "function_declaration",
                         "class_definition", "class_declaration",
                         "method_definition", "impl_item", "struct_item",
                         "enum_item", "trait_item"):
            boundaries.append((node.start_point[0], node.end_point[0]))

    if not boundaries:
        return _chunk_by_lines(unit, str(path), lines)

    chunks = []
    cur_start, cur_end = boundaries[0]
    for s, e in boundaries[1:]:
        if e - cur_start > 150:  # flush if chunk would get too big
            body = "\n".join(lines[cur_start:cur_end + 1])
            chunks.append(_make_chunk(unit, str(path), cur_start + 1,
                                      cur_end + 1, body))
            cur_start, cur_end = s, e
        else:
            cur_end = e
    body = "\n".join(lines[cur_start:cur_end + 1])
    chunks.append(_make_chunk(unit, str(path), cur_start + 1,
                              cur_end + 1, body))
    return chunks


# ---------- embedding ----------

def embed_batch(texts: list[str]) -> np.ndarray:
    """Embed texts via Ollama's /api/embed. Returns (N, D) float32 array."""
    resp = requests.post(
        f"{OLLAMA_URL}/api/embed",
        json={"model": EMBED_MODEL, "input": texts},
        timeout=300,
    )
    resp.raise_for_status()
    data = resp.json()
    if "embeddings" not in data:
        raise RuntimeError(f"unexpected Ollama response: {list(data.keys())}")
    return np.array(data["embeddings"], dtype=np.float32)


# ---------- incremental index ----------

def load_previous_index() -> dict[str, np.ndarray]:
    """Return {content_hash: vector} from an existing index, or {}."""
    idx_path = CACHE_DIR / "index.json"
    vec_path = CACHE_DIR / "vectors.bin"
    if not idx_path.exists() or not vec_path.exists():
        return {}

    index = json.loads(idx_path.read_text())
    chunks = index.get("chunks", [])
    dim = int(index.get("dim", 0))
    if not chunks or dim == 0:
        return {}

    vecs = np.fromfile(vec_path, dtype=np.float32).reshape(len(chunks), dim)
    return {c["content_hash"]: vecs[i] for i, c in enumerate(chunks)}


def build_index(units: dict[str, list[str]]):
    CACHE_DIR.mkdir(parents=True, exist_ok=True)

    prev = load_previous_index()
    print(f"loaded {len(prev)} cached vectors")

    all_chunks: list[Chunk] = []
    for unit, files in units.items():
        for f in files:
            p = Path(f)
            if p.suffix not in TEXT_EXTS:
                continue
            if is_binary(p):
                continue
            try:
                all_chunks.extend(chunk_file(p, unit))
            except Exception as e:
                print(f"  skipping {f}: {e}", file=sys.stderr)

    print(f"total chunks: {len(all_chunks)}")

    # Split into cached vs new.
    cached_vectors, cached_meta = [], []
    new_chunks = []
    for c in all_chunks:
        if c.content_hash in prev:
            cached_vectors.append(prev[c.content_hash])
            cached_meta.append(c)
        else:
            new_chunks.append(c)

    print(f"reusing {len(cached_meta)} cached, embedding {len(new_chunks)} new")

    # Embed new chunks in batches.
    new_vectors = []
    for i in range(0, len(new_chunks), BATCH_SIZE):
        batch = new_chunks[i:i + BATCH_SIZE]
        texts = [c.text[:MAX_CHUNK_CHARS] for c in batch]
        vecs = embed_batch(texts)
        new_vectors.append(vecs)
        print(f"  embedded {i + len(batch)}/{len(new_chunks)}")

    # Assemble final ordering: cached first, then new.
    all_meta = cached_meta + new_chunks

    parts = []
    if cached_vectors:
        parts.append(np.stack(cached_vectors))
    if new_vectors:
        parts.append(np.vstack(new_vectors))
    if parts:
        all_vecs = np.vstack(parts)
    else:
        all_vecs = np.zeros((0, 0), dtype=np.float32)

    # Write index.json (metadata only, no text).
    dim = int(all_vecs.shape[1]) if all_vecs.size else 0
    index = {
        "model": EMBED_MODEL,
        "dim": dim,
        "chunks": [
            {
                "unit": c.unit,
                "file": c.file,
                "start_line": c.start_line,
                "end_line": c.end_line,
                "content_hash": c.content_hash,
            }
            for c in all_meta
        ],
    }
    (CACHE_DIR / "index.json").write_text(json.dumps(index, indent=2))

    # Write vectors.bin (raw float32, row-major).
    all_vecs.tofile(CACHE_DIR / "vectors.bin")

    # Write manifest.json.
    head = subprocess.check_output(
        ["git", "rev-parse", "HEAD"], text=True
    ).strip()
    manifest = {
        "indexed_commit": head,
        "model": EMBED_MODEL,
        "dim": dim,
        "chunk_count": len(all_meta),
        "manifests": MANIFESTS,
    }
    (CACHE_DIR / "manifest.json").write_text(json.dumps(manifest, indent=2))

    print(f"wrote {len(all_meta)} chunks to {CACHE_DIR}/")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", default=".", help="repository root")
    args = ap.parse_args()
    os.chdir(args.repo)

    files = git_tracked_files()
    print(f"tracked files: {len(files)}")

    units = detect_units(files)
    print(f"units detected: {len(units)}")
    top = sorted(units.items(), key=lambda kv: -len(kv[1]))[:10]
    for u, fs in top:
        print(f"  {u}: {len(fs)} files")

    build_index(units)


if __name__ == "__main__":
    main()
