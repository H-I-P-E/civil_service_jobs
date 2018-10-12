source('user_name_and_password.R') #This file will need to contain your csj username and password for this script to run

my_session <- log_in_session(username, password)

download_page_logged_in <- Vectorize(function(job_ref){
  file_name <- paste(adverts_folder, '\\', job_ref, '.html', sep = '')
  print(file_name)
  if(!file.exists(file_name)){
  job_url <- paste("https://www.civilservicejobs.service.gov.uk/csr/jobs.cgi?jcode=",job_ref,"&csource=csalerts", sep = "")
  job_url_session <- jump_to(my_session, job_url)
  job_html <- read_html(job_url_session)
  write_xml(job_html, file_name)
  Sys.sleep(1)}
  return(file_name)
})

all_adverts <- read_csv(cleaned_data_csv) %>%
  select(job_id,link) %>%
  mutate(full_advert_file = download_page_logged_in(job_id))



