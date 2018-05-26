competencies <- read_csv(competencies_file) %>%
  mutate(dummy = T)

job_data <- adverts_csv_name %>%
  read_csv %>%
  transmute(
    job_ref = job_ref,
    potential_competency_text = tolower(paste(`Selection process details`,
                                       `Job description`,
                                       `Competencies`,
                                       `Person specification`, 
                                       sep ="!!!")),
    dummy = T)

competency_table <- job_data %>%
  full_join(competencies) %>%
  mutate(count = str_count(potential_competency_text, competency)) %>%
  filter(count > 0) %>%
  select(job_ref, competency, count)

write_csv(competency_table, competency_data_file)