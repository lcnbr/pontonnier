// Shared content and navigation. Paths are relative to the website root.
#let published-url = "https://lcnbr.github.io/pontonnier/"
#let name = "Pontonnier·ère·s de Genève"
#let motto = "Rhodanus Et Lemanus"
#let email = "info@pontonniers-geneve.ch"
#let instagram = "https://www.instagram.com/pontonniers_geneve/"
// One album inventory supplies the year menu in the navbar.
#let albums = ((title: "Tous les albums", path: "galerie/"),) + range(2025, 2011, step: -1).map(year => (
  title: str(year),
  path: if year in (2012, 2015) { "images-" + str(year) + "/" }
    else { "galerie/images-" + str(year) + "/" },
)) + (
  (title: "Avant 1960", path: "galerie/avant-1950/"),
  (title: "Castor", path: "galerie/castor/"),
  (title: "Images et affiches", path: "images-flyer/"),
)
#let navigation = (
  (title: "Accueil", path: ""),
  (title: "Histoire", path: "histoire/", children: (
    (title: "Histoire", path: "histoire/"),
    (title: "La Société", path: "la-societe/"),
    (title: "L’époque gallo-romaine", path: "lepoque-gallo-romaine/"),
    (title: "Le bac d’Aïre", path: "histoire/revival-du-bac-daire/"),
    (title: "La descente du Rhône", path: "la-descente-du-rhone/"),
  )),
  (title: "Sport", path: "sport/", children: (
    (title: "Sport", path: "sport/"),
    (title: "Cours de Navigation", path: "sport/cours/"),
    (title: "Examens Pontonniers", path: "sport/cours/examens-pontonniers/"),
    (title: "Matériel", path: "sport/materiel/"),
    (title: "Cordages", path: "sport/cordages/"),
    (title: "Vidéos", path: "videos/"),
  )),
  (title: "Galerie", path: "galerie/", children: albums),
  (title: "Apprenez à ramer!", path: "sport/cours/"),
  (title: "Origami-Weidling", path: "origami-weidling/"),
  (title: "Contact", path: "contact/"),
  (title: "Liens", path: "liens/"),
)

// A random river view is kept throughout a visit. Media stays in the pinned archive.
#let backgrounds = (
  "archive/2025/02/IMG_E0535-1024x957.jpg",
  "archive/2021/08/QZYJ8260.jpg",
  "archive/2025/08/POYQ5872.jpg",
  "archive/2025/08/IMG_3243-1152x1536.jpg",
  "archive/2025/08/YJLM7520.jpg",
  "archive/2025/02/YBNP4270.jpg",
  "archive/2025/02/ENVBE2445-1259x2048.jpg",
  "archive/2023/10/MKED6965.jpg",
  "archive/2021/08/UZEDE9072.jpg",
)
#let rhonometre-url = "https://rhonometre.pontonniers-geneve.ch/?embed=1&station=2606&background=transparent&branding=0"
