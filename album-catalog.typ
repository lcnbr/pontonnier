#import "site.typ": albums

// The navbar registry already contains every album's source path.
#let album-catalog = albums.slice(1).map(entry => {
  import ("content/" + entry.path.trim("/") + ".typ") as source
  source.album
})
