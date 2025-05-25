library(plumber)

pr_obj <- pr("api.R")
pr_run(pr_obj, host = "0.0.0.0", port = as.numeric(Sys.getenv("PORT", 8000)))
