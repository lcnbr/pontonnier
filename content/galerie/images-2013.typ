#import "/theme.typ": *

// Set cover: none to use the first photo instead.
#let album = album-data(
  title: "2013", path: "galerie/images-2013/",
  cover: "archive/2016/10/img_0652-1080x810.jpg",
  events: (
    album-event(
      id: "photos", title: "2013",
      cover: "archive/2016/10/img_0652-1080x810.jpg",
    )[
Descente du Rhone 2013

#gallery[

#photo("archive/2016/10/img_0652-1080x810.jpg", "Images 2013 — photographie 1")

#photo("archive/2016/10/img_0644-1080x810.jpg", "Images 2013 — photographie 2")

#photo("archive/2016/10/img_0647-1080x1440.jpg", "Images 2013 — photographie 3")

#photo("archive/2016/10/img_0641-1080x810.jpg", "Images 2013 — photographie 4")

]
    ],
  ),
)

#show: page.with(title: album.title, path: album.path)
#album-page(album)
