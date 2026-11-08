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
