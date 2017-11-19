library(readr)
library(lubridate)
library(stringr)

raw_data_csv_name <- 'data\\raw_data.csv'
cleaned_data_csv <- 'data\\cleaned_data.csv'

if(!file.exists(raw_data_csv_name)){
  source('create_csv_from_html_emails.R')
}

read_csv(raw_data_csv_name) %>%
  mutate(closing_date = gsub("Closing Date: ", "", closing_date)) %>%
  mutate(closing_date = dmy(closing_date)) %>%
  mutate(date_downloaded = ymd(date_downloaded)) %>%
  mutate(grade = gsub("Grade: ", "", grade)) %>%
  mutate(approach = gsub("Approach: ", "", approach)) %>%
  write.csv(cleaned_data_csv, row.names = F)
