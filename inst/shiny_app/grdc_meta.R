###

#Shiny Web App to visualize discharge data from GRDC
#Read GRDC meta information from files
#Erwin Rottler, University of Potsdam, 2019/2020

###

#get folder paths defined in set_dir.R
source(paste0(getwd(), "/inst/shiny_app/set_dir.R"))

#Read meta data from GRDC files located in folder 'data/grdc'
file_paths <- list.files(path = grdc_dir, pattern = "*.Cmd", full.names = T)
file_names <- list.files(path = grdc_dir, pattern = "*.Cmd", full.names = F)

grdc_meta <- NULL

for(i in 1:length(file_paths)){

  print(paste(i, "of", length(file_paths)))

  #get rows with meta information
  meta_rows <- read_lines(file_paths[i], n_max = 32)
  meta_rows <- iconv(meta_rows, "UTF-8", "ASCII", "")
  #Name
  row_name <- meta_rows[11]
  sta_name <- substr(row_name, 26, nchar(row_name))
  #Country
  row_country <- meta_rows[12]
  cou_name <- substr(row_country, 12, nchar(row_country))
  cou_name <- trimws(cou_name)
  #Longitude
  row_long <- meta_rows[14]
  sta_long_raw <- substr(row_long, 18, nchar(row_long))
  sta_long <- trimws(sta_long_raw)
  #Latitude
  row_lati <- meta_rows[13]
  sta_lati_raw <- substr(row_lati, 17, nchar(row_lati))
  sta_lati <- trimws(sta_lati_raw)
  #Start/End time series
  row_seri <- meta_rows[24]
  sta_seri <- substr(row_seri, 26, nchar(row_seri)-13)
  end_seri <- substr(row_seri, 36, nchar(row_seri)-3)
  #gauge ID from file name
  gauge_id <- substr(file_names[i], 1, 7)

  meta_sing <- c(sta_name, sta_lati, sta_long, sta_seri, end_seri, file_paths[i], gauge_id, cou_name)


  if(i == 1){

    grdc_meta <- meta_sing

  }else{

    grdc_meta <- rbind(grdc_meta, meta_sing)

  }


}

colnames(grdc_meta) <- c("name", "latitude", "longitude", "start_series", "end_series", "file_path", "id", "country")
rownames(grdc_meta) <- NULL

grdc_meta <- as.data.frame(grdc_meta, stringsAsFactors=FALSE)
grdc_meta$latitude   <- as.numeric(grdc_meta$latitude)
grdc_meta$longitude  <- as.numeric(grdc_meta$longitude)
grdc_meta$start_series  <- as.numeric(grdc_meta$start_series)
grdc_meta$end_series  <- as.numeric(grdc_meta$end_series)
grdc_meta$id <- as.numeric(grdc_meta$id)

#prevent duplicated latituds for selected via map
dup_lat <- which(duplicated(grdc_meta$latitude))
grdc_meta$latitude[dup_lat] <- grdc_meta$latitude[dup_lat] + rnorm(length(dup_lat), 0, 0.001)

#save grdc meta information as table (to be read by app at start up)
write.table(grdc_meta, file = grdc_meta_path, sep = ";", row.names = T, quote = T)
