import contextlib
import json
import os
import portalocker  # ← নতুন import

class JsonFileStore(MemoryStore):
    """Persistent with cross-process locking. Works on Windows/macOS/Linux."""

    def __init__(self, path: str):
        self.path = path
        self._data: dict = {}
        os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
        if os.path.exists(path):
            with open(path, "r", encoding="utf-8") as f:
                self._data = json.load(f)

    @contextlib.contextmanager
    def _locked(self):
        lock_path = self.path + ".lock"
        with portalocker.Lock(lock_path, mode="w", timeout=10):
            # re-read under lock to avoid stale data
            if os.path.exists(self.path):
                with open(self.path, "r", encoding="utf-8") as f:
                    self._data = json.load(f)
            yield
            with open(self.path, "w", encoding="utf-8") as f:
                json.dump(self._data, f, indent=2)

    def get(self, namespace, key):
        return self._data.get(namespace, {}).get(key)

    def put(self, namespace, key, value):
        with self._locked():
            self._data.setdefault(namespace, {})[key] = value

    def dump(self, namespace):
        return dict(self._data.get(namespace, {}))
