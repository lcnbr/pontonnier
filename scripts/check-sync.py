#!/usr/bin/env python3
"""Keep the editor repository within Typst's documented Git Sync limits."""

from pathlib import Path
import json
import subprocess


ROOT = Path(__file__).resolve().parents[1]
PREVIEW_LIMITS = json.loads((ROOT / "preview/limits.json").read_text())
MEDIA_SUFFIXES = {".jpg", ".jpeg", ".png", ".gif", ".webp", ".mp4", ".pdf"}


def git(*args, **kwargs):
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True, **kwargs)


def main():
    paths = [Path(name) for name in git("ls-files", "-z").split("\0") if name]
    errors = []
    preview_images = []
    if len(paths) > 1000:
        errors.append(f"{len(paths)} tracked files exceed Typst Pro's 1,000-file limit")
    for path in paths:
        if path.suffix.lower() in MEDIA_SUFFIXES:
            if path.parts[0] == "preview" and path.suffix.lower() in {
                ".jpg",
                ".jpeg",
                ".png",
                ".webp",
            }:
                preview_images.append(path)
                if (ROOT / path).stat().st_size > PREVIEW_LIMITS["max_image_bytes"]:
                    errors.append(
                        f"{path}: editor thumbnail exceeds {PREVIEW_LIMITS['max_image_bytes'] // 1024} KiB"
                    )
            else:
                errors.append(f"{path}: store media in pontonnier-media instead")
        if (ROOT / path).stat().st_size > 20 * 1024**2:
            errors.append(f"{path}: exceeds Typst's 20 MiB per-file limit")

    if (
        len(preview_images) > PREVIEW_LIMITS["max_images"]
        or sum((ROOT / path).stat().st_size for path in preview_images)
        > PREVIEW_LIMITS["max_total_bytes"]
    ):
        errors.append(
            f"Editor thumbnails must stay within {PREVIEW_LIMITS['max_images']} files "
            f"and {PREVIEW_LIMITS['max_total_bytes'] // 1024**2} MiB total"
        )

    # Include history and all fetched refs: deleting a large file is not enough.
    objects = git("rev-list", "--objects", "--all")
    identities = "\n".join(line.split()[0] for line in objects.splitlines()) + "\n"
    sizes = git("cat-file", "--batch-check=%(objectsize)", input=identities)
    history_bytes = sum(int(size) for size in sizes.splitlines())
    if history_bytes > 100_000_000:
        errors.append("Reachable Git objects exceed the 100 MB sync budget")
    if errors:
        raise SystemExit("\n".join(errors))
    source_bytes = sum((ROOT / path).stat().st_size for path in paths)
    print(
        f"Typst sync: {len(paths)} files, {source_bytes:,} source bytes, "
        f"{history_bytes:,} uncompressed Git-history bytes"
    )


if __name__ == "__main__":
    main()
