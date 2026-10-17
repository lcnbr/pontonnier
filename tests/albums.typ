#import "/media.typ": *
#import "/album.typ": *

#let selected = sys.inputs.at("test-cover", default: "rame.jpg")
#let body = [#gallery[#photo("rhone.jpg", "Rhône") #photo("rame.jpg", "Rame")] #video("archive/2022/01/P80_A_x264.mp4", "Navigation")]
#let chosen = album-event(id: "chosen", title: [La #link("https://example.com")[sortie]], cover: selected, body)
#let fallback = album-event(id: "fallback", title: "Autre sortie", body)
#let reordered = album-event(id: "reordered", title: "Réordonné", cover: selected)[#photo("lac.jpg", "Lac") #body]
#let video-only = album-event(id: "video", title: "Vidéo")[#video("archive/2022/01/P80_A_x264.mp4", "Navigation")]
#assert.eq(chosen.cover, selected)
#assert.eq(reordered.cover, selected)
#assert.eq(fallback.cover, "rhone.jpg")
#assert.eq(video-only.cover, none)
#assert.eq(chosen.items.len(), 3)
#assert.eq(media-summary(chosen.items), "2 photos · 1 vidéo")
#let album = album-data(title: "2026", path: "test/", events: (chosen, fallback))
#assert.eq(album.cover, "rhone.jpg")
#assert.eq(album.items.len(), 6)
#assert.eq(album-data(title: "2026", path: "test/", cover: selected, events: (chosen,)).cover, selected)
#html.html[#html.body[#album-page(album) #album-page(album-data(title: "Vidéos", path: "videos/", events: (video-only, chosen)))]]
