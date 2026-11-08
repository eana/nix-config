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
