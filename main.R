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
library(DBI)
library(httr)
library(RCurl)

impactful_folder <- 'impactful adverts'
emails_folder <- 'emails'
external_emails_folder <- 'external emails'
adverts_folder <- 'adverts'
lookups_folder <- 'lookups'
data_folder <- 'data'
email_tables <- 'ea emails'

raw_data_csv_name <- file.path(data_folder, 'raw_data.csv')
external_emails_data_csv <- file.path(data_folder, 'raw_external_data.csv')
department_lookup <- file.path(lookups_folder, 'department_remapping.csv')
cleaned_data_csv <- file.path(data_folder, 'basic_advert_data.csv')
role_data_csv <- file.path(data_folder, 'role_data.csv')
grade_data_csv <- file.path(data_folder, 'grade_data.csv')
salary_data_csv <- file.path(data_folder, 'salary_data.csv')
location_data_csv <- file.path(data_folder, 'locations_data.csv')
found_locations_csv <- file.path(data_folder, 'found_locations.csv')
adverts_csv_name <- file.path(data_folder, 'full_advert_data.csv')
missing_data_csv <- file.path(data_folder, 'missing_data.csv')
key_words_csv <- file.path(lookups_folder, 'key_words.csv')
pre_mining_data_csv <- file.path(data_folder, 'job_description_with_cause_areas.csv')
key_words_results_file <- file.path(data_folder, 'key_words_results_full.csv')
key_words_summary_file <- file.path(data_folder, 'key_words_summary.csv')
competencies_file <- file.path(lookups_folder, 'competencies.csv')
manual_locations_file <- file.path(lookups_folder, 'manually_matched_locations.csv')
specific_locations_file <- file.path(lookups_folder, 'specific_location_searches.csv')
post_code_locations_file <- file.path(lookups_folder, 'postcode_locations.csv')
region_lookup_file <- file.path(lookups_folder, 'region_lookup.csv')
adverts_for_80k <- file.path(email_tables, 'jobs_for_80k_jobs_board.csv')

competency_data_file <- file.path(data_folder, 'competency_data.csv')
#jobsdb <- dbConnect(RSQLite::SQLite(), file.path(data_folder, "jobs_db.sqlite"))

#Set proxy if necessary
proxy_file <- "proxy_url.txt"

if(file.exists(proxy_file)){
  proxy_url <- read_file(proxy_file)
  set_config(use_proxy(url = proxy_url, port = 8080))
}

#data
source('R_data//functions.R')
source('R_data//create_csv_from_html_emails.R')
source('R_data//clean_data.R')
source('R_data//parse_locations.R')
source('R_data//scrape_adverts.R')
source('R_data//create_csv_from_html_adverts.R')

#analysis
source('R_analysis//find_adverts_with_keys_words.R')
source('R_analysis//ea_community_emails.R')
