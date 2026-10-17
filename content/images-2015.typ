#import "/theme.typ": *

// Set cover: none to use the first photo instead.
#let album = album-data(
  title: "2015", path: "images-2015/",
  cover: "archive/2016/12/img_3079_b-1080x810.jpg",
  events: (
    album-event(
      id: "photos", title: "2015",
      cover: "archive/2016/12/img_3079_b-1080x810.jpg",
    )[
Crue centennale de l’Arve en Mai 2015

#photo("archive/2016/12/arve_2015_rudhard.jpg", "L'Arve, 04.05.2015", caption: [L’Arve, 04.05.2015. Photo: F. Rudhard, #link("http://www.notrehistoire.ch/medias/3106")[Source]])

#html.hr()

#link("http://www.pontonier.ch/cms/wettkaempfe-2013/42-wettkfe/wettkaempfe-2015/729-eidg-wettfahren.html")[39. Eidgenössisches Wettfahren 2015 in Mumpf]

#gallery[

#photo("archive/2016/12/img_3079_b-1080x810.jpg", "Images 2015 — photographie 2")

#photo("archive/2016/12/img_3078_b-1080x810.jpg", "Images 2015 — photographie 3")

#photo("archive/2016/12/img_3076_b-1080x810.jpg", "Images 2015 — photographie 4")

]
    ],
  ),
)

#show: page.with(title: album.title, path: album.path)
#album-page(album)
