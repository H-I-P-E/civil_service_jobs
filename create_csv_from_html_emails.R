library(rvest)
library(purrr)
library(dplyr)
library(tidyr)

jobs_xpath <- '//p | //h3 | //h2'
column_names = c("job_title", "department", "location", "salary", "grade", "approach", "role_type","closing_date")

emails_folder <- 'emails'
data <- emails_folder %>%
  dir(pattern = "*.html") %>%
  map(~read_html(paste(emails_folder,.,sep ='\\'))) %>%
  map(~html_nodes(., xpath = jobs_xpath)) %>%
  map(html_text) %>%
  map(~tail(., -2)) %>%
  map(~head(., -1)) %>%
  map(~data.frame('all_data' = ., 
                  'id' = rep(1:(length(.)%/%8), each = 8),
                  stringsAsFactors = F)) %>%
  map(~group_by(., id)) %>%
  map(~summarise(., 'all_data' = paste(all_data, collapse ="!!!"))) %>%
  map(~separate(., 'all_data', into = column_names, sep = "!!!")) %>%
  reduce(bind_rows)

