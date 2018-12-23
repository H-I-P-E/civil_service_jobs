get_long_lat_from_postcode <- function(postcode, is_outcode = F){
  if(is_outcode){
    get_request <- paste("api.postcodes.io/outcodes/", postcode, sep = "")
  }else(get_request <- paste("api.postcodes.io/postcodes/", postcode, sep = ""))
  request_data <- GET(get_request)
  request_result<- content(request_data)[['result']]
  if(is.null(request_result$longitude[1])){
    if(is_outcode){
      return(NULL)}
    outcode <- str_extract(postcode, outcode_regex)
    outcode_row <- get_long_lat_from_postcode(outcode, is_outcode = T)
    outcode_row$postcode <- postcode
    return(outcode_row)
  }
  row <- tibble(postcode = postcode, 
                long = request_result$longitude[1],
                lat = request_result$latitude[1])
  return(row)
}

log_in_session <- function(my_username, my_password){
  login_url <- "https://www.civilservicejobs.service.gov.uk/csr/login.cgi"
  session <- html_session(login_url)
  form <- html_form(read_html(login_url))[[1]]
  filled_form <- set_values(form,
                            username = my_username,
                            password_login_window = my_password)
  submit_form(session, filled_form)
  return(session)
}

remove_parents <- function(table_of_regions, parent_lookup){
  table_with_parents <- table_of_regions %>%
    left_join(parent_lookup, by = c("region" = "region"))
  table_of_regions %>%
    filter(!(region %in% table_with_parents$parents))
}

create_csv_from_html_emails <- function(my_email_folder, csv_name){
  if(file.exists(csv_name)){
    previous_extracted_data <- read_csv(csv_name)
    previous_extracted_dates <- previous_extracted_data$date_downloaded
  }else{
    previous_extracted_data <- NULL
    previous_extracted_dates <- c()}
  
  new_email_data <- data_frame(filename = dir(my_email_folder, pattern = "*.html")) %>%
    mutate(date_downloaded = gsub(".html", "", filename)) %>%
    filter(!(date_downloaded %in% previous_extracted_dates)) %>%
    mutate(file_contents = map(filename, ~ read_html(paste(my_email_folder,.,sep ='\\'))) %>% 
             map(~html_nodes(., xpath = jobs_xpath)) %>%
             map(~ ifelse(is.na(html_attr(., 'href')),html_text(.),html_attr(., 'href'))) %>%
             map(~head(., -1)) %>%
             map(~tail(., -2)) %>%
             map(~data.frame('all_data' = .[1:length(.)-length(.)%% length(column_names)],
                             'id' = rep(1:(length(.)%/% length(column_names)), each = length(column_names)),
                             stringsAsFactors = F))) %>%
    unnest %>%
    group_by(id, date_downloaded) %>%
    summarise('all_data' = paste(all_data, collapse ="!!!")) %>%
    separate('all_data', into = column_names, sep = "!!!") %>% 
    ungroup() %>%
    left_join(department_lookup %>% read_csv, 
              by = c('department'='unmapped_department')) %>%
    mutate(job_department = coalesce(job_department_short_name, department)) %>%
    select(-id) %>%
    mutate_all(funs(gsub("\t|;", "", .)))
  
  all_email_data <- previous_extracted_data %>%
    bind_rows(new_email_data) %>%
    distinct
  
  write.csv(all_email_data, csv_name, row.names = F)
}