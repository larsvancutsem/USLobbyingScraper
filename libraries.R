## install required packages if necessary
packages <- c("dplyr", "rvest", "httr", "readr", "purrr", "ggplot2", 
              "openxlsx", "jsonlite", "stringr", "withr", "xml2",
              "enc", "plotly", "tibble")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))  
}
lapply(packages, require, character.only = TRUE)
