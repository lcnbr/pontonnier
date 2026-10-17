#import "site.typ": name, motto, email, navigation

#let base = sys.inputs.at("base-path", default: "/")
#assert(base.starts-with("/") and base.ends-with("/"), message: "base-path must start and end with /")
#let site-link(path, body) = link(base + path, body)
#let photo(file, alt, caption: none) = html.figure[
  #image("assets/" + file, alt: alt)
  #if caption != none { html.figcaption(caption) }
]
#let gallery(body) = html.div(class: "gallery", body)
#let section(class, body) = html.div(class: class, body)
#let contact-link() = link("mailto:" + email, email)
#let menu-link(item, current) = html.a(
  href: base + item.path,
  ..if item.path == current { ("aria-current": "page") } else { (:) },
  item.title,
)

#let page(title: "", path: "", description: "La Société des Pontonnier·ère·s de Genève : histoire, navigation, cours et vie du club au bord du Rhône.", body) = {
  set text(lang: "fr")
  set document(title: title + " | " + name, author: name)
  html.html(lang: "fr")[
    #html.head[
      #html.meta(charset: "utf-8")
      #html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
      #html.meta(name: "description", content: description)
      #html.title(title + " | " + name)
      #html.style(read("assets/site.css"))
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
            #image("assets/banner.jpg", alt: "La rade de Genève à la tombée de la nuit")
          ]
          #html.nav(..("aria-label": "Navigation principale"))[
            #html.ul(class: "menu")[
              #for item in navigation {
                html.li[
                  #if "children" in item {
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
        #html.main(id: "content", tabindex: -1)[
          #html.h1(class: "entry-title", title)
          #html.div(class: "entry-content", body)
        ]
        #html.footer[
          #html.strong[#site-link("", name)]
          #html.span[Site réalisé avec #link("https://typst.app/")[Typst]]
        ]
      ]
    ]
  ]
}
