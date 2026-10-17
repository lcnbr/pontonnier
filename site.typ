// Shared content and navigation. Paths are relative to the website root.
#let name = "Pontonnier·ère·s de Genève"
#let motto = "Rhodanus Et Lemanus"
#let email = "info@pontonniers-geneve.ch"
#let instagram = "https://www.instagram.com/pontonniers_geneve/"
// The gallery picker and main menu share one album inventory.
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
