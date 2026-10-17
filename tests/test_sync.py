"""Keep the small editor thumbnails distinct from the full media repository."""

import importlib.util
from pathlib import Path
import subprocess
from tempfile import TemporaryDirectory
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    "check_sync", Path(__file__).parents[1] / "scripts/check-sync.py"
)
check_sync = importlib.util.module_from_spec(spec)
spec.loader.exec_module(check_sync)


class EditorMediaBudgetTests(unittest.TestCase):
    def setUp(self):
        self.temporary = TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.git("init", "--quiet")
        (self.root / "page.typ").write_text("= Test\n")
        self.git("add", ".")
        self.git(
            "-c",
            "user.name=Test",
            "-c",
            "user.email=test@example.invalid",
            "commit",
            "--quiet",
            "-m",
            "fixture",
        )
        self.patch = patch.object(check_sync, "ROOT", self.root)
        self.patch.start()
        self.addCleanup(self.patch.stop)

    def git(self, *args):
        subprocess.run(["git", *args], cwd=self.root, check=True, capture_output=True)

    def add_file(self, name, size):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(b"x" * size)
        self.git("add", name)

    def test_small_editor_thumbnail_is_allowed(self):
        self.add_file("preview/banner.jpg", 8 * 1024)
        check_sync.main()

    def test_media_outside_preview_cache_is_rejected(self):
        self.add_file("assets/photo.jpg", 1024)
        with self.assertRaisesRegex(SystemExit, "store media in pontonnier-media"):
            check_sync.main()

    def test_video_is_not_an_editor_thumbnail(self):
        self.add_file("preview/video.mp4", 1024)
        with self.assertRaisesRegex(SystemExit, "store media in pontonnier-media"):
            check_sync.main()

    def test_individual_thumbnail_budget(self):
        self.add_file("preview/oversized.jpg", 65 * 1024)
        with self.assertRaisesRegex(SystemExit, "thumbnail exceeds 64 KiB"):
            check_sync.main()

    def test_total_thumbnail_budget(self):
        for i in range(5):
            self.add_file(f"preview/{i}.jpg", 60 * 1024)
        with self.assertRaisesRegex(SystemExit, "256 KiB total"):
            check_sync.main()

    def test_thumbnail_file_count_budget(self):
        for i in range(13):
            self.add_file(f"preview/{i}.jpg", 10)
        with self.assertRaisesRegex(SystemExit, "12 files"):
            check_sync.main()


if __name__ == "__main__":
    unittest.main()
