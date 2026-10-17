#import "/theme.typ": *
#import "/site.typ": instagram
#show: page.with(title: "Accueil", path: "")

#section("instagram")[
  Suivez nos aventures sur\
  #link(instagram)[INSTAGRAM #"@pontonniers_geneve"]
]

#section("news-label")[NEWS:]
#section("news")[
  *26.06.2025* #link("https://www.pontonniers-geneve.ch/galerie/images-2025/#26062025")[Eidgenössisches Pontonier Wettfahren 2025 Schmerikon]

  *14.06.2025* #link("https://www.pontonniers-geneve.ch/galerie/images-2025/#14062025")[Wettfahren Wynau]

  *15.05.2025* #link("https://www.pontonniers-geneve.ch/galerie/images-2025/#15052025")[GRIMP Day 2025]
]
#html.hr()

#section("introduction")[
  Sur le Rhône et le lac Léman, la navigation en barque à fond plat appartient à une
  #site-link("histoire/")[longue histoire]. La Société des Pontonnier·ère·s de Genève
  fait vivre cette tradition au fil des saisons. Nous remontons le fleuve à la gaffe,
  le traversons à la rame et partageons le plaisir de naviguer au cœur de Genève.

  Nos #site-link("sport/cours/")[cours de navigation] accueillent les jeunes comme
  les adultes. Venez découvrir le Rhône depuis l’eau et apprendre à manœuvrer
  un Weidling en équipe.
]

#section("join")[#site-link("sport/cours/")[Venez ramer avec nous!]]

#gallery[
  #photo("rhone.jpg", "Navigation en barque sur le Rhône")
  #photo("rame.jpg", "Manœuvre à la rame à Genève")
  #photo("barque.jpg", "Un Weidling sur le fleuve")
  #photo("equipe.jpg", "Les pontonniers en équipe")
  #photo("navigation.jpg", "Une sortie sur l’eau")
  #photo("lac.jpg", "Navigation sur le lac Léman")
  #photo("jonction.jpg", "Les barques à la Jonction")
  #photo("sortie.jpg", "Sortie des pontonniers de Genève")
]

#html.iframe(
  class: "rhonometre", src: "https://rhonometre.pontonniers-geneve.ch/",
  title: "Rhonomètre : mesures du Rhône", loading: "lazy",
)[#link("https://rhonometre.pontonniers-geneve.ch/")[Consulter le Rhonomètre]]

#link("https://rhonometre.pontonniers-geneve.ch/")[Ouvrir le Rhonomètre]
