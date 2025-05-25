library(plumber)

#* @get /
#* @serializer unboxedJSON
function(req, res) {
  lat <- req$HTTP_LATITUD
  lon <- req$HTTP_LONGITUD
  
  if (is.null(lat) || is.null(lon)) {
    res$status <- 400
    return(list(error = "Missing Latitud or Longitud headers"))
  }
  
  list(latitud = lat, longitud = lon)
}
