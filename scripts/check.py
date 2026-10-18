#!/usr/bin/env python3
"""Check the compiled site, including links beneath a GitHub Pages subpath."""

import argparse
import json
import subprocess
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit


class Page(HTMLParser):
    def __init__(self, path):
        super().__init__(convert_charrefs=True)
        self.path = path
        self.ids = set()
        self.urls = []
        self.backgrounds = []
        self.errors = []
        self.headings = 0
        self.main = 0
        self.french = False
        self.viewport = False
        self.feed(path.read_text(encoding="utf-8"))

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if "editor-preview-notice" in (attrs.get("class") or "").split():
            self.errors.append("editor preview must not be published")
        if "id" in attrs:
            if attrs["id"] in self.ids:
                self.errors.append(f"duplicate id: {attrs['id']}")
            self.ids.add(attrs["id"])
        if tag == "html":
            self.french = attrs.get("lang") == "fr"
        if tag == "body" and "data-backgrounds" in attrs:
            try:
                pool = json.loads(attrs["data-backgrounds"])
                if (
                    not isinstance(pool, list)
                    or not pool
                    or not all(isinstance(path, str) and path for path in pool)
                ):
                    raise ValueError("invalid background inventory")
                self.backgrounds = pool
            except (TypeError, ValueError):
                self.errors.append("backgrounds must be a non-empty list of asset paths")
        if tag == "meta" and attrs.get("name") == "viewport":
            self.viewport = True
        if tag == "h1":
            self.headings += 1
        if tag == "main":
            self.main += 1
        if tag == "img" and not attrs.get("alt"):
            self.errors.append("image is missing alternative text")
        if tag == "img" and not attrs.get("src"):
            self.errors.append("image has no source")
        if tag == "a" and not attrs.get("href"):
            self.errors.append("empty link")
        for attribute in ("href", "src", "poster", "action"):
            if attrs.get(attribute):
                self.urls.append(attrs[attribute])
        if attrs.get("srcset"):
            self.urls.extend(
                item.strip().split()[0]
                for item in attrs["srcset"].split(",")
                if item.strip()
            )

    def check(self, pages, root, base):
        if not (
            self.french and self.viewport and self.headings == 1 and self.main == 1
        ):
            self.errors.append(
                "expected French document, viewport, one h1 and one main"
            )
        for href in self.urls + [base + "assets/" + path for path in self.backgrounds]:
            url = urlsplit(href)
            if url.hostname in {
                "pontonniers-geneve.ch",
                "www.pontonniers-geneve.ch",
                "pontonniers.files.wordpress.com",
                "pontonniers.wordpress.com",
            }:
                self.errors.append(f"original-site dependency: {href}")
                continue
            if url.scheme or url.netloc:
                continue
            if not href:
                self.errors.append("empty link")
                continue
            path = unquote(url.path)
            if path.startswith("/"):
                if not path.startswith(base):
                    self.errors.append(f"link escapes base path {base}: {href}")
                    continue
                target = root / path[len(base) :]
            elif path:
                target = self.path.parent / path
            else:
                target = self.path
            target = target.resolve()
            if not target.is_relative_to(root):
                self.errors.append(f"link escapes output directory: {href}")
                continue
            if target.is_dir():
                target /= "index.html"
            if not target.is_file():
                self.errors.append(f"broken link: {href}")
            elif url.fragment and target in pages:
                if unquote(url.fragment) not in pages[target].ids:
                    self.errors.append(f"missing anchor: {href}")
        return [f"{self.path.relative_to(root)}: {error}" for error in self.errors]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--directory", type=Path, default=Path("dist"))
    parser.add_argument("--base-path", default="/")
    args = parser.parse_args()
    root = args.directory.resolve()
    pages = {path: Page(path) for path in root.rglob("*.html")}
    errors = []
    for required in ("index.html", "404.html", ".nojekyll"):
        if not (root / required).is_file():
            errors.append(f"missing required output: {required}")
    for page in pages.values():
        errors.extend(page.check(pages, root, args.base_path))
    source = Path(__file__).resolve().parents[1]
    manifest = json.loads((source / "assets/manifest.json").read_text())
    originals = {item["original"]["path"] for item in manifest if "original" in item}
    if originals:
        # Read Git tree names, never the original blobs in the partial checkout.
        archived = set(subprocess.check_output(
            ["git", "-C", str(source / ".media"), "ls-tree", "-r", "--name-only",
             "HEAD", "--", "originals/"], text=True,
        ).splitlines())
        errors.extend(f"original is absent from the pinned media commit: {path}"
                      for path in sorted(originals - archived))
    published_bytes = sum(path.stat().st_size for path in root.rglob("*") if path.is_file())
    if published_bytes > 1_000_000_000:
        errors.append("Pages output exceeds 1 GB; keep camera originals outside the published bundle")
    if errors:
        raise SystemExit("\n".join(errors))
    print(
        f"Validated {len(pages)} HTML pages, local links and media references at {args.base_path}; "
        f"{len(originals)} archived originals, {published_bytes:,} published bytes"
    )


if __name__ == "__main__":
    main()
