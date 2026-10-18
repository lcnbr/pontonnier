#import "site.typ": name, motto, email, navigation, albums, backgrounds, rhonometre-url
#import "gallery.typ": photo-viewer, ui-icon
#import "media.typ": *
#import "album.typ": album-data, album-event, album-page, album-index

#let section(class, body) = html.div(class: class, body)
#let contact-link() = link("mailto:" + email, email)
#let menu-link(item, current) = html.a(href: base + item.path,
  ..if item.path == current { ("aria-current": "page") } else { (:) }, item.title)
#let album-menu(current) = {
  let album = albums.find(item => item.path == current)
  html.details(class: "gallery-menu")[
    #html.summary[Galerie#if album != none and album.title.len() == 4 { [ · #album.title] } #ui-icon("chevron")]
    #html.ul(class: "album-options submenu", ..("aria-label": "Choisir une année ou un album"))[
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
      #if not light-preview {
        html.script(read("assets/theme-init.js"))
        html.script(type: "module", src: base + "assets/site.mjs")
        html.script(type: "module", src: base + "assets/gallery.mjs")
      }
    ]
    #html.elem("body", attrs: (class: "site" + if light-preview { " editor-preview" } else { "" },
      "data-page": if path == "" { "home" } else { "article" }, "data-backgrounds": json.encode(backgrounds)))[
      #html.a(href: "#content", class: "skip-link")[Aller au contenu]
      #if not light-preview {
        html.div(class: "river-backdrop", ..("aria-hidden": true),
          style: "background-image:url('" + base + "assets/" + backgrounds.first() + "')")[]
      }
      #html.header(class: "site-header")[
        #html.a(href: base, class: "header-logo", ..("aria-label": "Accueil — " + name))[
          #picture("club-logo.png", "Logo des Pontonnier·ère·s de Genève", loading: "eager")
        ]
        #html.div(class: "header-inner")[
          #html.div(class: "branding")[
            #html.div(class: "site-title")[#site-link("", name)]
            #html.p(class: "site-description", motto)
          ]
          #html.nav(class: "nav-tools", ..("aria-label": "Navigation principale"))[
            #html.a(href: base, class: "compact-brand", name)
            #html.ul(class: "inline-links menu")[
              #for item in navigation {
                html.li(class: if item.path == "galerie/" { "gallery-nav" } else { "" })[
                  #if item.path == "galerie/" { album-menu(path) } else if "children" in item {
                    html.details[
                      #html.summary[#item.title #ui-icon("chevron")]
                      #html.ul(class: "submenu")[
                        #for child in item.children { html.li(menu-link(child, path)) }
                      ]
                    ]
                  } else { menu-link(item, path) }
                ]
              }
            ]
            #html.details(class: "overflow-menu", hidden: true)[
              #html.summary(..("aria-label": "Menu"))[#ui-icon("waves") #html.span(class: "menu-label")[Menu]]
              #html.div(class: "menu-panel")[
                #html.ul(class: "overflow-links menu", ..("aria-label": "Autres rubriques"))[]
              ]
            ]
            #html.button(type: "button", class: "theme-toggle", ..("aria-label": "Activer le mode sombre"))[
              #ui-icon("moon") #ui-icon("sun")
            ]
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
        #if light-preview { html.p(class: "editor-preview-notice")[Aperçu de rédaction · médias allégés] }
        #html.div(class: "entry-content", body)
        #if album != none and not light-preview { photo-viewer() }
      ]
      #if path == "" and not light-preview {
        html.section(class: "rhonometre-section", ..("aria-label": "Rhonomètre — Rhône avant la Jonction"))[
          #html.iframe(class: "rhonometre live-rhonometre", src: rhonometre-url,
            title: "Rhonomètre : température et débit du Rhône avant la Jonction", loading: "lazy",
            referrerpolicy: "strict-origin-when-cross-origin")[]
        ]
      }
      #if path != "" and not light-preview { html.div(class: "photo-reveal", ..("aria-hidden": true))[] }
    ]
  ]
}
