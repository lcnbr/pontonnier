"""The gallery loads small mosaics and links to unchanged, version-pinned originals."""

from html.parser import HTMLParser
import json
import os
from pathlib import Path
import shutil
import subprocess
from tempfile import TemporaryDirectory
import unittest

ROOT = Path(__file__).resolve().parents[1]
COMPILER = os.environ.get("TYPST", "typst")


class PhotoHTML(HTMLParser):
    def __init__(self, html):
        super().__init__()
        self.images = []
        self.links = []
        self.feed(html)

    def handle_starttag(self, tag, attrs):
        if tag == "img":
            self.images.append(dict(attrs))
        if tag == "a":
            self.links.append(dict(attrs))


@unittest.skipUnless(shutil.which(COMPILER), "Typst CLI is required")
class OriginalMediaTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.manifest = json.loads((ROOT / "assets/manifest.json").read_text())
        cls.by_path = {entry["path"]: entry for entry in cls.manifest}
        cls.original = next(entry for entry in cls.manifest if "original" in entry)
        cls.unchanged = next(entry for entry in cls.manifest
                             if "thumbnail" in entry and "original" not in entry)
        cls.revision = (ROOT / ".media-revision").read_text().strip()

    def compile(self, entry, mode="full", base="/pontonnier/", **inputs):
        with TemporaryDirectory() as directory:
            output = Path(directory) / "photo.html"
            command = [COMPILER, "compile", "--root", str(ROOT), "--features", "html",
                       "--format", "html", "--input", f"media={mode}",
                       "--input", f"base-path={base}", "--input",
                       "test-photo=" + entry["path"].removeprefix("assets/")]
            for key, value in inputs.items():
                command.extend(["--input", key.replace("_", "-") + "=" + value])
            result = subprocess.run(command + [str(ROOT / "tests/media.typ"), str(output)],
                                    capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            return PhotoHTML(output.read_text())

    def test_original_and_mosaic_have_independent_urls_under_both_base_paths(self):
        for base in ("/", "/pontonnier/"):
            with self.subTest(base=base):
                photo = self.compile(self.original, base=base)
                self.assertEqual(photo.images[0]["src"], base + self.original["thumbnail"])
                original = self.original["original"]
                self.assertEqual(photo.links[0]["href"],
                                 f"https://raw.githubusercontent.com/lcnbr/pontonnier-media/{self.revision}/{original['path']}")
                small = self.by_path[self.original["thumbnail"]]
                self.assertEqual(int(photo.images[0]["width"]), small["width"])
                self.assertEqual(int(photo.images[0]["height"]), small["height"])

    def test_already_original_files_keep_their_local_full_size_link(self):
        photo = self.compile(self.unchanged)
        self.assertEqual(photo.links[0]["href"], "/pontonnier/" + self.unchanged["path"])
        self.assertEqual(photo.images[0]["src"], "/pontonnier/" + self.unchanged["thumbnail"])

    def test_article_pictures_keep_their_existing_web_resolution(self):
        photo = self.compile(self.original, test_kind="picture")
        self.assertEqual(photo.images[0]["src"], "/pontonnier/" + self.original["path"])

    def test_authored_link_destinations_are_preserved(self):
        photo = self.compile(self.original, test_destination="/pontonnier/sport/")
        self.assertEqual(photo.links[0]["href"], "/pontonnier/sport/")

    def test_editor_still_uses_only_its_small_embedded_preview(self):
        entry = next(entry for entry in self.manifest if entry["path"] == "assets/rhone.jpg")
        photo = self.compile(entry, mode="preview")
        self.assertTrue(photo.images[0]["src"].startswith("data:image/"))

    def test_mosaic_derivatives_are_small_and_original_metadata_is_consistent(self):
        for entry in self.manifest:
            if "thumbnail" not in entry:
                continue
            small = self.by_path[entry["thumbnail"]]
            digest = entry.get("original", entry)["sha256"]
            self.assertIn(digest[:32], entry["thumbnail"])
            self.assertLessEqual(small["bytes"], 128 * 1024, entry["path"])
            self.assertLessEqual(max(small["width"], small["height"]), 960, entry["path"])
            if "original" in entry:
                original = entry["original"]
                self.assertGreaterEqual(original["width"] * original["height"], entry["width"] * entry["height"], entry["path"])
                self.assertIn(original["sha256"], original["path"])
                self.assertNotEqual(entry["thumbnail"], original["path"])


if __name__ == "__main__":
    unittest.main()
