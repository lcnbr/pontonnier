"""Regression cases for the site's published links and shared media."""

import importlib.util
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

spec = importlib.util.spec_from_file_location(
    "site_check", Path(__file__).parents[1] / "scripts/check.py"
)
site_check = importlib.util.module_from_spec(spec)
spec.loader.exec_module(site_check)


class PublishedSiteTests(unittest.TestCase):
    def setUp(self):
        self.temporary = TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)

    def check_page(self, body, base="/pontonnier/"):
        path = self.root / "index.html"
        path.write_text(
            '<html lang="fr"><meta name="viewport" content="width=device-width">'
            '<main id="content"><h1>Archive</h1>' + body + "</main></html>"
        )
        page = site_check.Page(path)
        return page.check({path: page}, self.root, base)

    def test_original_page_and_asset_links_are_rejected(self):
        for url in (
            "https://www.pontonniers-geneve.ch/galerie/images-2025/",
            "//pontonniers-geneve.ch/wp-content/uploads/photo.jpg",
            "https://pontonniers.files.wordpress.com/2016/11/genavaiii.pdf",
        ):
            with self.subTest(url=url):
                errors = self.check_page(f'<a href="{url}">Archive</a>')
                self.assertTrue(
                    any("original-site dependency" in error for error in errors)
                )

    def test_original_media_sources_are_rejected(self):
        for attribute in ("src", "poster", "srcset"):
            with self.subTest(attribute=attribute):
                errors = self.check_page(
                    f'<video {attribute}="https://www.pontonniers-geneve.ch/video.mp4"></video>'
                )
                self.assertTrue(
                    any("original-site dependency" in error for error in errors)
                )

    def test_missing_video_and_pdf_are_rejected(self):
        errors = self.check_page(
            '<video src="/pontonnier/assets/video.mp4"></video>'
            '<a href="/pontonnier/assets/guide.pdf">Guide</a>'
        )
        self.assertEqual(sum("broken link" in error for error in errors), 2)

    def test_shared_media_and_event_anchor_work_under_both_base_paths(self):
        (self.root / "assets").mkdir()
        (self.root / "assets/photo.jpg").write_bytes(b"test image")
        for base in ("/", "/pontonnier/"):
            with self.subTest(base=base):
                errors = self.check_page(
                    f'<a href="{base}#event">Event</a><span id="event"></span>'
                    f'<img src="{base}assets/photo.jpg" alt="Event photograph">',
                    base,
                )
                self.assertEqual(errors, [])

    def test_missing_anchor_and_base_path_escape_are_rejected(self):
        errors = self.check_page(
            '<a href="#missing">Missing</a><img src="/assets/photo.jpg" alt="Photo">'
        )
        self.assertTrue(any("missing anchor" in error for error in errors))
        self.assertTrue(any("escapes base path" in error for error in errors))

    def test_live_rhonometre_and_external_sources_remain_allowed(self):
        errors = self.check_page(
            '<iframe src="https://rhonometre.pontonniers-geneve.ch/"></iframe>'
            '<a href="https://www.hydrodaten.admin.ch/">Source</a>'
            '<a href="mailto:info@pontonniers-geneve.ch">Contact</a>'
        )
        self.assertEqual(errors, [])


if __name__ == "__main__":
    unittest.main()
