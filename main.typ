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
)
#for entry in pages {
  document(entry.output, include ("content/" + entry.source + ".typ"))
}
#asset(".nojekyll", bytes(""))
