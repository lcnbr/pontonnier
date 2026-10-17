// Shared content and navigation. Paths are relative to the website root.
#let name = "Pontonnier·ère·s de Genève"
#let motto = "Rhodanus Et Lemanus"
#let email = "info@pontonniers-geneve.ch"
#let instagram = "https://www.instagram.com/pontonniers_geneve/"
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
  (title: "Galerie", path: "galerie/", children: (
    (title: "Tous les albums", path: "galerie/"),
    (title: "Images 2025", path: "galerie/images-2025/"),
    (title: "Images 2024", path: "galerie/images-2024/"),
    (title: "Castor", path: "galerie/castor/"),
    (title: "Avant 1960", path: "galerie/avant-1950/"),
  )),
  (title: "Apprenez à ramer!", path: "sport/cours/"),
  (title: "Origami-Weidling", path: "origami-weidling/"),
  (title: "Contact", path: "contact/"),
  (title: "Liens", path: "liens/"),
)
