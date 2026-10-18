#!/usr/bin/env python3
"""Check editor media coverage, or list the images needed by regular pages."""

import argparse
from html.parser import HTMLParser
import hashlib
import json
import os
from pathlib import Path
import subprocess
from tempfile import TemporaryDirectory
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parents[1]


class PageMedia(HTMLParser):
    def __init__(self, html, preview=False):
        super().__init__()
        self.preview = preview
        self.errors = []
        self.notice = False
        self.album = False
        self.images = []
        self.feed(html)

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        classes = (attrs.get("class") or "").split()
        self.notice |= "editor-preview-notice" in classes
        self.album |= tag == "main" and "gallery-page" in classes
        if tag == "img":
            self.images.append(
                {"src": attrs.get("src", ""), "alt": attrs.get("alt", "")}
            )
        if not self.preview:
            return
        if tag in {"video", "iframe", "script"} or "gallery" in classes:
            self.errors.append(f"unexpected heavyweight element: {tag}")
        if self.album and "editor-gallery" in classes:
            self.errors.append("album gallery must stay hidden in the editor")
        if tag == "img" and not attrs.get("src", "").startswith("data:image/"):
            self.errors.append("preview image is not embedded locally")


def compile_page(page, output, mode):
    result = subprocess.run(
        [
            os.environ.get("TYPST", "typst"),
            "compile",
            "--root",
            str(ROOT),
            "--features",
            "html",
            "--format",
            "html",
            "--input",
            "base-path=/",
            "--input",
            f"media={mode}",
            str(page),
            str(output),
        ],
        capture_output=True,
        text=True,
    )
    if result.returncode:
        raise SystemExit(result.stderr)
    return PageMedia(output.read_text(), preview=mode == "preview")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--inventory",
        action="store_true",
        help="Print regular-page image paths as JSON",
    )
    args = parser.parse_args()
    pages = sorted((ROOT / "content").rglob("*.typ"))
    inventory = set()
    regular_images = 0
    cached = {}
    originals = {}
    if not args.inventory:
        originals = {
            item["path"]: item
            for item in json.loads((ROOT / "assets/manifest.json").read_text())
        }
        for item in json.loads((ROOT / "preview/manifest.json").read_text()):
            file = ROOT / item["file"]
            if not file.is_relative_to(ROOT / "preview") or ".." in file.parts:
                raise SystemExit("Preview file must be inside preview/")
            if hashlib.sha256(file.read_bytes()).hexdigest() != item["sha256"]:
                raise SystemExit(
                    f"{item['file']}: preview checksum differs; run npm run previews"
                )
            for source in item["sources"]:
                cached["assets/" + source] = item
    with TemporaryDirectory(prefix="pontonnier-editor-") as directory:
        output = Path(directory) / "page.html"
        for page in pages:
            if args.inventory:
                full = compile_page(page, output, "full")
                if full.album:
                    continue
                for image in full.images:
                    if not image["src"].startswith("/assets/"):
                        raise SystemExit(f"{page}: non-local image {image['src']}")
                    inventory.add(unquote(image["src"].lstrip("/")))
                continue
            preview = compile_page(page, output, "preview")
            if not preview.notice:
                preview.errors.append("missing editor preview notice")
            if preview.album:
                if len(preview.images) != 1:
                    preview.errors.append(
                        "album preview should show only the header logo"
                    )
            else:
                full = compile_page(page, output, "full")
                if [image["alt"] for image in preview.images] != [
                    image["alt"] for image in full.images
                ]:
                    preview.errors.append(
                        "regular-page images are missing or out of order; run npm run previews"
                    )
                for image in full.images:
                    source = unquote(image["src"].lstrip("/"))
                    thumbnail = cached.get(source)
                    original = originals.get(source)
                    if (
                        not thumbnail
                        or not original
                        or thumbnail["source_sha256"] != original["sha256"]
                    ):
                        preview.errors.append(
                            f"missing or stale preview for {source}; run npm run previews"
                        )
                regular_images += len(preview.images)
            if preview.errors:
                raise SystemExit(
                    f"{page.relative_to(ROOT)}: {', '.join(preview.errors)}"
                )
    if args.inventory:
        print(json.dumps(sorted(inventory)))
    else:
        print(
            f"Validated {len(pages)} editor previews: {regular_images} regular-page images, no remote media or album galleries"
        )


if __name__ == "__main__":
    main()
