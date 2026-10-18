"""Cover choices and derived media counts must agree in both Typst modes."""

import os
import json
from html.parser import HTMLParser
from pathlib import Path
import shutil
import subprocess
from tempfile import TemporaryDirectory
import unittest

ROOT = Path(__file__).resolve().parents[1]
COMPILER = os.environ.get("TYPST", "typst")


class CoverImages(HTMLParser):
    def __init__(self, html):
        super().__init__()
        self.images = []
        self.feed(html)

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "img" and attrs.get("alt") == "Couverture de l’album":
            self.images.append(attrs)


@unittest.skipUnless(shutil.which(COMPILER), "Typst CLI is required")
class AlbumTests(unittest.TestCase):
    def compile(self, mode, cover="rame.jpg"):
        with TemporaryDirectory() as directory:
            output = Path(directory) / "album.html"
            result = subprocess.run(
                [COMPILER, "compile", "--root", str(ROOT), "--features", "html",
                 "--format", "html", "--input", f"media={mode}",
                 "--input", f"test-cover={cover}", str(ROOT / "tests/albums.typ"), str(output)],
                capture_output=True, text=True,
            )
            return result, output.read_text() if output.exists() else ""

    def test_selected_and_fallback_covers_in_both_modes(self):
        for mode in ("preview", "full"):
            for cover in ("rame.jpg", "lac.jpg"):
                with self.subTest(mode=mode, cover=cover):
                    result, html = self.compile(mode, cover)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertNotIn("else {", html)
                    if mode == "full":
                        images = CoverImages(html).images
                        self.assertEqual(images[0]["data-media-file"], cover)
                        self.assertEqual(images[1]["data-media-file"], "rhone.jpg")
                        inventory = json.loads((ROOT / "assets/manifest.json").read_text())
                        selected = next(item for item in inventory if item["path"] == f"assets/{cover}")
                        self.assertTrue(images[0]["src"].endswith("/" + selected["thumbnail"]))
                        self.assertIn('class="album-cover"', html)
                    else:
                        self.assertNotIn('class="album-cover"', html)
                        self.assertNotIn("<video", html)

    def test_unknown_cover_fails_with_an_editable_path_error(self):
        result, _ = self.compile("full", "missing-photo.jpg")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Album cover is not a known image: missing-photo.jpg", result.stderr)


if __name__ == "__main__":
    unittest.main()
