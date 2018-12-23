external_advert_data<- read_csv(external_emails_data_csv) %>%
  transmute(job_id = str_extract(link, '[[:digit:]]{7,}'),
            is_readvertised = T,
            new_closing_date = dmy(gsub("Closing Date: ", "", closing_date)),
            new_downloaded_date = ymd(date_downloaded))

all_advert_data <- read_csv(raw_data_csv_name) %>%
  mutate(closing_date = dmy(gsub("Closing Date: ", "", closing_date)),
         date_downloaded = ymd(date_downloaded),
         grade = gsub("Grade: ", "", grade),
         approach = gsub("Approach: ", "", approach),
         location = gsub("Location: ", "", location),
         salary = gsub("Salary: ", "", salary),
         role_type = sub("Role Type: ", "", role_type),
         job_id = str_extract(link, '[[:digit:]]{7,}')) %>%
  left_join(external_advert_data) %>%
  replace_na(list(is_readvertised = F, 
                  new_closing_date = "1900-01-01",
                  new_downloaded_date = "1900-01-01")) %>%
  mutate(is_readvertised = ifelse((approach != "External") & 
                              (is_readvertised == T), T, F))

all_advert_data %>%
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