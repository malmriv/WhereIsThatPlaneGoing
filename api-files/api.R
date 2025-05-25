library(plumber)
library(httr2)
library(jsonlite)


#* @get /
#* @serializer unboxedJSON

#Define request-response function
function(req, res) {
  library(httr2)
  
  lat <- as.numeric(req$HTTP_LATITUD)
  lon <- as.numeric(req$HTTP_LONGITUD)
  
  if (is.na(lat) || is.na(lon)) {
    res$status <- 400
    return(list(error = "Missing or invalid Latitud or Longitud headers"))
  }
  
  north <- round(lat + 0.0675, 4)
  south <- round(lat - 0.0675, 4)
  west  <- round(lon - 0.0675, 4)
  east  <- round(lon + 0.0675, 4)
  
  url <- paste0(
    "https://fr24api.flightradar24.com/api/live/flight-positions/full?",
    "bounds=", north, ",", south, ",", west, ",", east
  )
  
  #Set request, set headers according to FR24 documentation
  req_api <- request(url)
  req_api <- req_headers(req_api,
                         Authorization = paste("Bearer", Sys.getenv("MY_API_KEY")),
                         Accept = "application/json",
                         `Accept-Version` = "v1"
  )
  #Try-catch in case of failure
  resp <- tryCatch(
    req_perform(req_api),
    error = function(e) {
      res$status <- 502
      return(list(error = "Upstream request failed", message = e$message))
    }
  )
  
  #In case of OK execution, this should act as a pass through integration
  if (inherits(resp, "httr2_response")) {
    res$status <- resp_status(resp)
    res$setHeader("Content-Type", resp_header(resp, "Content-Type") %||% "application/json")
    return(resp_body_json(resp))
  } else {
    return(resp)  # The error list from tryCatch
  }
}
