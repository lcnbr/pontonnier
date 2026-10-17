#import "/theme.typ": *

// Set cover: none to use the first photo instead.
#let album = album-data(
  title: "2012", path: "images-2012/",
  cover: "archive/2016/10/img_2143.jpg",
  events: (
    album-event(
      id: "photos", title: "2012",
      cover: "archive/2016/10/img_2143.jpg",
    )[
Echange des bateaux

#gallery[

#photo("archive/2016/10/img_2143.jpg", "Images 2012 — photographie 1")

#photo("archive/2016/10/img_2144.jpg", "Images 2012 — photographie 2")

#photo("archive/2016/10/img_2145.jpg", "Images 2012 — photographie 3")

#html.br()

]
    ],
  ),
)

#show: page.with(title: album.title, path: album.path)
#album-page(album)
