## set locale language and appropriate date format
Sys.setlocale("LC_TIME", "English")


## specify relative directories
dir <- list()
dir[["raw"]] <- paste0(getwd(), "/raw")
dir[["csv"]] <- paste0(getwd(), "/csv")
dir[["dat"]] <- paste0(getwd(), "/data")
lapply(dir, function(x) dir.create(file.path(x), showWarnings = F))
