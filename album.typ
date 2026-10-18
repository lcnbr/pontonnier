#import "media.typ": base, picture, media, media-items, light-preview

#let cover-file(cover, items) = {
  let photos = items.filter(item => item.kind == "photo")
  let file = if cover != none { cover } else if photos.len() > 0 { photos.first().file } else { none }
  if file != none {
    assert(media.any(item => item.path == "assets/" + file and "width" in item and "height" in item),
      message: "Album cover is not a known image: " + file)
  }
  file
}

#let album-event(body, id: "", title: "", cover: none) = {
  assert(id != "all-photos" and id != "", message: "Choose a non-empty event id other than all-photos")
  let items = media-items(body)
  (id: id, title: title, body: body, items: items, cover: cover-file(cover, items))
}

#let album-data(title: "", path: "", events: (), cover: none, intro: []) = {
  let ids = events.map(event => event.id)
  assert(ids.dedup().len() == ids.len(), message: "Event ids must be unique within an album")
  let items = media-items(intro) + events.map(event => event.items).flatten()
  (title: title, path: path, events: events, intro: intro, items: items, cover: cover-file(cover, items))
}

#let media-summary(items) = {
  let photos = items.filter(item => item.kind == "photo").len()
  let videos = items.filter(item => item.kind == "video").len()
  let parts = ()
  if photos > 0 { parts.push(str(photos) + if photos == 1 { " photo" } else { " photos" }) }
  if videos > 0 { parts.push(str(videos) + if videos == 1 { " vidéo" } else { " vidéos" }) }
  parts.join(" · ")
}

#let album-card(item, href, events: false) = html.a(class: "album-card", href: href)[
  #if not light-preview {
    html.span(class: "album-cover")[
      #if item.cover != none { picture(item.cover, "Couverture de l’album", thumbnail: true) } else {
        html.span(class: "album-cover-empty")[Album]
      }
    ]
  }
  #html.span(class: "album-card-title")[#{
    show link: item => item.body
    item.title
  }]
  #html.span(class: "album-card-meta")[
    #media-summary(item.items)
    #if events and item.events.len() > 1 { [ · #item.events.len() événements] }
  ]
]

#let album-grid(items) = html.div(class: "album-cards")[
  #for item in items { album-card(item, base + item.path, events: true) }
]

#let album-index(catalog) = {
  let years = catalog.filter(item => item.title.match(regex("^\\d{4}$")) != none)
  let collections = catalog.filter(item => item.title.match(regex("^\\d{4}$")) == none)
  html.p[Des entraînements, des sorties et des rencontres au fil de l’eau.]
  album-grid(years.slice(0, calc.min(6, years.len())))
  if years.len() > 6 {
    html.details(class: "older-albums")[
      #html.summary[Années précédentes · #(years.at(6).title)–#(years.last().title)]
      #album-grid(years.slice(6))
    ]
  }
  if collections.len() > 0 {
    html.h2[Archives et collections]
    album-grid(collections)
  }
}

#let album-page(album) = {
  // Article photo groups stay visible; only album media is omitted in the editor.
  show html.elem.where(tag: "div"): element => if light-preview and element.attrs.at("class", default: "") == "editor-gallery" {
    html.p(class: "editor-media-note")[Photos de la galerie masquées dans l’aperçu de rédaction.]
  } else { element }
  show image: element => if light-preview {
    html.p(class: "editor-media-note")[Image : #element.alt]
  } else { element }

  if album.events.len() > 1 {
    html.div(class: "album-overview")[
      #html.div(class: "album-summary")[
        #html.p[#album.events.len() événements · #media-summary(album.items)]
        #html.a(href: base + album.path + "#all-photos")[#if album.items.any(item => item.kind == "video") { [Tout voir] } else { [Voir les #album.items.len() photos] }]
      ]
      #album.intro
      #html.div(class: "album-cards")[
        #for event in album.events { album-card(event, base + album.path + "#" + event.id) }
      ]
    ]
  } else { album.intro }
  html.div(class: "album-events", id: "all-photos")[
    #for event in album.events {
      html.section(class: "album-event", id: event.id)[
        #html.h2(class: "event-title", event.title)
        #html.p(class: "event-meta", media-summary(event.items))
        #event.body
      ]
    }
  ]
}
