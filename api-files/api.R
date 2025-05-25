install.packages("plumber")
install.packages("httr2")
install.packages("jsonlite")

library(plumber)
library(httr2)
library(jsonlite)

#* @get /
#* @serializer unboxedJSON
function(req, res) {
  # Step 1: Get headers
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

  # Step 2: Compute bounding box
  north <- round(lat + 0.0675, 4)
  south <- round(lat - 0.0675, 4)
  west  <- round(lon - 0.0675, 4)
  east  <- round(lon + 0.0675, 4)

  # Step 3: Load token from env
  api_token <- Sys.getenv("MY_API_KEY")
  if (identical(api_token, "")) {
    res$status <- 500
    return(list(error = "API token not configured"))
  }

  # Step 4: Build and send request
  url <- "https://fr24api.flightradar24.com/api/live/flight-positions/full"
  req_flights <- request(url) |>
    req_url_query(bounds = paste(north, south, west, east, sep = ",")) |>
    req_headers(
      Authorization = paste("Bearer", api_token),
      Accept = "application/json",
      `Accept-Version` = "v1"
    )

  resp <- tryCatch(
    req_perform(req_flights),
    error = function(e) {
      res$status <- 502
      return(list(error = "Failed to contact FlightRadar24 API", detail = e$message))
    }
  )

  # Step 5: Parse and return the response
  if (inherits(resp, "response")) {
    content <- resp_body_json(resp)
    return(content)  # Return raw or processed JSON
  } else {
    return(resp)  # Error object
  }
}
