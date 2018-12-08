dir.create(email_tables, showWarnings = FALSE)

min_cause_area_sum <- 10 #make this cause area specific?
ea_cause_areas <- c('Biorisk and biosecurity', 'China policy', 'Climate change', 
                    'Factory farming', 'Nuclear disarmament', 'AI, data and tech policy',
                    'Mental health', 'Global health and development', 'Existential risk', 'Institutional decision-making') 
#These should bepart of the cause area info and key word search
#The lines above are a quick fix - without them we have lots of DfID jobs

all_advert_data <-adverts_csv_name %>%
  read_csv

needed_advert_info <- all_advert_data %>%
  select(job_ref, `Number of posts`) 

basic_advert_info <- cleaned_data_csv %>%
  read_csv

previously_identified_adverts <- email_tables %>%
  list.files() %>%
  map(~read_csv(file.path(email_tables, .))) %>%
  reduce(bind_rows) %>%
  pull(link) 

emailable_key_words_results <- key_words_results_file %>%
  read_csv %>%
  left_join(needed_advert_info) %>%
  left_join(basic_advert_info, by = c('job_ref' = 'job_id')) %>%
  mutate(`To share with EAs? Y/N/?` = '',
         Notes = '') %>%
  filter(cause_area_sum >= min_cause_area_sum,
         (closing_date - today()) > 4,
         `Cause area` %in% ea_cause_areas,
         approach == 'External',
         !(link %in%  previously_identified_adverts)) %>%
  select(`Cause area`,
         link,
         job_department,
         `To share with EAs? Y/N/?`,
         Notes) %>%
  unique()

#check if there are any new ones?
my_file_name <- file.path(email_tables, paste(today(),'.csv', sep = ''))
if(!file.exists(my_file_name)){
  write_csv(emailable_key_words_results, my_file_name)
} else(print('File already exists delete/rename and rerun!'))