## initiate scrape
url <- "https://www.senate.gov/legislative/Public_Disclosure/database_download.htm"

pattern <- "td a"
file_list <- html_session(url) %>% html_nodes(pattern) %>% html_attr("href")

lapply(file_list, function(file){
  attempt <- 0
  file_name <- paste0(dir[["raw"]], "/", str_split(file, "/")[[1]][5])
  while( !file.exists(file_name) && attempt <= 10 ) {
    message(paste0("retrieve file: ", file))
    attempt <- attempt + 1
    try(
      tryCatch(download.file(file, file_name),
               warning = function(w) {
                 message(paste0("warning: ", w))
               }, error = function(e) {
                 message(paste0("error: ", e))})
    )
  } 
})


## unzip files
zip_files <- list.files(dir[["raw"]], pattern = "\\.zip", full.names = T)
unpacked_files <- list.files(dir[["raw"]], pattern = "\\d$", full.names = F)
lapply(zip_files, function(zipfile){
  zipfile <- zip_files[[1]]
  temp_name <- zipfile %>% str_extract(pattern = "\\d{4}_\\d+")
  if(!(temp_name %in% unpacked_files)){
    message(paste0("unzipping: ", zipfile))
    unzip(zipfile = zipfile, exdir = str_split(zipfile, "\\.")[[1]][1])
  }
})


rm(zip_files, zip_files, unpacked_files, file_list, pattern, url)
