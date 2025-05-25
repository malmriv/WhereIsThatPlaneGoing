library(plumber)
library(httr2)
library(jsonlite)

#* @get /
#* @serializer unboxedJSON

#Define request-response function
function(req, res) {
  #Read airport information
  airports <- read.csv("ListaAeropuertos.csv", sep = ";", stringsAsFactors = FALSE,fileEncoding = "UTF-8")
  
  #Read request headers
  lat <- as.numeric(req$HTTP_LATITUD)
  lon <- as.numeric(req$HTTP_LONGITUD)
  
  if (is.null(lat) || is.null(lon)) {
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
    content <- resp_body_json(resp)
    # Check if data is empty or missing
    if (is.null(content$data) || length(content$data) == 0) {
      return(list(Mensaje = "No se encuentra a ningún avión a 7 km a la redonda :("))
    }
    else {
      
      #Aquí está toda la lógica para elaborar el mensaje. Solo lee el primer avión,
      #manejar casos con múltiples resultados en versiones posteriores.
      first_flight <- content$data[[1]]
      orig_icao <- first_flight$orig_icao
      dest_icao <- first_flight$dest_icao
      orig_airport <- airports[airports$icao_code == orig_icao, ]
      dest_airport <- airports[airports$icao_code == dest_icao, ]
      get_airport_info <- function(df) {
        if (nrow(df) == 0) {
          return("aeropuerto desconocido")
        } else {
          paste0(df$name, " (", df$municipality, ", ", df$iso_country, ")")
        }
      }
      
      origin_info <- get_airport_info(orig_airport)
      dest_info <- get_airport_info(dest_airport)
      
      mensaje <- paste0(
        "Este avión vuela desde ", origin_info,
        " hacia ", dest_info, "."
      )
      return(list(Mensaje = mensaje))
    }
    
    return(content)
  } else {
    return(resp)  # The error list from tryCatch
  }
}
