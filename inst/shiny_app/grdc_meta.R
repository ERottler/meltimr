###

#Read GRDC meta data from files

###

grdc_dir <- "/media/rottler/data2/GRDC_DAY" #Path to folder with GRDC data
# grdc_dir <- "/srv/shiny-server/melTim/data" #Path to folder with GRDC data
catc_dir <- "/media/rottler/data2/basin_data/grdc_basins/" #Path to folder with GRDC watersheds

#list watersheds available
catch_paths <- list.files(path = catc_dir, pattern = "*.shp$", full.names = T)
catch_names <- list.files(path = catc_dir, pattern = "*.shp$", full.names = F)
catch_ids <- as.numeric(substr(catch_names, 28, 34))

#Read meta data from GRDC files located in folder 'data/grdc'
file_paths <- list.files(path = grdc_dir, pattern = "*.Cmd", full.names = T)
file_names <- list.files(path = grdc_dir, pattern = "*.Cmd", full.names = F)

grdc_meta <- NULL

for(i in 1:length(file_paths)){

  print(i)

  #get rows with meta information
  meta_rows <- read_lines(file_paths[i], n_max = 32)
  meta_rows <- iconv(meta_rows, "UTF-8", "ASCII", "")

  #Name
  sta_name <- substr(meta_rows[11], 26, nchar(meta_rows[11]))

  #Longitude
  sta_long <- substr(meta_rows[14], 24, nchar(meta_rows[14]))

  #Latitude
  sta_lati <- substr(meta_rows[13], 24, nchar(meta_rows[13]))

  #Start Year
  sta_year <- substr(meta_rows[24], 26, 29)

  #End Year
  end_year <- substr(meta_rows[24], 36, 39)

  #Station ID
  sta_id <- substr(file_names[i], 1, 7)

  #Catchment area
  # catch_area <- trimws(substr(meta_rows[15], 23, nchar(meta_rows[15])))

  #Catchment available
  catch_log <- as.numeric(sta_id) %in% catch_ids

  #Meta data single station
  meta_sing <- c(sta_name, sta_lati, sta_long, sta_year, end_year, file_paths[i], sta_id, catch_log)

  #Collect meta data all stations
  grdc_meta <- rbind(grdc_meta, meta_sing)

}

colnames(grdc_meta) <- c("name", "latitude", "longitude", "Start_year", "End_year", "file_path", "id", "catch_available")
rownames(grdc_meta) <- NULL
grdc_meta <- as.data.frame(grdc_meta, stringsAsFactors=FALSE)
grdc_meta$latitude   <- as.numeric(grdc_meta$latitude)
grdc_meta$longitude  <- as.numeric(grdc_meta$longitude)
grdc_meta$Start_year  <- as.numeric(grdc_meta$Start_year)
grdc_meta$End_year  <- as.numeric(grdc_meta$End_year)
grdc_meta$End_year  <- as.numeric(grdc_meta$End_year)
# grdc_meta$catch_area  <- as.numeric(grdc_meta$catch_area)

#prevent duplicated latituds for selected via map
dup_lat <- which(duplicated(grdc_meta$latitude))
grdc_meta$latitude[dup_lat] <- grdc_meta$latitude[dup_lat] + rnorm(length(dup_lat), 0, 0.001)

write.table(grdc_meta, file = paste0("/home/rottler/ownCloud/RhineFlow/rhine_snow/R/meltimr/inst/shiny_app/grdc_meta.csv"), sep = ";", row.names = T, quote = T)
