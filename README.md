# Pontonnier

The [Pontonnier website](https://lcnbr.github.io/pontonnier/) is authored in Typst,
which generates its HTML directly. This repository contains the small editing
project. Typst previews include optimized local images throughout the regular pages,
including article photo groups. Album galleries, videos and embeds stay hidden;
publishing uses small mosaic images and opens the highest available archived originals. Photos, PDFs and videos live in [pontonnier-media](https://github.com/lcnbr/pontonnier-media).

Edit the `.typ` files under `content/` and push to `main`. CI fetches the media
commit pinned in `.media-revision` and publishes the complete website at the
same address, including its local media URLs and live Rhonomètre integration.

With Git, Typst 0.15.1 and Python 3 installed:

```sh
bash scripts/build.sh
python3 scripts/check.py
```

The first build downloads media into the ignored `.media/` checkout.
See [the editing guide](docs/editing.typ) for Typst web-app setup, the one-time
reconnection after the media split, previews and adding media. [Sources](docs/sources.typ)
records attribution. HTML and bundle export are experimental; the compiler is pinned.

The shared Signal / Rhône theme uses the Rhonomètre font stack, a compact sticky
navbar, a persistent light/dark toggle, and a random river photograph kept for
the browser visit. Edit the `backgrounds` inventory in `site.typ` to change the
nine-image pool. The approved navbar uses 65% opacity, 2px blur and a 32px gap
above the content sheet. The gallery keeps its uncropped mosaic, album covers
and fullscreen carousel with zoom.

Accueil embeds the live Rhonomètre at station 2606. The optional transparent,
unbranded presentation and automatic iframe height require the corresponding
Rhonomètre release; older releases still display the live embed with their
existing branding. The host checks message origin and source before resizing.

Photo quality is separate from editor previews. `assets/manifest.json` maps each
logical photo to a local WebP thumbnail (at most 960px and 128 KiB) and, when a
larger original was recovered, its unchanged archive file. The fullscreen viewer
shows the small image immediately and upgrades to the original when decoded.
Originals are loaded from the pinned `pontonnier-media` commit on GitHub Raw;
they are not copied into either Typst or the GitHub Pages bundle. Standalone article
pictures retain their existing web renditions. CI checks that every original is
present in the selected media commit without downloading the original blobs.

To refresh the source catalog and media in a separate media checkout:

```sh
npm ci
node scripts/upgrade-media.mjs /path/to/pontonnier-media
```

The updater checks WordPress's media catalog, including `original_image`, then
compares actual image dimensions. It preserves original bytes and EXIF data,
records provenance in the media repo's `originals/manifest.json`, and reuses
content-addressed files across aliases. Existing archived originals are retained
if the source site later removes them. Commit and push the media repo, update
`.media-revision`, and run the usual build and validation before publishing.
