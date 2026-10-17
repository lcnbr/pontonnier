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
// The editor embeds downscaled article images; publishing keeps the full media.
#let media-mode = sys.inputs.at("media", default: "preview")
#assert(media-mode in ("preview", "full"), message: "media must be preview or full")
#let light-preview = media-mode == "preview"
#let previews = if light-preview { json("preview/manifest.json") } else { () }
#let media = json("assets/manifest.json")
#let picture(file, alt, loading: "lazy") = {
  if light-preview {
    let thumbnail = previews.find(item => file in item.sources)
    return if thumbnail != none { image(thumbnail.file, alt: alt) }
      else { html.p(class: "editor-media-note")[Image : #alt] }
  }
  let entry = media.find(item => item.path == "assets/" + file)
  let dimensions = if entry != none and "width" in entry and "height" in entry {
    (width: entry.width, height: entry.height)
  } else { (:) }
  html.img(src: base + "assets/" + file, alt: alt, loading: loading, decoding: "async", ..dimensions)
}
#let photo(file, alt, caption: none, destination: none) = {
  metadata((kind: "gallery-media", items: ((kind: "photo", file: file),)))
  let href = if destination == none { base + "assets/" + file } else { destination }
  html.figure(class: if destination == none { "photo gallery-photo" } else { "photo" })[
    #link(href, picture(file, alt))
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
