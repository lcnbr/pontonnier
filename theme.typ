#import "site.typ": name, motto, email, navigation, albums
#import "gallery.typ": photo-viewer

#import "media.typ": *
#import "album.typ": album-data, album-event, album-page, album-index

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
          #if album != none and path != "galerie/" {
            html.nav(class: "album-breadcrumb", ..("aria-label": "Fil d’Ariane"))[
              #site-link("galerie/")[Albums]
              #html.span(class: "album-parent", hidden: true)[#html.span("/") #site-link(path, album.title)]
            ]
          }
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
