library(plumber)
library(httr2)
library(jsonlite)

pr("api.R") |> 
  pr_run(host = "0.0.0.0", port = as.numeric(Sys.getenv("PORT", 8000)))
