source('user_name_and_password.R') #This file will need to contain your csj username and password for this script to run

my_session <- log_in_session(username, password)

existing_files <- list.files(adverts_folder, pattern = "*.html", recursive = TRUE, include.dirs = FALSE) %>%
  map(~str_extract(.,"[:digit:]{7,}.html"))

existing_ids <- existing_files %>% map(~str_extract(.,"[:digit:]{7,}"))

download_page_logged_in <- Vectorize(function(job_ref,date_downloaded){
  folder <- file.path(adverts_folder, 
                      year(date_downloaded), 
                      month(date_downloaded, label = TRUE)) 
  file_name <- paste(job_ref, 'html', sep = '.')
  if(!(file_name %in% existing_files)){
    print(paste("Downloading job:",job_ref))
    dir.create <- dir.create(folder, recursive = T, showWarnings = F)
    file_path <- file.path(folder, file_name)
    job_url <- paste("https://www.civilservicejobs.service.gov.uk/csr/jobs.cgi?jcode=",job_ref,"&csource=csalerts", sep = "")
    job_url_session <- jump_to(my_session, job_url)
    job_html <- read_html(job_url_session)
    write_xml(job_html, file_path)
    }
  return(file_name)
})

curlSetOpt(timeout = 20000)
all_adverts <- read_csv(cleaned_data_csv) %>%
  select(job_id, date_downloaded) %>%
  filter(!(job_id %in% existing_ids)) %>%
  mutate(full_advert_file = download_page_logged_in(job_id, date_downloaded))
