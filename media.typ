#import "site.typ": published-url

// Media metadata survives the lightweight preview, keeping counts and cover
// fallbacks identical in the editor and in the published HTML.
#let media-items(value) = {
  if type(value) == array { return value.map(media-items).flatten() }
  if type(value) != content { return () }
  if value.func() == metadata {
    let data = value.value
    return if type(data) == dictionary and data.at("kind", default: none) == "gallery-media" { data.items } else { () }
  }
  value.fields().values().map(media-items).flatten()
}

#let base = sys.inputs.at("base-path", default: published-url)
#assert(base.ends-with("/"), message: "The site base URL must end with /")
#let site-link(path, body) = link(base + path, body)
// Editor previews, small mosaic images and unchanged originals have separate paths.
#let media-mode = sys.inputs.at("media", default: "preview")
#assert(media-mode in ("preview", "full"), message: "media must be preview or full")
#let light-preview = media-mode == "preview"
#let previews = if light-preview { json("preview/manifest.json") } else { () }
#let media = json("assets/manifest.json")
#let picture(file, alt, loading: "lazy", thumbnail: false) = {
  if light-preview {
    let cached = previews.find(item => file in item.sources)
    return if cached != none { image(cached.file, alt: alt) }
      else { html.p(class: "editor-media-note")[Image : #alt] }
  }
  let source = media.find(item => item.path == "assets/" + file)
  if thumbnail and source != none and "derived_from" not in source {
    assert("thumbnail" in source, message: "Create a mosaic thumbnail for " + file + " with scripts/upgrade-media.mjs")
  }
  let entry = if thumbnail and source != none and "thumbnail" in source {
    let small = media.find(item => item.path == source.thumbnail)
    assert(small != none, message: "Missing mosaic image for " + file)
    small
  } else { source }
  let dimensions = if entry != none and "width" in entry and "height" in entry {
    (width: str(entry.width), height: str(entry.height))
  } else { (:) }
  html.elem("img", attrs: (src: base + if entry != none { entry.path } else { "assets/" + file },
    alt: alt, loading: loading, decoding: "async", "data-media-file": file, ..dimensions))
}
#let photo(file, alt, caption: none, destination: none) = {
  metadata((kind: "gallery-media", items: ((kind: "photo", file: file),)))
  let entry = media.find(item => item.path == "assets/" + file)
  let href = if destination != none { destination } else if entry != none and "original" in entry {
    "https://raw.githubusercontent.com/lcnbr/pontonnier-media/" + read(".media-revision").trim() + "/" + entry.original.path
  } else { base + "assets/" + file }
  html.figure(class: if destination == none { "photo gallery-photo" } else { "photo" })[
    #link(href, picture(file, alt, thumbnail: true))
    #if caption != none { html.figcaption(caption) }
  ]
}
#let video(file, description) = {
  metadata((kind: "gallery-media", items: ((kind: "video", file: file),)))
  if light-preview {
    html.p(class: "editor-media-note")[Vidéo : #description]
  } else {
    html.figure[
      #html.video(src: base + "assets/" + file, controls: true, preload: none,
        ..("aria-label": description))[
        #site-link("assets/" + file)[Télécharger la vidéo]
      ]
      #html.figcaption(description)
    ]
  }
}
#let gallery(body, caption: none) = {
  html.div(class: if light-preview { "editor-gallery" } else { "gallery" }, body)
  if caption != none { html.div(class: "gallery-caption", caption) }
}
