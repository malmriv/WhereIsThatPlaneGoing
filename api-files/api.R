library(plumber)

#* @get /
#* @serializer unboxedJSON
function(req, res) {
  lat <- as.numeric(req$HTTP_LATITUD)
  lon <- as.numeric(req$HTTP_LONGITUD)

  if (is.na(lat) || is.na(lon)) {
    res$status <- 400
    return(list(error = "Missing or invalid Latitud or Longitud headers"))
  }

  north <- lat + 0.135
  south <- lat - 0.135
  west  <- lon - 0.135
  east  <- lon + 0.135

  list(
    north = north,
    south = south,
    west = west,
    east = east
  )
}
