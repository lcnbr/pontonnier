// Compile as a bundle in CI. Each content file also supports HTML preview.
#let pages = (
  (source: "index", output: "index.html"),
  (source: "histoire", output: "histoire/index.html"),
  (source: "la-societe", output: "la-societe/index.html"),
  (source: "histoire/revival-du-bac-daire", output: "histoire/revival-du-bac-daire/index.html"),
  (source: "la-descente-du-rhone", output: "la-descente-du-rhone/index.html"),
  (source: "sport", output: "sport/index.html"),
  (source: "sport/cours", output: "sport/cours/index.html"),
  (source: "sport/cours/examens-pontonniers", output: "sport/cours/examens-pontonniers/index.html"),
  (source: "sport/materiel", output: "sport/materiel/index.html"),
  (source: "sport/cordages", output: "sport/cordages/index.html"),
  (source: "galerie", output: "galerie/index.html"),
  (source: "origami-weidling", output: "origami-weidling/index.html"),
  (source: "videos", output: "videos/index.html"),
  (source: "contact", output: "contact/index.html"),
  (source: "liens", output: "liens/index.html"),
  (source: "404", output: "404.html"),
  (source: "galerie/images-2025", output: "galerie/images-2025/index.html"),
  (source: "galerie/images-2024", output: "galerie/images-2024/index.html"),
  (source: "galerie/images-2023", output: "galerie/images-2023/index.html"),
  (source: "galerie/images-2022", output: "galerie/images-2022/index.html"),
  (source: "galerie/castor", output: "galerie/castor/index.html"),
  (source: "galerie/images-2021", output: "galerie/images-2021/index.html"),
  (source: "galerie/images-2020", output: "galerie/images-2020/index.html"),
  (source: "sentierdessaules", output: "sentierdessaules/index.html"),
  (source: "galerie/images-2019", output: "galerie/images-2019/index.html"),
  (source: "images-flyer", output: "images-flyer/index.html"),
  (source: "galerie/images-2018", output: "galerie/images-2018/index.html"),
  (source: "apprenez-a-ramer", output: "apprenez-a-ramer/index.html"),
  (source: "galerie/images-2017", output: "galerie/images-2017/index.html"),
  (source: "galerie/images-2014", output: "galerie/images-2014/index.html"),
  (source: "images-2015", output: "images-2015/index.html"),
  (source: "lepoque-gallo-romaine", output: "lepoque-gallo-romaine/index.html"),
  (source: "news", output: "news/index.html"),
  (source: "images-2012", output: "images-2012/index.html"),
  (source: "galerie/images-2013", output: "galerie/images-2013/index.html"),
  (source: "galerie/images-2016", output: "galerie/images-2016/index.html"),
  (source: "galerie/avant-1950", output: "galerie/avant-1950/index.html"),
  (source: "niveau-du-rhone", output: "niveau-du-rhone/index.html"),
  (source: "inscriptions", output: "inscriptions/index.html"),
)
#for entry in pages {
  document(entry.output, include ("content/" + entry.source + ".typ"))
}
#for entry in json("assets/manifest.json") {
  asset(entry.path, read(entry.path, encoding: none))
}
#asset(".nojekyll", bytes(""))
