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

