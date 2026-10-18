= Editing and publishing the website

== Source and media repositories

#link("https://github.com/lcnbr/pontonnier")[pontonnier] is the small project
synced with the Typst web app. Typst 0.15.1 generates all website HTML directly;
CSS supplies the layout. The photographs, diagrams, videos and PDF downloads
live in #link("https://github.com/lcnbr/pontonnier-media")[pontonnier-media].

- `content/`: editable French page sources.
- `site.typ`: the name, contact details, published URL, album inventory and background pool.
- `theme.typ`: the shared Typst HTML page template.
- `media.typ`: photos, videos and lightweight editor media.
- `album.typ`: cover choices, media counts and album/event cards.
- `album-catalog.typ`: the overview, derived from the album sources in `site.typ`.
- `assets/site.css`: the visual layout.
- `gallery.typ`: Typst-generated photo viewer controls.
- `assets/gallery.mjs`: mosaic layout, carousel navigation and zoom.
- `assets/site.mjs`: sticky navigation, overflow menu, theme and visit background.
- `assets/theme-init.js`: restores the visitor’s theme before the first paint.
- `assets/manifest.json`: published asset paths, provenance and image dimensions.
- `.media-revision`: the full media commit selected for publication.
- `main.typ`: the pages and assets emitted by Typst’s bundle exporter.
- `.media/`: an ignored media checkout, downloaded by local builds and CI.
- `dist/`: generated deployment files, also ignored by Git.
- `preview/`: optimized images for regular pages, with source hashes and size limits.
- `scripts/update-previews.mjs`: refreshes editor images from the pinned media repository.
- `scripts/upgrade-media.mjs`: recovers public originals and creates small mosaic images.

The published site keeps the same local `assets/` URLs for article media and adds
small WebP images for mosaics and covers. Opening a photo loads the largest
available original from the pinned media repository on GitHub Raw. It does not
request the original WordPress site. Camera originals remain outside the Pages
bundle and outside the small Typst project; CI uses a partial media checkout.

== Reconnect after the media split

The media was removed from every commit in this repository on 17 October 2026.
This makes the whole Git history small enough to clone through Typst’s Git Sync.
Content edits and their authorship were preserved, but commit identifiers changed.

For a project linked before this migration:

+ Save or export any edits that have not been pushed from the old Typst project.
+ From the Typst dashboard, use *Start from GitHub* to create a fresh project from
  `lcnbr/pontonnier`, branch `main`.
+ Choose Typst 0.15.1, enable experimental HTML export and select HTML preview.
+ Select `content/index.typ`, or another page, as the previewed file. Copy any
  saved, unpushed text edits into this new project before continuing to edit.

Keep the old project until those edits are recovered. Use the new project for
future pulls and pushes. Other local Git clones should also be cloned again.
The complete original history remains recoverable from the media repository’s
`source-before-media-split-2026-10-17` tag.

== Authoring and previewing

Each page imports the shared theme and sets its title and route:

```typst
#import "/theme.typ": *
#show: page.with(title: "La Société", path: "la-societe/")

Une nouvelle description de notre association.

== Nos activités

- Navigation à la rame
- Navigation à la gaffe

#site-link("sport/cours/")[Découvrir les cours]
```

The template supplies the main heading. Use `==` for section headings,
`site-link` for internal links and Typst’s `link` for external references.
Select the page’s source file to switch pages within the Typst editor.

Individual Typst previews default to lightweight editing mode. Every image on
regular pages is available locally, including historical illustrations, maps,
knot diagrams, and photo groups in articles and on the homepage. Album covers
and album photographs remain hidden. Videos and embedded services are replaced
by short notes. These previews load no remote media.

The JPEGs in `preview/` are downscaled copies embedded directly in the preview
HTML. Images fit within 960 × 1280 pixels without cropping or upscaling;
animated GIFs use a still frame. Identical source files share a preview. The
current cache is about 3.6 MB. `preview/limits.json` caps it at 96 images,
128 KiB per image and 4 MiB total, keeping the editing repository small.
Originals still belong in `pontonnier-media` and are used for publication.

When adding or replacing an image used outside an album, refresh the cache
locally with Node.js 20.9 or newer, Python 3 and the pinned Typst CLI installed:

```sh
bash scripts/fetch-media.sh
npm ci --ignore-scripts
npm run previews
python3 scripts/check-preview.py
```

Commit the generated `preview/` changes along with the page and media manifest.
The generator discovers images from the Typst-generated regular pages, verifies
the pinned originals and applies the size limits before writing. Node packages
are maintenance tools only: they are ignored by Git and never synced into Typst.
CI checks that regular-page previews include every image and that their source
hashes are current; ordinary text edits need no image regeneration.

Production builds explicitly pass `--input media=full`. They retain every photo,
video, embed and download at its existing local website URL. To preview all media
from a single file locally, use `--features html --input media=full`; its images
load from `published-url` unless a local `base-path` is supplied.

The web app does not support bundle export. Preview individual files there;
GitHub Actions compiles `main.typ` to publish the complete website. Typst Pro is
needed to connect Git Sync. Pull before editing, then push when ready.

#link("https://typst.app/docs/web-app/git-sync/")[Typst Git Sync documentation]

== Local builds and checks

Install Git, Python 3 and the Typst CLI release in `.typst-version`, then run:

```sh
bash scripts/build.sh
python3 scripts/check.py
```

The build fetches exactly `.media-revision` from the public media repository
into `.media/`. It reuses a matching checkout and stops if that checkout has
local changes. No personal access token is needed. Invoke shell scripts through
Bash because editor synchronization can remove executable file permissions.

For a live preview, fetch the media once and run Typst’s built-in server:

```sh
bash scripts/fetch-media.sh
typst watch --root . --features html,bundle --format bundle \
  --input base-path=/ --input media=full main.typ dist
```

Typst prints the local URL. Stop it with Ctrl-C. A root build uses `/`; a GitHub
Pages project build uses `/pontonnier/`:

```sh
BASE_PATH=/pontonnier/ bash scripts/build.sh
python3 scripts/check.py --base-path /pontonnier/
```

A server for that build must mount `dist/` at `/pontonnier/`. Typst generates the
HTML. A small local JavaScript module enhances the gallery and menu; there are
no external script dependencies. Without JavaScript, the photos and album links
remain usable. Typst injects live reload only into its preview server.

CI also runs the Python tests, `node --test tests/gallery.test.mjs` and
`python3 scripts/check-preview.py`; the last command compiles every editor page
and verifies that it contains only embedded lightweight images.

== Adding or changing media

+ Add the binary file under `assets/` in `pontonnier-media`, then commit and push
  that repository. Preserve existing paths when replacing a file.
+ In this source repository, update `.media-revision` to the full media commit SHA.
+ Add or update its `assets/manifest.json` entry. Record the path, original source,
  byte size and SHA-256 checksum; images also need width and height in pixels.
+ Reference it from Typst. If it is an image on a regular page, run
  `npm run previews` to refresh the local editor copy. Push the source changes
  and previews to trigger publication.

```typst
#photo("archive/2026/10/sortie.jpg", "Sortie sur le Rhône")
#video("archive/2026/10/sortie.mp4", "Navigation sur le Rhône")
#site-link("assets/archive/document.pdf")[Télécharger le document]
```

Pushing media alone does not change the live site. The source revision explicitly
selects the media version, making builds reproducible. Keep binary files out of
this editor repository except for the bounded `preview/` thumbnail cache. CI
checks that cache, the source file count, file sizes and reachable history size.

== Album covers, events and new years

Each album source exports `album` and renders it with `album-page`. Its top-level
`cover:` selects the year or collection cover. Each `album-event` has its own
optional `cover:`. Paths are relative to the media repository’s `assets/` folder.
The existing choices are pinned to the covers approved in the layout preview.

```typst
#import "/theme.typ": *

#let album = album-data(
  title: "2026", path: "galerie/images-2026/",
  cover: "archive/2026/10/sortie.jpg",
  events: (
    album-event(
      id: "sortie-octobre", title: [Sortie d’octobre],
      cover: "archive/2026/10/equipe.jpg",
    )[
      #gallery[
        #photo("archive/2026/10/sortie.jpg", "Une barque sur le Rhône")
        #photo("archive/2026/10/equipe.jpg", "Notre équipe",
          caption: [Photo : notre équipe.])
      ]
    ],
  ),
)
#show: page.with(title: album.title, path: album.path)
#album-page(album)
```

Change either cover by editing that one path and pushing. Set `cover: none`, or
omit it, to use the first photo in that event or album. Explicit choices stay
unchanged when photos are inserted or reordered. Covers must be images listed
in `assets/manifest.json`; an unknown path produces a clear build error. They
retain their original proportions inside the cover frame.

Photo/video counts and overview cards are calculated from the same Typst content;
there is no separate generated catalog to maintain. Photos, videos, credits,
source links and explanatory text belong inside the event body. Video-only
events are supported; they can use an explicit image as their cover. Keep event
ids stable because existing links use them, and reserve `all-photos` for the
complete year view. Titles can contain links, which remain available in the
opened event; cover cards display the title text.

The navbar opens the album overview for a year. Select an event card for its
photos and videos, or use the link beside the media count for the whole year.
The carousel follows that selection and opens in a fullscreen overlay. The page
behind it stays in place and cannot scroll or receive keyboard focus. Scroll,
pinch or use the magnifier buttons to zoom; drag to pan, click
the percentage to reset, and use the arrows or swipe at normal zoom to change
photos. Escape or the close icon returns to the gallery position. Browser Back
and old event anchors also work. Without JavaScript, the cards link to the event
sections, which remain visible on the page.

Alternative text identifies images for accessibility and is never displayed as
a caption. Add `caption: [...]` to `photo` for a real caption, or to `gallery`
for a shared caption or credit. Captions can contain source links. The editor
continues to hide album media and covers while showing the editable text; photo
groups on regular pages remain visible.

To add a year, copy a recent album source, extend the `albums` year range in
`site.typ`, and register the page in `main.typ`. The overview automatically reads
that album source. The historic routes for 2012 and 2015 are preserved.

For other new pages, copy an existing content file, register it in `main.typ`
and add navigation in `site.typ` as needed. Check both root and project-path builds.

== Deployment and reference scope

Pushes to `main` validate the editor repository, fetch the pinned media, compile
all pages, check local links and media paths, and publish to GitHub Pages.
Pull requests run the checks without publishing. Pages uses *GitHub Actions* as
its build source. The workflow uses its short-lived GitHub token; no hosting
password or cross-repository write credential is required.

The address remains #link("https://lcnbr.github.io/pontonnier/"). A future custom
domain should also be set as `published-url` for web-editor previews; CI obtains
its deployment base path from GitHub Pages.

The albums, articles, technical material and downloads remain local to the
published website. The live Rhonomètre is intentionally retained as an external
service, as requested. Independent references and YouTube/SketchUp embeds remain
external too. Contact and registration use email, without the WordPress backend.
