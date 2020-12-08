## create dataframe and clean


if(!grepl("clean_data", list.files(dir[["dat"]]))){
  
  ## intial retrieval
  files <- list.files(dir[["csv"]], full.names = T)
  data <- lapply(files, read_csv) %>% bind_rows()
  
  
  ## clean data (as clean_data)
  #' Here, we split the lobbying filings by IssueCode (assume that the Amount 
  #' contributed can be divided linearly corresponding to the Issues the Client 
  #' is lobbying for).
  
  IssueCode_temp <- str_split(data$IssueCode, "\\|")
  SpecificIssue_temp <- str_split(data$SpecificIssue, "\\|")
  n_temp <- lapply(IssueCode_temp, length) %>% unlist()
  Amount_temp <- rep(data$Amount/n_temp, n_temp)
  
  # SpecificIssues where split on char "|" did not work -> full set of specific Issues
  id_nomatch <- which(lapply(IssueCode_temp, length) %>% unlist() != lapply(SpecificIssue_temp, length) %>% unlist())
  SpecificIssue_temp[id_nomatch] <- lapply(id_nomatch, function(x) {rep(data$SpecificIssue[x], n_temp[x])})
  
  clean_data <- data[rep(seq_len(nrow(data)), n_temp), ]
  clean_data$IssueCode <- IssueCode_temp %>% unlist()
  clean_data$SpecificIssue <- SpecificIssue_temp %>% unlist()
  clean_data$Amount <- Amount_temp
  
  ## clean up memory
  rm(data, IssueCode_temp, SpecificIssue_temp, files)
  
  ## match to firm identifiers
  match <- read_csv("data/match.csv")
  bvd_id <- match$`Matched BvD ID`[match(clean_data$ClientName, match$`Company name`)]
  clean_data <- add_column(clean_data, BVD_ID = bvd_id, .after = "ClientName")
  
  ## write dataframe
  ids <- clean_data$Year %>% unique() %>% sort()
  lapply(ids, function(x) write_csv2(clean_data[clean_data$Year == x, ], 
                                     paste0(dir[["dat"]], "/clean_data", x, ".csv")))
  
} else {
  files <- list.files(dir[["dat"]], "\\d.csv", full.names = T)
  clean_data <- lapply(files, read_csv2) %>% bind_rows()
}


