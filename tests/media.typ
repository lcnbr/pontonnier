#import "/media.typ": *
#let selected = sys.inputs.at("test-photo", default: "rhone.jpg")
#let destination = sys.inputs.at("test-destination", default: none)
#html.html[#html.body[
  #if sys.inputs.at("test-kind", default: "photo") == "picture" {
    picture(selected, "Photo de test")
  } else { photo(selected, "Photo de test", destination: destination) }
]]
