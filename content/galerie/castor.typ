#import "/theme.typ": *

// Set cover: none to use the first photo instead.
#let album = album-data(
  title: "Castor", path: "galerie/castor/",
  cover: "archive/2022/01/IMG_9659-1024x768.jpg",
  events: (
    album-event(
      id: "presentation", title: "Castor",
      cover: "archive/2022/01/IMG_9659-1024x768.jpg",
    )[
#photo("archive/2022/09/DJI_0424_d.jpg", "Castor — photographie 1")
    ],
    album-event(
      id: "31122021", title: [#strong[Sortie fin d’année]],
      cover: "archive/2022/01/IMG_9659-1024x768.jpg",
    )[
#video("archive/2022/01/P80_C_x264_001.mp4", "Castor — vidéo")

#video("archive/2022/01/P80_A_x264.mp4", "Castor — vidéo")
    ],
    album-event(
      id: "15122021", title: [#strong[Sortie nocturne]],
      cover: "archive/2022/01/IMG_9659-1024x768.jpg",
    )[
#gallery[

#photo("archive/2022/09/DJI_0424_d.jpg", "Castor — photographie 2")

#photo("archive/2022/01/IMG_9669-768x1024.jpg", "Castor — photographie 3")

#photo("archive/2022/01/IMG_9659-1024x768.jpg", "Castor — photographie 4")

#photo("archive/2022/01/IMG_9667-1152x1536.jpg", "Castor — photographie 5")

]
    ],
    album-event(
      id: "09122021", title: [#strong[L’arrivée de Castor]],
      cover: "archive/2021/12/IMG_9443.jpg",
    )[
#gallery[

#photo("archive/2021/12/IMG_9443.jpg", "Castor — photographie 6")

#photo("archive/2021/12/IMG_9462.jpg", "Castor — photographie 7")

#photo("archive/2021/12/IMG_9465.jpg", "Castor — photographie 8")

#photo("archive/2021/12/IMG_9472.jpg", "Castor — photographie 9")

#photo("archive/2021/12/IMG_9540.jpg", "Castor — photographie 10")

#photo("archive/2021/12/IMG_9525.jpg", "Castor — photographie 11")

#photo("archive/2021/12/IMG_9487.jpg", "Castor — photographie 12")

#photo("archive/2021/12/IMG_9556.jpg", "Castor — photographie 13")

#photo("archive/2021/12/IMG_9585.jpg", "Castor — photographie 14")

#photo("archive/2021/12/IMG_9598.jpg", "Castor — photographie 15")

]

#video("archive/2021/12/IMG_9446_x264.mp4", "Castor — vidéo")

#video("archive/2021/12/IMG_9474_x264.mp4", "Castor — vidéo")

#video("archive/2021/12/IMG_9496_x264.mp4", "Castor — vidéo")

#video("archive/2021/12/IMG_9587_x264.mp4", "Castor — vidéo")

#video("archive/2021/12/IMG_9594_x264.mp4", "Castor — vidéo")
    ],
  ),
)

#show: page.with(title: album.title, path: album.path)
#album-page(album)
