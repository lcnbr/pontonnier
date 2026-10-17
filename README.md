# Pontonnier

A reproduction of [pontonniers-geneve.ch](https://www.pontonniers-geneve.ch/),
with French content authored in Typst and HTML generated directly by Typst.

The articles, photo albums, PDFs and hosted videos are served locally; the live
Rhonomètre remains an external integration.

Edit the `.typ` files under `content/`, push to `main`, and GitHub Actions publishes to
[GitHub Pages](https://lcnbr.github.io/pontonnier/).

With Typst 0.15.1 installed:

```sh
bash scripts/build.sh
python3 scripts/check.py
```

See [the editing and deployment guide](docs/editing.typ) for Typst web app
setup, local preview, and adding pages; [sources](docs/sources.typ) records
reference content and media. HTML and bundle export are experimental and the
compiler is pinned in `.typst-version`. Generated HTML is not committed.
