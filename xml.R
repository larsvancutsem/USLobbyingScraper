## unpack xml files


## retrieve files in recursive folder search
xml_files <- list.files(dir[["raw"]], pattern = "\\.xml", recursive=T, full.names=T)
csv_files <- list.files(dir[["csv"]], full.names = F)


## extract xml files to csv tables
for(xml_file in xml_files){
  file_name <- xml_file %>% str_split("/") %>% unlist() %>% last() %>% gsub(pattern = "\\.xml", replacement = "\\.csv")
  if(!(file_name %in% csv_files)){
    
    start <- Sys.time()

    message(paste0("parsing file: ", xml_file))
    doc <- read_xml(xml_file)
    
    parse_xml <- function(x) {x %>% paste0(collapse="|")}
    df <- xml_find_all(doc, ".//Filing") %>%
      map_df(function(x) {
        f_iss <- xml_find_all(x, './Issues/Issue')
        f_cli <- xml_find_all(x, './Client')
        f_reg <- xml_find_all(x, './Registrant')
        f_lob <- xml_find_all(x, './Lobbyists/Lobbyist')
        f_gov <- xml_find_all(x, './GovernmentEntities/GovernmentEntity')
        list( 
          ID = xml_attr(x, 'ID'),
          Year = xml_attr(x, "Year"),
          Received = xml_attr(x, "Received"),
          Amount = xml_attr(x, "Amount"),
          Type = xml_attr(x, "Type"),
          Period = xml_attr(x, "Period"),
          
          IssueCode = f_iss %>% xml_attr("Code") %>% parse_xml(),
          SpecificIssue = f_iss %>% xml_attr("SpecificIssue") %>% parse_xml(),
          
          ClientName = f_cli %>% xml_attr("ClientName"),
          ClientGeneralDescription = f_cli %>% xml_attr("GeneralDescription"),
          ClientID = f_cli %>% xml_attr("ClientID"),
          SelfFiler = f_cli %>% xml_attr("SelfFiler"),
          ContactFullname = f_cli %>% xml_attr("ContactFullname"),
          IsStateOrLocalGov = f_cli %>% xml_attr("IsStateOrLocalGov"),
          ClientCountry = f_cli %>% xml_attr("ClientCountry"),
          ClientPPBCountry = f_cli %>% xml_attr("ClientPPBCountry"),
          ClientState = f_cli %>% xml_attr("ClientState"),
          ClientPPBState = f_cli %>% xml_attr("ClientPPBState"),
          
          RegistrantID = f_reg %>% xml_attr("RegistrantID"),
          RegistrantName = f_reg %>% xml_attr("RegistrantName"),
          RegistrantGeneralDescription = f_reg %>% xml_attr("GeneralDescription"),
          Address = f_reg %>% xml_attr("Address"),
          RegistrantCountry = f_reg %>% xml_attr("RegistrantCountry"),
          RegistrantPPBCountry = f_reg %>% xml_attr("RegistrantPPBCountry"),
          
          LobbyistName = f_lob %>% xml_attr("LobbyistName") %>% parse_xml(),
          LobbyistCoveredGovPositionIndicator = f_lob %>% xml_attr("LobbyistCoveredGovPositionIndicator") %>% parse_xml(),
          OfficialPosition = f_lob %>% xml_attr("OfficialPosition") %>% parse_xml(),
          
          GovEntName = f_gov %>% xml_attr("GovEntityName") %>% parse_xml()
        ) %>% return()
      })
    
    # tryCatch loop to create csv file
    attempt <- 0
    message(paste0("writing: ", file_name, "\n"))
    while(!file.exists(paste0(dir[["csv"]], '/', file_name))) {
      Sys.sleep(1)
      attempt <- attempt + 1
      try(
        tryCatch(write.csv(df, paste0(dir[["csv"]], '/', file_name)),
                 warning = function(w) {
                   message(paste0("warning: ", w))
                 }, error = function(e) {
                   message(paste0("error: ", e))})
      )
    }
    
    message(paste0("Duration was: ", Sys.time() - start, "\n"))
  }
}

rm(xml_files, csv_files, xml_file, file_name)
