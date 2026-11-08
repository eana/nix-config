import importlib.util
import os
import unittest
from pathlib import Path

INDEX_PY = Path(os.environ["REPO_WIKI_INDEX"])


def load_index_module():
    spec = importlib.util.spec_from_file_location("repo_wiki_index", INDEX_PY)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


class BackendDefaults(unittest.TestCase):
    def test_default_backend_is_ollama(self):
        os.environ.pop("REPO_WIKI_EMBED_BACKEND", None)
        mod = load_index_module()
        self.assertEqual(mod.EMBED_BACKEND, "ollama")


from unittest import mock


class TunableDefaults(unittest.TestCase):
    def test_defaults(self):
        for var in ("REPO_WIKI_BATCH_SIZE", "REPO_WIKI_MAX_RETRIES", "REPO_WIKI_BATCH_DELAY"):
            os.environ.pop(var, None)
        mod = load_index_module()
        self.assertEqual(mod.BATCH_SIZE, 8)
        self.assertEqual(mod.MAX_RETRIES, 5)
        self.assertEqual(mod.EMBED_BATCH_DELAY, 6)

    def test_env_overrides(self):
        with mock.patch.dict(os.environ, {
            "REPO_WIKI_BATCH_SIZE": "4",
            "REPO_WIKI_MAX_RETRIES": "2",
            "REPO_WIKI_BATCH_DELAY": "1.5",
        }):
            mod = load_index_module()
        self.assertEqual(mod.BATCH_SIZE, 4)
        self.assertEqual(mod.MAX_RETRIES, 2)
        self.assertEqual(mod.EMBED_BATCH_DELAY, 1.5)


import numpy as np


class GeminiIndexTests(unittest.TestCase):
    def setUp(self):
        self.env = mock.patch.dict(os.environ, {
            "REPO_WIKI_EMBED_BACKEND": "gemini",
            "REPO_WIKI_EMBED_MODEL": "gemini-embedding-2",
            "GEMINI_API_KEY": "test-key",
        })
        self.env.start()
        self.addCleanup(self.env.stop)

    def test_gemini_batch_request_shape(self):
        mod = load_index_module()
        captured = {}

        class Resp:
            status_code = 200

            def raise_for_status(self):
                pass

            def json(self):
                return {"embeddings": [{"values": [0.1, 0.2]}, {"values": [0.3, 0.4]}]}

        def fake_post(url, json=None, headers=None, timeout=None):
            captured.update(url=url, json=json, headers=headers)
            return Resp()

        with mock.patch.object(mod.requests, "post", fake_post):
            out = mod.embed_batch(["alpha", "beta"])

        self.assertEqual(out.shape, (2, 2))
        self.assertTrue(captured["url"].endswith(":batchEmbedContents"))
        self.assertEqual(captured["headers"]["x-goog-api-key"], "test-key")
        reqs = captured["json"]["requests"]
        self.assertEqual([r["content"]["parts"][0]["text"] for r in reqs], ["alpha", "beta"])
        self.assertEqual(reqs[0]["taskType"], "RETRIEVAL_DOCUMENT")
        self.assertEqual(reqs[0]["model"], "models/gemini-embedding-2")

    def test_gemini_missing_key_raises(self):
        os.environ.pop("GEMINI_API_KEY")
        mod = load_index_module()
        with self.assertRaises(RuntimeError):
            mod.embed_batch(["alpha"])

    def test_gemini_retries_on_429_then_succeeds(self):
        mod = load_index_module()

        class RateLimited:
            status_code = 429
            headers = {}

            def raise_for_status(self):
                raise mod.requests.HTTPError("429")

        class Ok:
            status_code = 200

            def raise_for_status(self):
                pass

            def json(self):
                return {"embeddings": [{"values": [0.1, 0.2]}]}

        responses = iter([RateLimited(), RateLimited(), Ok()])

        def fake_post(url, json=None, headers=None, timeout=None):
            return next(responses)

        with mock.patch.object(mod.requests, "post", fake_post), \
             mock.patch.object(mod.time, "sleep"):
            out = mod.embed_batch(["alpha"])

        self.assertEqual(out.shape, (1, 2))

    def test_gemini_gives_up_after_max_retries(self):
        mod = load_index_module()

        class RateLimited:
            status_code = 429
            headers = {}

            def raise_for_status(self):
                raise mod.requests.HTTPError("429")

        def fake_post(url, json=None, headers=None, timeout=None):
            return RateLimited()

        with mock.patch.object(mod.requests, "post", fake_post), \
             mock.patch.object(mod.time, "sleep"):
            with self.assertRaises(mod.requests.HTTPError):
                mod.embed_batch(["alpha"])


import json
import tempfile


class CacheValidationTests(unittest.TestCase):
    def _write_cache(self, cache, backend, model):
        (cache / "index.json").write_text(json.dumps({
            "backend": backend, "model": model, "dim": 2,
            "chunks": [{"unit": "u", "file": "f", "start_line": 1,
                        "end_line": 1, "content_hash": "h"}],
        }))
        np.array([[1.0, 0.0]], dtype=np.float32).tofile(cache / "vectors.bin")

    def test_cache_rejected_on_model_mismatch(self):
        with mock.patch.dict(os.environ, {
            "REPO_WIKI_EMBED_BACKEND": "gemini",
            "REPO_WIKI_EMBED_MODEL": "new-model",
            "GEMINI_API_KEY": "test-key",
        }):
            mod = load_index_module()
            with tempfile.TemporaryDirectory() as tmp:
                cache = Path(tmp)
                self._write_cache(cache, "gemini", "old-model")
                mod.CACHE_DIR = cache
                self.assertEqual(mod.load_previous_index(), {})

    def test_cache_rejected_on_backend_mismatch(self):
        with mock.patch.dict(os.environ, {
            "REPO_WIKI_EMBED_BACKEND": "gemini",
            "REPO_WIKI_EMBED_MODEL": "gemini-embedding-2",
            "GEMINI_API_KEY": "test-key",
        }):
            mod = load_index_module()
            with tempfile.TemporaryDirectory() as tmp:
                cache = Path(tmp)
                self._write_cache(cache, "ollama", "gemini-embedding-2")
                mod.CACHE_DIR = cache
                self.assertEqual(mod.load_previous_index(), {})


QUERY_PY = Path(os.environ["REPO_WIKI_QUERY"])


def load_query_module():
    spec = importlib.util.spec_from_file_location("repo_wiki_query", QUERY_PY)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


class GeminiQueryTests(unittest.TestCase):
    def test_max_retries_env_override(self):
        os.environ.pop("GEMINI_API_KEY", None)
        with mock.patch.dict(os.environ, {"REPO_WIKI_MAX_RETRIES": "2"}):
            mod = load_query_module()
        self.assertEqual(mod.MAX_RETRIES, 2)

    def test_gemini_query_request_shape(self):
        with mock.patch.dict(os.environ, {"GEMINI_API_KEY": "test-key"}):
            mod = load_query_module()
            captured = {}

            class Resp:
                status_code = 200

                def raise_for_status(self):
                    pass

                def json(self):
                    return {"embedding": {"values": [0.1, 0.2]}}

            def fake_post(url, json=None, headers=None, timeout=None):
                captured.update(url=url, json=json, headers=headers)
                return Resp()

            with mock.patch.object(mod.requests, "post", fake_post):
                out = mod.embed_query("purpose", "gemini-embedding-2", "gemini")

        self.assertEqual(out.tolist(), [0.1, 0.2])
        self.assertTrue(captured["url"].endswith(":embedContent"))
        self.assertEqual(captured["headers"]["x-goog-api-key"], "test-key")
        self.assertEqual(captured["json"]["taskType"], "RETRIEVAL_QUERY")
        self.assertEqual(captured["json"]["content"]["parts"][0]["text"], "purpose")
