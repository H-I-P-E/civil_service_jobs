jobs_xpath <- '//p | //h3 | //h2 | //h2//a'
column_names = c("job_title", "link", "department", "location", "salary", "grade", "approach", "role_type","closing_date")


create_csv_from_html_emails(emails_folder, raw_data_csv_name)
create_csv_from_html_emails(external_emails_folder, external_emails_data_csv)
