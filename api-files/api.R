library(plumber)

#* @get /
#* @serializer unboxedJSON
function(req, res) {
  raw_lat <- req$HTTP_LATITUD
  raw_lon <- req$HTTP_LONGITUD

  if (is.null(raw_lat) || is.null(raw_lon)) {
    res$status <- 400
    return(list(error = "Missing Latitud or Longitud headers"))
  }

  lat <- as.numeric(raw_lat)
  lon <- as.numeric(raw_lon)

  if (is.na(lat) || is.na(lon)) {
    res$status <- 400
    return(list(error = "Invalid Latitud or Longitud values"))
  }

  north <- round(lat + 0.0675, digits = 4)
  south <- round(lat - 0.0675, digits = 4)
  west  <- round(lon - 0.0675, digits = 4)
  east  <- round(lon + 0.0675, digits = 4)

  list(
    north = north,
    south = south,
    west = west,
    east = east
  )
}
