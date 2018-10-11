cleaned_data_locations <- read_csv(cleaned_data_csv) %>%
  select(job_id, location)

manual_locations <- read_csv(manual_locations_file)
specific_locations <- read_csv(specific_locations_file)
post_code_locations <- read_csv(post_code_locations_file)
region_lookup <- read_csv(region_lookup_file) %>%
  mutate(region_regex = paste("(^|[:punct:]|[[:space:]])", region,"([[:space:]]|$|[:punct:])", sep =""))

if(file.exists(location_data_csv)){
  old_locations <- read_csv(location_data_csv)
  old_location_ids <- pull(job_id) %>%
    unique()}else{
      old_location_ids <- c()
    }

manual_location_matches <- cleaned_data_locations %>%
  inner_join(manual_locations) %>%
  select(-location)

postcode_regex = "([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9][A-Za-z]?))))\\s?[0-9][A-Za-z]{2})"

locations_with_postcodes <- cleaned_data_locations %>%
  filter(!(job_id%in% manual_location_matches$job_id)) %>%
  mutate(post_codes = str_extract_all(location, postcode_regex)) %>%
  unnest(post_codes)
  
regions_regexes <- region_lookup %>% select(region_regex) %>%
  mutate(dummy = T)

postcodes_matched_by_region <- cleaned_data_locations %>%
  filter(!(job_id%in% manual_location_matches$job_id),
         !(job_id%in% locations_with_postcodes$job_id)) %>%
  head(100) %>%
  mutate(dummy = T) %>% 
  left_join(regions_regexes) %>%
  mutate(region_match = str_detect(tolower(location), region_regex)) 

write_csv(locations, location_data_csv)
