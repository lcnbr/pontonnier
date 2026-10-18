# Pontonnier

The [Pontonnier website](https://lcnbr.github.io/pontonnier/) is authored in Typst,
which generates its HTML directly. This repository contains the small editing
project. Typst previews include optimized local images throughout the regular pages,
including article photo groups. Album galleries, videos and embeds stay hidden;
publishing retains the full media. Photos, PDFs and videos live in [pontonnier-media](https://github.com/lcnbr/pontonnier-media).

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
