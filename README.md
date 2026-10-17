# Pontonnier

The [Pontonnier website](https://lcnbr.github.io/pontonnier/) is authored in Typst,
which generates its HTML directly. This repository contains the small editing
project. Typst previews use six tiny local images and omit galleries, videos and
embeds; publishing retains the full media. Photos, PDFs and videos live in [pontonnier-media](https://github.com/lcnbr/pontonnier-media).

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
