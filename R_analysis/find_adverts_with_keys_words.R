all_advert_data <- adverts_csv_name %>%
  read_csv %>%
  select(job_ref, `Job description`) %>%
  mutate(dummy = TRUE)

key_words <- key_words_csv %>%
  read_csv %>%
  mutate(dummy = TRUE)

if(file.exists(key_words_results_file)){
  previous_key_words <- read_csv(key_words_results_file) %>%
    mutate_all(as.character) %>%
    mutate(ref_word = paste(job_ref, `Search term`))
} else{previous_key_words <-NULL}

key_word_counts <- all_advert_data %>%
  left_join(key_words) %>%
  mutate(ref_word = paste(as.character(job_ref), `Search term`)) %>%
  filter(!(ref_word %in% previous_key_words$ref_word)) %>%
  mutate(match = str_count(tolower(`Job description`),`Search term`)) %>%
  mutate(match_rating = match*`Strength of association 1-9 (currently subjective)`) %>%
  group_by(`Cause area`, job_ref) %>%
  mutate(cause_area_sum = sum(match_rating)) %>%
  ungroup %>%
  select(job_ref,  `Cause area`, cause_area_sum, match_rating, `Search term`) #%>%

key_word_counts %>%
  mutate_all(as.character) 
  bind_rows(previous_key_words) %>%
  write_csv(key_words_results_file)