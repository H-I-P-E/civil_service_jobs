library(rvest)
library(purrr)
library(dplyr)
library(tidyr)

emails_folder <- 'emails'
jobs_xpath <- '//p | //h3 | //h2'
column_names = c("job_title", "department", "location", "salary", "grade", "approach", "role_type","closing_date")
raw_data_csv_name <- 'raw_data.csv'

data_frame(filename = dir(emails_folder, pattern = "*.html")) %>%
  mutate(date_downloaded = gsub(".html", "", filename),
         file_contents = map(filename, ~ read_html(paste(emails_folder,.,sep ='\\'))) %>% 
           map(~html_nodes(., xpath = jobs_xpath)) %>%
           map(html_text) %>%
           map(~tail(., -2)) %>%
           map(~head(., -1)) %>%
           map(~data.frame('all_data' = ., 
                           'id' = rep(1:(length(.)%/% length(column_names)), each = length(column_names)),
                           stringsAsFactors = F))) %>%
  unnest %>%
  group_by(id, date_downloaded) %>%
  summarise('all_data' = paste(all_data, collapse ="!!!")) %>%
  separate('all_data', into = column_names, sep = "!!!") %>% 
  ungroup() %>%
  select(-id) %>%
  write.csv(raw_data_csv_name, row.names = F)