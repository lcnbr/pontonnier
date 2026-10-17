#import "/theme.typ": *
#show: page.with(title: "Niveau du Rhône", path: "niveau-du-rhone/")

Le Rhonomètre présente les mesures du Rhône et de l’Arve. Consultez la date et
l’heure affichées avec chaque mesure.

#html.iframe(class: "rhonometre", src: "https://rhonometre.pontonniers-geneve.ch/",
  title: "Rhonomètre : mesures du Rhône et de l’Arve", loading: "lazy")[]

#link("https://rhonometre.pontonniers-geneve.ch/")[Ouvrir le Rhonomètre en plein écran]
