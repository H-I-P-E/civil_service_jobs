basic_info_css <- '.vac_display_field_value , h3'

get_data_from_html <- function(html_document){
  nodes <- html_nodes(html_document, css = basic_info_css)
  return(nodes)
  }

#Takes a list of html nodes and returns a single row of data using the the h3s as column headings
#Spread all the data not each row
convert_nodes_to_data <- function(nodes){
    as_data <- data.frame(type = html_name(nodes), text = html_text(nodes)) %>%
      mutate(row = as.integer(row.names(.)),
            dummy = TRUE)
    data_as_one_row <- full_join(as_data %>% filter(type != 'h3'),
              as_data %>% filter(type == 'h3'),
                      by = c('dummy')) %>%
     filter(row.x > row.y) %>%
     group_by(row.x) %>%
     filter(row.y == max(row.y)) %>%
     ungroup %>%
     transmute(variable = as.character(text.y),
               value = as.character(text.x)) %>%
     group_by(variable) %>%
     summarise(value = paste(value, collapse = "!!!")) 
  return(data_as_one_row)
}

references_to_exclude <- c()

if(file.exists(adverts_csv_name)){
  previous_data <- read_csv(adverts_csv_name)
  references_to_exclude <- unique(c(references_to_exclude, previous_data$job_ref))
}
if(file.exists(missing_data_csv)){
  previous_missing_data <- read_csv(missing_data_csv)
  references_to_exclude <- unique(c(references_to_exclude, previous_missing_data$job_ref))
}

all_files <- data_frame(filename = dir(adverts_folder, pattern = "*.html", recursive = T, full.names = T)) %>%
  mutate(job_ref = str_extract(filename, '[[:digit:]]{7,}')) %>%
  filter(!(as.character(job_ref) %in% references_to_exclude)) %>%
  mutate(data = map(filename, ~ read_html(.)))

missing_data <- all_files %>%
  filter(unlist(map(data, length)) <= 1) %>%
  select(job_ref) %>%
  mutate(issue = "missing xml part")

all_files_extract <- all_files %>%
  filter(unlist(map(data, length)) > 1) %>% #The html doc should have a node and doc element, so should be length 2
  mutate(html_nodes = data %>%
           map(~ get_data_from_html(.)))

missing_data <- missing_data %>%
  bind_rows(filter(all_files_extract, unlist(map(html_nodes, xmlSize) == 0)) %>%
             select(job_ref) %>%
             mutate(issue = "no matched nodes"))

if(nrow(missing_data) >0){
  if(file.exists(missing_data_csv)){
    missing_data <- read_csv(missing_data_csv) %>%
      mutate_all(as.character) %>%
      bind_rows(missing_data)
  }
write_csv(missing_data, missing_data_csv)
}

if(nrow(all_files_extract) >0){
all_files_extract_as_data <- all_files_extract %>%
  filter(unlist(map(html_nodes, xmlSize) > 0)) %>% #Filter out documents with no matching nodes
  mutate(row_of_data = map(html_nodes, convert_nodes_to_data)) %>%
  filter(map(row_of_data, length) > 0) %>%
  unnest(row_of_data) %>%
  spread(variable, value) %>%
  mutate_all(funs(gsub("\t|;", "", .)))

if(file.exists(adverts_csv_name)){
  all_files_extract_as_data <- read_csv(adverts_csv_name) %>%
    mutate_all(as.character) %>%
    bind_rows(all_files_extract_as_data)
}
write_csv(all_files_extract_as_data, adverts_csv_name)
}