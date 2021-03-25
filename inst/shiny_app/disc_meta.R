###

#Shiny Web App to visualize daily discharge data from large data sets
#Collect meta information

###

library(readr, raster)

#get folder paths defined in set_dir.R
source(paste0(getwd(), "/inst/shiny_app/set_dir.R"))

#grdc_data----

# Global Runoff Data Base from GRDC
# https://www.bafg.de/GRDC/EN/01_GRDC/13_dtbse/database_node.html
# Data portal: https://portal.grdc.bafg.de/applications/public.html?publicuser=PublicUser

#Read meta data from GRDC files located in folder 'data/grdc'
file_paths_grdc <- list.files(path = grdc_disc_dir, pattern = "*.Cmd", full.names = T)
file_names_grdc <- list.files(path = grdc_disc_dir, pattern = "*.Cmd", full.names = F)

grdc_meta <- NULL

for(i in 1:length(file_paths_grdc)){

  print(paste(i, "of", length(file_paths_grdc)))

  #get rows with meta information
  meta_rows <- read_lines(file_paths_grdc[i], n_max = 32)
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
  gauge_id <- substr(file_names_grdc[i], 1, 7)

  meta_sing <- c(sta_name, sta_lati, sta_long, sta_seri, end_seri, file_paths_grdc[i], gauge_id, cou_name)


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
grdc_meta$source <- rep("grdc", nrow(grdc_meta))

#prevent duplicated latituds for selected via map
dup_lat <- which(duplicated(grdc_meta$latitude))
grdc_meta$latitude[dup_lat] <- grdc_meta$latitude[dup_lat] + rnorm(length(dup_lat), 0, 0.001)

#save meta information as table (to be read by app at start up)
write.table(grdc_meta, file = disc_meta_path, sep = ";", row.names = F, quote = T)


#lamah_data----

# LamaH | Large-Sample Data for Hydrology and Environmental Sciences for Central Europe – files
# Data source: https://doi.org/10.5281/zenodo.4525244
# Data documentation: https://doi.org/10.5194/essd-2021-72

lamah_meta_full <- read.table(paste0(lamah_dir, "/D_gauges/1_attributes/Gauge_attributes.csv"), header = T, sep = ";")
file_names_lamah <- list.files(path = paste0(lamah_dir, "/D_gauges/2_timeseries/daily"), pattern = "*.csv", full.names = F)
file_paths_lamah <- list.files(path = paste0(lamah_dir, "/D_gauges/2_timeseries/daily"), pattern = "*.csv", full.names = T)

#get id from filenames
get_id_lamah <- function(file_name){
  as.numeric(substr(file_name, 4, (nchar(file_name)-4)))
}
ids_lamah_files <- sapply(file_names_lamah, get_id_lamah)
file_paths_lamah[ids_lamah_files] <- file_paths_lamah

#modify observation end
#0 means still running
lamah_meta_full$obsend[which(lamah_meta_full$obsend == 0)] <- 2021

#latitude and longitude to WGS84
crswgs84 <- sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
gauges_shp <- rgdal::readOGR(paste0(lamah_dir, "/D_gauges/3_shapefiles/Gauges.shp"))
gauges <- SpatialPointsDataFrame(data.frame(lon = lamah_meta_full$lon,
                                            lat = lamah_meta_full$lat),
                                    data = data.frame(data =rep(-1, length(lamah_meta_full$lon))),
                                    proj4string =  raster::crs(gauges_shp))
gauges    <- spTransform(gauges, crswgs84)

#prevent duplicated latituds for selected via map
dup_lat <- which(duplicated(gauges@coords[, 2]))
gauges@coords[dup_lat, 2] <- gauges@coords[dup_lat, 2]  + rnorm(length(dup_lat), 0, 0.001)

#select information
lamah_meta <- data.frame(name = as.character(lamah_meta_full$name),
                         latitude = gauges@coords[, 2],
                         longitude = gauges@coords[, 1],
                         start_series = lamah_meta_full$obsbeg_day,
                         end_series = lamah_meta_full$obsend,
                         file_path = file_paths_lamah,
                         id = lamah_meta_full$ID,
                         country = as.character(lamah_meta_full$country),
                         source = rep("lamah", nrow(lamah_meta_full)),
                         stringsAsFactors=FALSE)

#combine with grdc meta
meta_expo <- rbind(grdc_meta, lamah_meta)

#save meta information as table (to be read by app at start up)
write.table(meta_expo, file = disc_meta_path, sep = ";", row.names = F, quote = T)
