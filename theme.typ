#import "site.typ": name, motto, email, navigation, albums, published-url
#import "gallery.typ": photo-viewer

#let base = sys.inputs.at("base-path", default: published-url)
#assert(base.ends-with("/"), message: "The site base URL must end with /")
#let site-link(path, body) = link(base + path, body)
// The editor uses a tiny local thumbnail set; publishing keeps the full media.
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
  let href = if destination == none { base + "assets/" + file } else { destination }
  html.figure(class: if destination == none { "photo gallery-photo" } else { "photo" })[
    #link(href, picture(file, alt))
    #if caption != none { html.figcaption(caption) }
  ]
}
#let video(file, description) = if light-preview {
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
#let gallery(body, caption: none) = {
  if light-preview {
    html.p(class: "editor-media-note")[Photos de la galerie masquées dans l’aperçu de rédaction.]
  } else { html.div(class: "gallery", body) }
  if caption != none { html.div(class: "gallery-caption", caption) }
}
#let section(class, body) = html.div(class: class, body)
#let contact-link() = link("mailto:" + email, email)
#let menu-link(item, current) = html.a(
  href: base + item.path,
  ..if item.path == current { ("aria-current": "page") } else { (:) },
  item.title,
)

#let album-menu(current) = {
  let album = albums.find(item => item.path == current)
  html.details(class: "gallery-menu")[
    #html.summary[Galerie#if album != none and album.title.len() == 4 { [ · #album.title] }]
    #html.ul(class: "album-options", ..("aria-label": "Choisir une année ou un album"))[
      #for item in albums { html.li(menu-link(item, current)) }
    ]
  ]
}

#let page(title: "", path: "", description: "La Société des Pontonnier·ère·s de Genève : histoire, navigation, cours et vie du club au bord du Rhône.", body) = {
  let album = albums.find(item => item.path == path)
  set text(lang: "fr")
  set document(title: title + " | " + name, author: name)
  show html.elem.where(tag: "iframe"): element => if light-preview {
    html.p(class: "editor-media-note")[Contenu intégré masqué dans l’aperçu de rédaction.]
  } else { element }
  html.html(lang: "fr")[
    #html.head[
      #html.meta(charset: "utf-8")
      #html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
      #html.meta(name: "description", content: description)
      #html.title(title + " | " + name)
      #html.style(read("assets/site.css"))
      #if not light-preview { html.script(type: "module", src: base + "assets/gallery.mjs") }
    ]
    #html.body[
      #html.a(href: "#content", class: "skip-link")[Aller au contenu]
      #html.div(class: "wrapper")[
        #html.header[
          #html.div(class: "branding")[
            #html.div(class: "site-title")[#site-link("", name)]
            #html.p(class: "site-description", motto)
          ]
          #html.div(class: "banner")[
            #picture("banner.jpg", "La rade de Genève à la tombée de la nuit", loading: "eager")
          ]
          #html.nav(..("aria-label": "Navigation principale"))[
            #html.ul(class: "menu")[
              #for item in navigation {
                html.li(class: if item.path == "galerie/" { "gallery-nav" } else { "" })[
                  #if item.path == "galerie/" { album-menu(path) } else if "children" in item {
                    html.details[
                      #html.summary(item.title)
                      #html.ul(class: "submenu")[
                        #for child in item.children { html.li(menu-link(child, path)) }
                      ]
                    ]
                  } else { menu-link(item, path) }
                ]
              }
            ]
          ]
        ]
        #html.main(id: "content", tabindex: -1, class: if album != none { "gallery-page" } else { "" })[
          #html.h1(class: "entry-title", title)
          #if light-preview {
            html.p(class: "editor-preview-notice")[Aperçu de rédaction · médias allégés]
          }
          #html.div(class: "entry-content", body)
          #if album != none and not light-preview { photo-viewer() }
        ]
        #html.footer[
          #html.strong[#site-link("", name)]
          #html.span[Site réalisé avec #link("https://typst.app/")[Typst]]
        ]
      ]
    ]
  ]
}
