dir.create(email_tables, showWarnings = FALSE)

min_cause_area_sum <- 10 #make this cause area specific?
ea_cause_areas <- c('Biorisk', 'China', 'Climate change', 
                    'Factory farming', 'Nuclear') 
#These should bepart of the cause area info and key word search
#The lines above are a quick fix - without them we have lots of DfID jobs

all_advert_data <-adverts_csv_name %>%
  read_csv

needed_advert_info <- all_advert_data %>%
  select(job_ref, `Number of posts`)

emailable_key_words_results <- key_words_results_file %>%
  read_csv %>%
  left_join(needed_advert_info) %>%
  filter(cause_area_sum >= min_cause_area_sum,
         closing_date >= today(),
         `Cause area` %in% ea_cause_areas) %>%
  select(`Cause area`, job_department,
         link, grade, location, 
         `Number of posts`, date_downloaded,
         closing_date, job_title, approach) %>%
  mutate(`Toby’s subjective and probably terrible rating of how impactful this job is within this cause area: please do not take this seriously he is not very smart and is a generally terrible person` = '')

my_file_name <- file.path(email_tables, paste(today(),'.csv', sep = ''))

write_csv(emailable_key_words_results, my_file_name)
