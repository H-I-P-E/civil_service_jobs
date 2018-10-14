all_advert_data <- adverts_csv_name %>%
  read_csv %>%
  select(job_ref, `Job description`) %>%
  mutate(`Job description` = tolower(`Job description`))

key_words <- key_words_csv %>%
  read_csv

count_key_word <- function(key_word, job_descriptions){
  print(key_word)
  job_descriptions[key_word] <- str_count(job_descriptions$`Job description`, key_word) 
  return(job_descriptions  %>%
           select(-`Job description`))}
  
key_word_results <- map(key_words$`Search term`, count_key_word, all_advert_data) %>%
  reduce(inner_join, by = c("job_ref" = "job_ref")) %>%
  gather(key = "search_term", value = "count", -job_ref) %>%
  filter(count > 0) %>%
  left_join(key_words, by = c("search_term" = "Search term")) %>%
  mutate(match_rating = count*`Strength of association 1-9 (currently subjective)`) %>%
  group_by(`Cause area`, job_ref) %>%
  mutate(cause_area_sum = sum(match_rating)) %>%
  ungroup %>%
  select(job_ref, `Cause area`, cause_area_sum, match_rating, search_term, score_cutoff)


write_csv(key_word_results, key_words_results_file)
