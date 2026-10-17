#!/usr/bin/env python3
"""Compile every editor page and reject heavyweight or remote preview media."""

from html.parser import HTMLParser
import os
from pathlib import Path
import subprocess
from tempfile import TemporaryDirectory

ROOT = Path(__file__).resolve().parents[1]


class Preview(HTMLParser):
    def __init__(self, html):
        super().__init__()
        self.errors = []
        self.notice = False
        self.feed(html)

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        classes = (attrs.get("class") or "").split()
        self.notice |= "editor-preview-notice" in classes
        if tag in {"video", "iframe", "script"} or "gallery" in classes:
            self.errors.append(f"unexpected heavyweight element: {tag}")
        if tag == "img" and not attrs.get("src", "").startswith("data:image/"):
            self.errors.append("preview image is not embedded locally")


def main():
    pages = sorted((ROOT / "content").rglob("*.typ"))
    with TemporaryDirectory(prefix="pontonnier-editor-") as directory:
        for index, page in enumerate(pages):
            output = Path(directory) / f"{index}.html"
            result = subprocess.run(
                [os.environ.get("TYPST", "typst"), "compile", "--root", str(ROOT),
                 "--features", "html", "--format", "html", str(page), str(output)],
                capture_output=True, text=True,
            )
            if result.returncode:
                raise SystemExit(result.stderr)
            preview = Preview(output.read_text())
            if not preview.notice:
                preview.errors.append("missing editor preview notice")
            if preview.errors:
                raise SystemExit(f"{page.relative_to(ROOT)}: {', '.join(preview.errors)}")
    print(f"Validated {len(pages)} lightweight editor previews without remote media")


if __name__ == "__main__":
    main()
