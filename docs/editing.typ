= Editing and publishing the website

== Source and media repositories

#link("https://github.com/lcnbr/pontonnier")[pontonnier] is the small project
synced with the Typst web app. Typst 0.15.1 generates all website HTML directly;
CSS supplies the layout. The photographs, diagrams, videos and PDF downloads
live in #link("https://github.com/lcnbr/pontonnier-media")[pontonnier-media].

- `content/`: editable French page sources.
- `site.typ`: the name, contact details, published URL and album inventory.
- `theme.typ`: the shared Typst HTML template and media elements.
- `assets/site.css`: the visual layout.
- `assets/manifest.json`: published asset paths, provenance and image dimensions.
- `.media-revision`: the full media commit selected for publication.
- `main.typ`: the pages and assets emitted by Typst’s bundle exporter.
- `.media/`: an ignored media checkout, downloaded by local builds and CI.
- `dist/`: generated deployment files, also ignored by Git.

The published site keeps the same local `assets/` URLs. Visitors do not download
media from GitHub or from the original WordPress site. CI assembles the two
repositories and deploys one self-contained static site.

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

HTML previews load images, videos and downloads from the published website,
using `published-url` in `site.typ`. The web app therefore needs only the source
files and the small asset index. It does not need the binary media archive.
Text and layout edits appear in the preview; newly added media becomes visible
there after its first deployment. CSS is included in the preview itself.

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
  --input base-path=/ main.typ dist
```

Typst prints the local URL. Stop it with Ctrl-C. A root build uses `/`; a GitHub
Pages project build uses `/pontonnier/`:

```sh
BASE_PATH=/pontonnier/ bash scripts/build.sh
python3 scripts/check.py --base-path /pontonnier/
```

A server for that build must mount `dist/` at `/pontonnier/`. Production has no
application JavaScript. Typst injects live reload only into its preview server.

== Adding or changing media

+ Add the binary file under `assets/` in `pontonnier-media`, then commit and push
  that repository. Preserve existing paths when replacing a file.
+ In this source repository, update `.media-revision` to the full media commit SHA.
+ Add or update its `assets/manifest.json` entry. Record the path, original source,
  byte size and SHA-256 checksum; images also need width and height in pixels.
+ Reference it from Typst and push the source change to trigger publication.

```typst
#photo("archive/2026/10/sortie.jpg", "Sortie sur le Rhône")
#video("archive/2026/10/sortie.mp4", "Navigation sur le Rhône")
#site-link("assets/archive/document.pdf")[Télécharger le document]
```

Pushing media alone does not change the live site. The source revision explicitly
selects the media version, making builds reproducible. Keep binary files out of
this editor repository; CI rejects them and checks the source file count, file
sizes and reachable Git-history size against the documented sync limits.

== Gallery years and new pages

Wrap photos in `gallery[...]` for the responsive mosaic. Images retain their
proportions and open their local file when clicked. The `albums` inventory in
`site.typ` supplies the main menu and year dropdown. Extend the year range when
adding an annual album, then register its source and output path in `main.typ`.
The historic routes for 2012 and 2015 are preserved.

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
