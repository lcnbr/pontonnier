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

Les albums complets sont conservés sur le site d’origine.

#for year in range(2025, 2012, step: -1) [
  - #link("https://www.pontonniers-geneve.ch/" + if year == 2015 { "images-2015/" } else { "galerie/images-" + str(year) + "/" })[Images #year]
]

- #link("https://www.pontonniers-geneve.ch/galerie/avant-1950/")[Avant 1960]
- #link("https://www.pontonniers-geneve.ch/galerie/castor/")[Castor]
