#!/usr/bin/env python3
"""
repo-wiki-query: retrieve relevant chunks from a .wiki-cache/ index.

Loads the embedding index built by repo-wiki-index, embeds the query
with the same model recorded in the index, and returns the top-K most
similar chunks with their source text read from disk.

The index directory defaults to .wiki-cache/ but can be overridden with
--cache-dir, which is useful when keeping multiple indexes around (one
per embedding model, for example).

Exit codes:
  0  success
  1  no index / empty index
  2  embedding failure
"""

import argparse
import json
import os
import sys
from pathlib import Path

import numpy as np
import requests

OLLAMA_URL = os.environ.get("OLLAMA_URL", "http://localhost:11434")
DEFAULT_CACHE_DIR = ".wiki-cache"
DEFAULT_TOP_K = 10
DEFAULT_MAX_CHARS = 2000


def load_index(cache_dir: Path):
    idx_path = cache_dir / "index.json"
    vec_path = cache_dir / "vectors.bin"
    if not idx_path.exists() or not vec_path.exists():
        sys.exit(f"no index found in {cache_dir}; run repo-wiki-index first")

    index = json.loads(idx_path.read_text())
    chunks = index.get("chunks", [])
    dim = int(index.get("dim", 0))
    if not chunks or dim == 0:
        sys.exit(f"index in {cache_dir} is empty; run repo-wiki-index first")

    vecs = np.fromfile(vec_path, dtype=np.float32).reshape(len(chunks), dim)
    return index, chunks, vecs


def embed_query(query: str, model: str) -> np.ndarray:
    try:
        resp = requests.post(
            f"{OLLAMA_URL}/api/embed",
            json={"model": model, "input": [query]},
            timeout=60,
        )
        resp.raise_for_status()
    except requests.RequestException as e:
        sys.exit(f"embedding failed: {e}")
    data = resp.json()
    if "embeddings" not in data or not data["embeddings"]:
        sys.exit(f"unexpected Ollama response: {list(data.keys())}")
    return np.array(data["embeddings"][0], dtype=np.float32)


def read_chunk(chunk: dict, max_chars: int) -> str:
    p = Path(chunk["file"])
    if not p.exists():
        return f"<file missing: {chunk['file']}>"
    lines = p.read_text(errors="replace").splitlines()
    start = max(0, chunk["start_line"] - 1)
    end = min(len(lines), chunk["end_line"])
    text = "\n".join(lines[start:end])
    if len(text) > max_chars:
        omitted = len(text) - max_chars
        text = text[:max_chars] + f"\n... [truncated, {omitted} chars omitted]"
    return text


def cmd_list_units(chunks: list[dict]):
    counts: dict[str, int] = {}
    for c in chunks:
        counts[c["unit"]] = counts.get(c["unit"], 0) + 1
    if not counts:
        print("(no units)")
        return
    width = max(len(u) for u in counts)
    for unit, n in sorted(counts.items(), key=lambda kv: (-kv[1], kv[0])):
        print(f"{n:5d}  {unit.ljust(width)}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("query", nargs="?", help="natural-language query")
    ap.add_argument("--unit", help="restrict to chunks whose unit contains this substring")
    ap.add_argument("--path", help="restrict to chunks whose file path contains this substring")
    ap.add_argument("--top-k", type=int, default=DEFAULT_TOP_K)
    ap.add_argument("--max-chars", type=int, default=DEFAULT_MAX_CHARS,
                    help="cap on chunk text length in output")
    ap.add_argument("--json", action="store_true", help="emit JSON instead of text")
    ap.add_argument("--files-only", action="store_true",
                    help="print unique file paths only (no chunk text)")
    ap.add_argument("--list-units", action="store_true",
                    help="list all units in the index with chunk counts")
    ap.add_argument("--cache-dir", default=DEFAULT_CACHE_DIR,
                    help=f"index directory (default: {DEFAULT_CACHE_DIR})")
    ap.add_argument("--repo", default=".",
                    help="repository root to run against (default: cwd)")
    args = ap.parse_args()

    os.chdir(args.repo)
    cache_dir = Path(args.cache_dir)

    # --list-units short-circuits everything else. No query needed.
    if args.list_units:
        _, chunks, _ = load_index(cache_dir)
        cmd_list_units(chunks)
        return

    if not args.query:
        ap.error("query is required unless --list-units is given")

    index, chunks, vecs = load_index(cache_dir)
    model = index["model"]
    print(f"# cache={cache_dir} model={model} chunks={len(chunks)}",
          file=sys.stderr)

    q = embed_query(args.query, model)

    # Cosine similarity. Guard against zero norms.
    vec_norms = np.linalg.norm(vecs, axis=1, keepdims=True)
    vec_norms[vec_norms == 0] = 1.0
    q_norm = np.linalg.norm(q)
    if q_norm == 0:
        sys.exit("query embedding has zero norm")
    vecs_n = vecs / vec_norms
    q_n = q / q_norm

    scores = vecs_n @ q_n

    if args.unit or args.path:
        mask = np.ones(len(chunks), dtype=bool)
        if args.unit:
            mask &= np.array([args.unit in c["unit"] for c in chunks])
        if args.path:
            mask &= np.array([args.path in c["file"] for c in chunks])
        if not mask.any():
            sys.exit("no chunks match the given filters")
        scores = np.where(mask, scores, -np.inf)

    top_idx = np.argsort(-scores)[: args.top_k]

    if args.files_only:
        seen = set()
        for i in top_idx:
            if not np.isfinite(scores[i]):
                continue
            f = chunks[i]["file"]
            if f not in seen:
                seen.add(f)
                print(f)
        return

    results = []
    for i in top_idx:
        if not np.isfinite(scores[i]):
            continue
        c = chunks[i]
        results.append({
            "score": float(scores[i]),
            "unit": c["unit"],
            "file": c["file"],
            "start_line": c["start_line"],
            "end_line": c["end_line"],
            "text": read_chunk(c, args.max_chars),
        })

    if args.json:
        print(json.dumps(results, indent=2))
        return

    for n, r in enumerate(results, 1):
        header = (
            f"=== [{n}] {r['file']}:{r['start_line']}-{r['end_line']}  "
            f"(unit: {r['unit']}, score: {r['score']:.3f}) ==="
        )
        print(header)
        print(r["text"])
        print()


if __name__ == "__main__":
    main()
