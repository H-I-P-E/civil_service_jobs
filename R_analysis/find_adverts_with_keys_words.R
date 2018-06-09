all_advert_data <- adverts_csv_name %>%
  read_csv %>%
  select(job_ref, `Job description`, `Contact point for applicants`, filename) %>%
  mutate(dummy = TRUE)

key_words <- key_words_csv %>%
  read_csv %>%
  mutate(dummy = TRUE)

key_word_counts <- all_advert_data %>%
  left_join(key_words) %>%
  mutate(match = str_count(tolower(`Job description`),`Search term`)) %>%
  filter(match > 0) %>%
  mutate(match_rating = match*`Strength of association 1-9 (currently subjective)`) %>%
  group_by(`Cause area`, job_ref) %>%
  mutate(cause_area_sum = sum(match_rating)) %>%
  ungroup %>%
  select(job_ref,  `Cause area`, cause_area_sum, match_rating, `Search term`) %>%
  spread(key = `Search term`, value = match_rating, fill = 0) %>%
  left_join(all_advert_data) %>%
  left_join(cleaned_data_csv %>% read_csv,
            by = c('job_ref' = 'job_id'))

create_cause_area_folder <- function(table_of_adverts){
  cause_area <- table_of_adverts$`Cause area`[[1]]
  cause_folder <- file.path(impactful_folder, cause_area)
  dir.create(cause_folder, showWarnings = FALSE)
  table_of_adverts %>%
    mutate(source_file_path = file.path(adverts_folder, filename),
           target_file_path = file.path(cause_folder, 
                                        paste(cause_area_sum, job_department, grade, filename, sep = "; "))) %>%
    mutate(copy = walk2(source_file_path, target_file_path, file.copy))
}

key_word_counts %>%
  group_by(`Cause area`) %>%
  do(create_cause_area_folder(.))

key_word_counts %>%
  select(-`Job description`) %>%
  write_csv(key_words_results_file)

####mining prep####

policy_roles <- role_data_csv %>%
  read_csv %>%
  filter(role_type == 'Policy') %>%
  transmute(job_id = job_id,
            is_policy = T)

all_advert_data <- adverts_csv_name %>%
  read_csv %>%
  select(job_ref,`Job description`, `Contact point for applicants`) %>%
  left_join(cleaned_data_csv %>%
              read_csv, by = c("job_ref" = "job_id"))

ready_for_mining <- all_advert_data %>%
  left_join(key_word_counts %>%
              mutate(possibly_impactful = as.numeric(cause_area_sum >= 9)) %>%
              select(job_ref, `Cause area`, possibly_impactful)) %>%
  spread(`Cause area`, possibly_impactful, fill = 0) %>%
  select(-`<NA>`) %>%
  left_join(policy_roles, by = c("job_ref" = "job_id")) %>%
  replace_na(replace = list('is_policy' = F))

write_csv(ready_for_mining, pre_mining_data_csv)

####Summaries key word adverts and contact parsing####

email_regex <- "/([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\\.[a-zA-Z0-9_-]+)/"
email_and_names <- all_advert_data %>%
  select(job_ref, `Contact point for applicants`) %>%
  mutate(emails = map(`Contact point for applicants`, ~grep(email_regex,.x , value = T)))

key_words_summary  <- ready_for_mining %>%
  filter(job_ref %in% key_word_counts$job_ref) %>%
  left_join(all_advert_data)


write_csv(key_words_summary, key_words_summary_file)

