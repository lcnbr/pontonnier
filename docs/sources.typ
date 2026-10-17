= Reference sources and media

The source is the public website of the Société des Pontonnier·ère·s de Genève,
inspected on 17 October 2026. Its Twenty Ten composition supplies the reference
layout. The CSS in this repository is a separate implementation.

== Content migration

The public articles, technical material, gallery events and captions are authored
in editable Typst files under `content/`, preserving the corresponding paths on
#link("https://www.pontonniers-geneve.ch/"). The main entry point is
`content/index.typ`; `content/galerie.typ` lists every imported album.

The existing history introduction and its local edit are preserved. Additional
illustrations, historical background, sources and downloads were appended.
The gallery’s legacy named anchors were retained; missing event targets in the
2014, 2021 and 2023 albums were repaired to point at their corresponding sections.
WordPress attachment-page links resolve to the same pictures hosted locally.

The route inventory is in `main.typ`. Blank internal pages and test pages were
excluded. Contact and registration retain the society’s contact information;
the WordPress form processor is not part of this static site.

== Media provenance

`assets/manifest.json` records each local file’s path, source URL, byte size and
SHA-256 checksum. Typst reads this inventory to publish the files in the bundle.
Images use existing source-provided web renditions where available. They were
not generatively recreated. Videos and PDFs retain their downloaded bytes.

The former WordPress link to Louis Blondel’s _Le port gallo-romain_ was unavailable.
Its PDF was recovered from the current website’s uploads at
#link("https://www.pontonniers-geneve.ch/wp-content/uploads/2016/11/genavaiii.pdf").

Photographs, artwork, logos, articles and documents retain their original rights
and authorship. Public availability does not transfer ownership, and this
repository does not assign them a blanket license. Article credits and source
references are retained with the corresponding content.

== External integrations

At the user’s request, the live Rhonomètre remains at
#link("https://rhonometre.pontonniers-geneve.ch/"). It is a separate service with
its own backend. YouTube, SketchUp, Instagram and independent reference sites
remain external. The main website’s pages, images, PDFs and hosted videos are
served locally and do not request the original website.

== Compiler and deployment

- #link("https://typst.app/docs/reference/html/")[Typst native HTML export]
- #link("https://typst.app/docs/reference/bundle/")[Typst bundle export]
- #link("https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages")[GitHub Pages custom workflows]
