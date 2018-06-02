library(rvest)
library(purrr)
library(tidyr)
library(XML)
library(readr)
library(lubridate)
library(stringr)
library(dplyr)
library(downloader)
library(xml2)

impactful_folder <- 'impactful adverts'
emails_folder <- 'emails'
adverts_folder <- 'adverts'
lookups_folder <- 'lookups'
data_folder <- 'data'
email_tables <- 'ea emails'

raw_data_csv_name <- file.path(data_folder, 'raw_data.csv')
department_lookup <- file.path(lookups_folder, 'department_remapping.csv')
cleaned_data_csv <- file.path(data_folder, 'cleaned_advert_data.csv')
role_data_csv <- file.path(data_folder, 'role_data.csv')
grade_data_csv <- file.path(data_folder, 'grade_data.csv')
salary_data_csv <- file.path(data_folder, 'salary_data.csv')
adverts_csv_name <- file.path(data_folder, 'all_full_advert_data.csv')
missing_data_csv <- file.path(data_folder, 'missing_data.csv')
key_words_csv <- file.path(lookups_folder, 'key_words.csv')
pre_mining_data_csv <- file.path(data_folder, 'job_description_with_cause_areas.csv')
key_words_results_file <- file.path(data_folder, 'key_words_results_full.csv')
key_words_summary_file <- file.path(data_folder, 'key_words_summary.csv')
competencies_file <- file.path(lookups_folder, 'competencies.csv')
competency_data_file <- file.path(data_folder, 'competency_data.csv')

#data
source('R_data//create_csv_from_html_emails.R')
source('R_data//clean_data.R')
source('R_data//scrape_adverts.R')
source('R_data//create_csv_from_html_adverts.R')

#analysis
source('R_analysis//find_adverts_with_keys_words.R')
source('R_analysis//ea_community_emails.R')
