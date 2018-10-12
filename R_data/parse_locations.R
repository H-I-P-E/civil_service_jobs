postcode_regex = "([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2}[A-Za-z]?)|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][0-9]{1,2}))))\\s?[0-9][A-Za-z]{2})"
outcode_regex = "([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2}[A-Za-z]?)|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][0-9]{1,2}))))\\s?)"

manual_locations <- read_csv(manual_locations_file)
specific_locations <- read_csv(specific_locations_file) %>%
  mutate(region_regex = region)
region_lookup <- read_csv(region_lookup_file) %>%
  mutate(region_regex = paste("(^|[:punct:]|[[:space:]])", region,"([[:space:]]|$|[:punct:])", sep ="")) %>%
  mutate(postcode = NA) %>%
  rbind(specific_locations) %>%
  mutate(dummy = T)

parent_child_regions <- region_lookup %>%
  select(region, parent_region) %>%
  filter(!is.na(parent_region)) %>%
  left_join(region_lookup%>% 
              select(region, parent_region),
            by = c("parent_region" = "region")) %>%
  left_join(region_lookup %>% 
              select(region, parent_region),
            by = c("parent_region.y" = "region")) %>%
  gather(key = "key", value = "parents", -region) %>%
  select(-key) %>%
  filter(!is.na(parents)) #can only go 3 parents deeps

if(file.exists(found_locations_csv)){
    old_found_locations_data <- read_csv(found_locations_csv)
    old_found_locations <- old_found_locations_data$location %>%
      unique()}else{
        old_found_locations_data <- NULL
        old_found_locations <- c()}

if(file.exists(location_data_csv)){
  old_locations <- read_csv(location_data_csv)
  old_location_ids <- old_locations$job_id %>%
    unique()}else{
      old_locations <- NULL
      old_location_ids <- c()}

if(file.exists(post_code_locations_file)){
  known_postcodes <- read_csv(post_code_locations_file)
  list_of_known_postcodes <- known_postcodes$postcode}else{
    known_postcodes <- NULL
    list_of_known_postcodes <- c()}

cleaned_data_locations <- read_csv(cleaned_data_csv) %>%
  select(job_id, location) %>%
  filter(!(job_id %in% old_location_ids))

if(nrow(cleaned_data_locations) > 0){
manual_location_matches <- cleaned_data_locations %>%
  inner_join(manual_locations) %>%
  select(-location)

locations_with_postcodes <- cleaned_data_locations %>%
  filter(!(job_id%in% manual_location_matches$job_id)) %>%
  mutate(postcode = str_extract_all(location, postcode_regex)) %>%
  unnest(postcode)

postcode_lookup <- locations_with_postcodes %>%
  distinct(postcode) %>%
  filter(!(postcode %in% list_of_known_postcodes)) %>%
  pull(postcode) %>%
  map(get_long_lat_from_postcode) %>%
  reduce(bind_rows, .init = NULL) %>%
  rbind(known_postcodes)

locations_with_postcodes <- locations_with_postcodes %>%
  left_join(postcode_lookup) %>%
  select(job_id, long, lat, postcode)

locations <- rbind(manual_location_matches,
                   locations_with_postcodes)

locations_matched_by_region <- cleaned_data_locations %>%
  filter(!(job_id %in% locations$job_id)) %>%
  filter(!(location %in% old_found_locations)) %>%
  distinct(location) %>%
  mutate(dummy = T) %>% 
  left_join(region_lookup) %>%
  mutate(region_match = str_detect(tolower(location), region_regex))  %>%
  filter(region_match)

matched_by_region_without_parents <- locations_matched_by_region %>%
  split(.$location) %>%
  map(remove_parents, parent_child_regions) %>%
  reduce(bind_rows, .init = NULL)

found_locations <- matched_by_region_without_parents %>%
  select(long, lat, postcode, location) %>%
  rbind(old_found_locations)

location_region_matches <- cleaned_data_locations %>%
  filter(!(job_id%in% locations$job_id)) %>%
  left_join(found_locations)  %>%
  select(job_id, long, lat, postcode)

locations <- rbind(locations,
                   location_region_matches,
                   old_locations)

write_csv(found_locations, found_locations_csv)
write_csv(postcode_lookup, post_code_locations_file)
write_csv(locations, location_data_csv)
}
