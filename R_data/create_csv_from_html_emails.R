jobs_xpath <- '//p | //h3 | //h2 | //h2//a'
column_names = c("job_title", "link", "department", "location", "salary", "grade", "approach", "role_type","closing_date")

all_email_data <- data_frame(filename = dir(emails_folder, pattern = "*.html")) %>%
  mutate(date_downloaded = gsub(".html", "", filename),
         file_contents = map(filename, ~ read_html(paste(emails_folder,.,sep ='\\'))) %>% 
           map(~html_nodes(., xpath = jobs_xpath)) %>%
           map(~ ifelse(is.na(html_attr(., 'href')),html_text(.),html_attr(., 'href'))) %>%
           map(~tail(., -2)) %>%
           map(~head(., -1)) %>%
           map(~data.frame('all_data' = ., 
                           'id' = rep(1:(length(.)%/% length(column_names)), each = length(column_names)),
                           stringsAsFactors = F))) %>%
  unnest %>%
  group_by(id, date_downloaded) %>%
  summarise('all_data' = paste(all_data, collapse ="!!!")) %>%
  separate('all_data', into = column_names, sep = "!!!") %>% 
  ungroup() %>%
  left_join(department_lookup %>% read_csv, 
            by = c('department'='unmapped_department')) %>%
  mutate(job_department = coalesce(job_department, department)) %>%
  select(-id, -department) %>%
  mutate_all(funs(gsub("\t|;", "", .)))

write.csv(all_email_data, raw_data_csv_name, row.names = F)