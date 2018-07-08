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

locations_lookup <- post_code_locations_file %>%
  read_csv %>%
  mutate(
    postcode_regex = paste("(^|,|[[:space:]])", tolower(Postcode),"[[:space:]]|$)", sep =""),
    region_regex = paste("(^|,|[[:space:]])", tolower(Region),"[[:space:]]|$)", sep ="")
  ) %>%
  select(postcode_regex,region_regex, Postcode, Region) %>%
  mutate(dummy = TRUE)

locations <-  all_advert_data %>%
  subset(select = c(job_id, location)) %>%
  mutate(dummy = TRUE,
         location = tolower(gsub("[[:punct:]]", " ", location))) %>%
  full_join(locations_lookup) %>%
  rowwise() %>%
  mutate(post_code_matches = grepl(postcode_regex, location)) %>%
  mutate(region_matches = grepl(region_regex, location)) %>%
  filter(post_code_matches | region_matches)%>%
  distinct(job_id, Region) %>%
  select(job_id, Region)

write_csv(locations, location_data_csv)


