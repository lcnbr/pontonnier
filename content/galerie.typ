#import "/theme.typ": *
#show: page.with(title: "Galerie", path: "galerie/")

Des entraînements, des sorties et des rencontres au fil de l’eau.

#gallery[
  #photo("rhone.jpg", "Navigation sur le Rhône")
  #photo("rame.jpg", "Manœuvre à la rame")
  #photo("barque.jpg", "Barque sur le fleuve")
  #photo("equipe.jpg", "L’équipe de navigation")
  #photo("navigation.jpg", "Une sortie des pontonniers")
  #photo("lac.jpg", "Le lac Léman")
  #photo("jonction.jpg", "Les barques à la Jonction")
  #photo("sortie.jpg", "Une sortie du club")
]

== Les albums par année

Retrouvez les sorties, entraînements et compétitions de la société.

#for year in range(2025, 2011, step: -1) [
  - #site-link(if year in (2012, 2015) { "images-" + str(year) + "/" } else { "galerie/images-" + str(year) + "/" })[Images #year]
]

- #site-link("galerie/avant-1950/")[Avant 1960]
- #site-link("galerie/castor/")[Castor]

- #site-link("images-flyer/")[Images et affiches]
