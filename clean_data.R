library(readr)
library(lubridate)
library(stringr)
library(dplyr)
library(tidyr)

raw_data_csv_name <- 'data\\raw_data.csv'
cleaned_data_csv <- 'data\\cleaned_advert_data.csv'
role_data_csv <- 'data\\role_data.csv'
grade_data_csv <- 'data\\grade_data.csv'
salary_data_csv <- 'data\\salary_data.csv'

if(!file.exists(raw_data_csv_name)){
  source('create_csv_from_html_emails.R')
}

all_advert_data <- read_csv(raw_data_csv_name) %>%
  mutate(closing_date = dmy(gsub("Closing Date: ", "", closing_date)),
         date_downloaded = ymd(date_downloaded),
         grade = gsub("Grade: ", "", grade),
         approach = gsub("Approach: ", "", approach),
         location = gsub("Location: ", "", location),
         salary = gsub("Salary: ", "", salary),
         role_type = sub("Role Type: ", "", role_type),
         job_id = str_extract(link, '[[:digit:]]{7,}')) %>%
         write_csv(cleaned_data_csv)

role_types <- all_advert_data %>%
  subset(select = c(job_id, role_type)) %>%
  mutate(role_type = strsplit(role_type, ",")) %>% 
  unnest(role_type) %>%
  mutate(role_type = trimws(role_type)) %>%
  write_csv(role_data_csv)

grades <-  all_advert_data %>%
  subset(select = c(job_id, grade)) %>%
  mutate(grade = strsplit(grade, ",")) %>% 
  unnest(grade) %>%
  mutate(grade = trimws(grade)) %>%
  write_csv(grade_data_csv)
 
salaries <-  all_advert_data %>%
  subset(select = c(job_id, salary)) %>%
  mutate(salary = str_extract_all(salary, "[:digit:]{2,3}.?,? ?[:digit:]{3}")) %>% 
  unnest(salary) %>%
  mutate(salary = as.numeric(gsub('\\.|,| ', '', salary))) %>%
  na.omit %>%
  write_csv(salary_data_csv)

