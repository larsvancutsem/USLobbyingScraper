## dataset U.S. lobbying disclosures


## set directory to file directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


## source required libraries and environment
source("libraries.R")
source("env.R")


## retrieve xml files public disclosures on lobbying
source("scrape.R")


## unpack xml files to tables
source("xml.R")


## create dataframe and clean
source("data.R")



### plot interlude #############################################################
visual <- clean_data[as.Date(clean_data$Received) >= as.Date("01/07/2018", format = "%d/%m/%Y") & 
           as.Date(clean_data$Received) <= as.Date("07/07/2018", format = "%d/%m/%Y"), ]
visual <- visual[which(visual$Amount > 0 & (visual$ClientCountry %in% c("USA"))), ]
visual$IssueCode <- with(visual, reorder(IssueCode, Amount, sum))

p <- visual %>% ggplot(aes(Received, IssueCode, color = ClientState, size = Amount, label = ClientName)) +
  geom_point() + theme_bw()
ggplotly(p)
################################################################################

