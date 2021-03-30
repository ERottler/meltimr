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

#order file paths following ID
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

#prevent duplicated latituds for selected via map
dup_lat <- which(duplicated(meta_expo$latitude))
meta_expo$latitude[dup_lat] <- meta_expo$latitude[dup_lat]  + rnorm(length(dup_lat), 0, 0.001)

#save meta information as table (to be read by app at start up)
write.table(meta_expo, file = disc_meta_path, sep = ";", row.names = F, quote = T)

#camels_us----
# CAMELS: Large-Sample Hydrometeorological Dataset
# 671 basins in the United States Geological Survey’s Hydro-Climatic Data Network
# https://ncar.github.io/hydrology/datasets/CAMELS_timeseries

usgs_gauge_meta <- read.csv(paste0(camels_dir_disc, "/basin_metadata/gauge_information.txt"),
                            sep = "\t", skip = 1, header = F)

#add read in 0 lost when at the beginning from station ID
usgs_gauge_meta$V2 <- as.character(usgs_gauge_meta$V2)
usgs_gauge_meta$V2[which(nchar(usgs_gauge_meta$V2) < 8)] <- paste0("0", usgs_gauge_meta$V2[which(nchar(usgs_gauge_meta$V2) < 8)])

file_paths_usgs <- list.files(path = paste0(camels_dir_disc, "/usgs_streamflow"), pattern = "*.txt", full.names = T, recursive = T)
file_names_usgs <- list.files(path = paste0(camels_dir_disc, "/usgs_streamflow"), pattern = "*.txt", full.names = F, recursive = T)

#get id from filenames
get_id_usgs <- function(file_name){
  as.character(substr(file_name, (nchar(file_name)-25), (nchar(file_name)-18)))
}
ids_usgs_files <- sapply(file_names_usgs, get_id_usgs)

#order file paths following ID
file_paths_usgs_ord <- rep(NA, nrow(usgs_gauge_meta))
for(i in 1:nrow(usgs_gauge_meta)){

  file_path_sel <- grep(usgs_gauge_meta[i, 2], file_paths_usgs, value = T)

  if(length(file_path_sel) > 1){
    print(i)
    print(length(file_path_sel))
  }

  file_paths_usgs_ord[i] <- file_path_sel

}

#get start/end of time series
start_series <- NULL
end_series <- NULL
for(i in 1:length(file_paths_usgs_ord)){

  usgs_disc_sel <- read.csv(file_paths_usgs_ord[i], sep = "", header = F)
  sta_yea_sel <- min(usgs_disc_sel[, 2], na.rm = T)
  end_yea_sel <- max(usgs_disc_sel[, 2], na.rm = T)

  start_series <- c(start_series, sta_yea_sel)
  end_series <- c(end_series, end_yea_sel)
}

#select information
usgs_meta <- data.frame(name = as.character(usgs_gauge_meta[, 3]),
                        latitude = usgs_gauge_meta[, 4],
                        longitude = usgs_gauge_meta[, 5],
                        start_series = start_series,
                        end_series = end_series,
                        file_path = file_paths_usgs_ord,
                        id = usgs_gauge_meta[, 2],
                        country = rep("USA", nrow(usgs_gauge_meta)),
                        source = rep("usgs", nrow(usgs_gauge_meta)),
                        stringsAsFactors=FALSE)

#combine with grdc meta
meta_expo <- rbind(grdc_meta, lamah_meta, usgs_meta)

#prevent duplicated latituds for selected via map
dup_lat <- which(duplicated(meta_expo$latitude))
meta_expo$latitude[dup_lat] <- meta_expo$latitude[dup_lat]  + rnorm(length(dup_lat), 0, 0.001)

#save meta information as table (to be read by app at start up)
write.table(meta_expo, file = disc_meta_path, sep = ";", row.names = F, quote = T)


#camels_br----

#CAMELS-BR: Hydrometeorological time series and landscape attributes for 897 catchments in Brazil
#https://zenodo.org/record/3964745

camels_br_gauge_meta <- read.csv(paste0(camels_br_dir,"01_CAMELS_BR_attributes/camels_br_location.txt"),
                                 sep = "", header = T)

file_paths_brazil <- list.files(path = paste0(camels_br_dir, "02_CAMELS_BR_streamflow_m3s"), pattern = "*.txt", full.names = T, recursive = T)
file_names_brazil <- list.files(path = paste0(camels_br_dir, "02_CAMELS_BR_streamflow_m3s"), pattern = "*.txt", full.names = F, recursive = T)

#get id from filenames
get_id_brazil <- function(file_name){
  as.character(substr(file_name, 1, 8))
}
ids_brazil_files <- sapply(file_names_brazil, get_id_brazil)

#order file paths following ID
file_paths_brazil_ord <- rep(NA, nrow(camels_br_gauge_meta))
for(i in 1:nrow(camels_br_gauge_meta)){

  file_path_sel <- grep(camels_br_gauge_meta$gauge_id[i], file_paths_brazil, value = T)

  if(length(file_path_sel) > 1){
    print(i)
    print(length(file_path_sel))
  }

  file_paths_brazil_ord[i] <- file_path_sel

}

#get start/end of time series
start_series <- NULL
end_series <- NULL
for(i in 1:length(file_paths_brazil_ord)){

  brazil_disc_sel <- read.csv(file_paths_brazil_ord[i], sep = "", header = T)
  sta_yea_sel <- min(brazil_disc_sel$year, na.rm = T)
  end_yea_sel <- max(brazil_disc_sel$year, na.rm = T)

  start_series <- c(start_series, sta_yea_sel)
  end_series <- c(end_series, end_yea_sel)

}

#select information
brazil_meta <- data.frame(name = as.character(camels_br_gauge_meta$gauge_name),
                          latitude = camels_br_gauge_meta$gauge_lat,
                          longitude = camels_br_gauge_meta$gauge_lon,
                          start_series = start_series,
                          end_series = end_series,
                          file_path = file_paths_brazil_ord,
                          id = camels_br_gauge_meta$gauge_id,
                          country = rep("Brazil", nrow(camels_br_gauge_meta)),
                          source = rep("camels_br", nrow(camels_br_gauge_meta)),
                          stringsAsFactors=FALSE)

#combine with grdc meta
meta_expo <- rbind(grdc_meta, lamah_meta, usgs_meta, brazil_meta)

#prevent duplicated latituds for selected via map
dup_lat <- which(duplicated(meta_expo$latitude))
meta_expo$latitude[dup_lat] <- meta_expo$latitude[dup_lat]  + rnorm(length(dup_lat), 0, 0.001)

#save meta information as table (to be read by app at start up)
write.table(meta_expo, file = disc_meta_path, sep = ";", row.names = F, quote = T)



#camels_gb----

#Catchment attributes and hydro-meteorological timeseries for 671 catchments across Great Britain (CAMELS-GB)
#https://catalogue.ceh.ac.uk/documents/8344e4f3-d2ea-44f5-8afa-86d2987543a9

gb_gauge_meta_1 <- read.csv(paste0(camels_gb_dir, "data/CAMELS_GB_hydrometry_attributes.csv"),
                              sep = ",", header = T)
gb_gauge_meta_2 <- read.csv(paste0(camels_gb_dir, "data/CAMELS_GB_topographic_attributes.csv"),
                            sep = ",", header = T)

file_paths_greatb <- list.files(path = paste0(camels_gb_dir, "/data/timeseries"), pattern = "*.csv", full.names = T, recursive = T)
file_names_greatb <- list.files(path = paste0(camels_gb_dir, "/data/timeseries"), pattern = "*.csv", full.names = F, recursive = T)

#get file names without time information
get_id_gb <- function(file_name){
  as.character(substr(file_name, 31, (nchar(file_name)-22) ))
}
ids_from_file <- sapply(file_names_greatb, get_id_gb)

#order file paths following ID
file_paths_gb_ord <- rep(NA, nrow(gb_gauge_meta_1))
for(i in 1:nrow(gb_gauge_meta_1)){

  file_path_sel <- file_paths_greatb[which(ids_from_file == gb_gauge_meta_1$gauge_id[i])]

  if(length(file_path_sel) > 1){
    print(i)
    print(length(file_path_sel))
  }

  file_paths_gb_ord[i] <- file_path_sel

}

#start and end year of time series
start_series_raw <- as.character(sapply(cl_gauge_meta[5,], rem_quote))
end_series_raw <- as.character(sapply(cl_gauge_meta[6,], rem_quote))
start_series <- format(as.Date(gb_gauge_meta_1$flow_period_start, "%Y-%m-%d"), "%Y")
end_series <- format(as.Date(gb_gauge_meta_1$flow_period_end, "%Y-%m-%d"), "%Y")

#select information
gb_meta <- data.frame(name = as.character(gb_gauge_meta_2$gauge_name),
                      latitude = gb_gauge_meta_2$gauge_lat,
                      longitude = gb_gauge_meta_2$gauge_lon,
                      start_series = start_series,
                      end_series = end_series,
                      file_path = file_paths_gb_ord,
                      id = gb_gauge_meta_1$gauge_id,
                      country = rep("GB", nrow(gb_gauge_meta_2)),
                      source = rep("camels_gb", nrow(gb_gauge_meta_2)),
                      stringsAsFactors=FALSE)

#combine with other meta data
meta_expo <- rbind(grdc_meta, lamah_meta, usgs_meta, brazil_meta, gb_meta)

#prevent duplicated latituds for selected via map
dup_lat <- which(duplicated(meta_expo$latitude))
meta_expo$latitude[dup_lat] <- meta_expo$latitude[dup_lat]  + rnorm(length(dup_lat), 0, 0.001)

#save meta information as table (to be read by app at start up)
write.table(meta_expo, file = disc_meta_path, sep = ";", row.names = F, quote = T)


#camels_cl----

cl_gauge_meta <- read.table(paste0(camels_cl_dir, "1_CAMELScl_attributes.txt"), sep = "\t", header = F, quote = "",
                          stringsAsFactors = F)
cl_rownames <- cl_gauge_meta[, 1]
cl_gauge_meta <- cl_gauge_meta[, -1]

#all time series in one file
file_path_cl <- paste0(camels_cl_dir, "2_CAMELScl_streamflow_m3s.txt")

#remove quotes from names
rem_quote <- function(char_in){
  substr(char_in, 2, nchar(char_in)-1)
}

lat_cl <- as.numeric(sapply(cl_gauge_meta[3,], rem_quote))
lon_cl <- as.numeric(sapply(cl_gauge_meta[4,], rem_quote))
name_cl <- as.character(sapply(cl_gauge_meta[2,], rem_quote))
name_cl <- gsub("\"", " ", name_cl)
id_cl <- as.character(sapply(cl_gauge_meta[1,], rem_quote))

start_series_raw <- as.character(sapply(cl_gauge_meta[5,], rem_quote))
end_series_raw <- as.character(sapply(cl_gauge_meta[6,], rem_quote))
start_series <- format(as.Date(start_series_raw, "%Y-%m-%d"), "%Y")
end_series <- format(as.Date(end_series_raw, "%Y-%m-%d"), "%Y")

#select information
cl_meta <- data.frame(name = name_cl,
                      latitude = lat_cl,
                      longitude = lon_cl,
                      start_series = start_series,
                      end_series = end_series,
                      file_path = rep(file_path_cl, length(name_cl)),
                      id = id_cl,
                      country = rep("Chile", length(name_cl)),
                      source = rep("camels_cl", length(name_cl)),
                      stringsAsFactors=FALSE)

#combine with grdc meta
meta_expo <- rbind(grdc_meta, lamah_meta, usgs_meta, brazil_meta, gb_meta, cl_meta)

#prevent duplicated latituds for selected via map
dup_lat <- which(duplicated(meta_expo$latitude))
meta_expo$latitude[dup_lat] <- meta_expo$latitude[dup_lat]  + rnorm(length(dup_lat), 0, 0.001)

#save meta information as table (to be read by app at start up)
write.table(meta_expo, file = disc_meta_path, sep = ";", row.names = F, quote = T)

#camels_aus----

aus_gauge_meta <- read.csv(paste0(camels_aus_dir, "01_id_name_metadata/id_name_metadata.csv"),
                           sep = ",", header = T, stringsAsFactors = F)
aus_strea_meta <- read.csv(paste0(camels_aus_dir, "03_streamflow/streamflow_GaugingStats.csv"),
                           sep = ",", header = T, stringsAsFactors = F)
aus_coord_meta <- read.csv(paste0(camels_aus_dir, "02_location_boundary_area/location_boundary_area.csv"),
                           sep = ",", header = T, stringsAsFactors = F)

#all time series in one file
file_path_aus <- paste0(camels_cl_dir, "3_streamflow/streamflow_MLd_inclInfilled.csv")

start_series <- format(as.Date(as.character(aus_strea_meta$start_date), "%Y%m%d"), "%Y")
end_series <- format(as.Date(as.character(aus_strea_meta$end_date), "%Y%m%d"), "%Y")

#select information
aus_meta <- data.frame(name = aus_gauge_meta$station_name,
                       latitude = aus_coord_meta$lat_outlet ,
                       longitude = aus_coord_meta$long_outlet,
                       start_series = start_series,
                       end_series = end_series,
                       file_path = rep(file_path_aus, length(aus_gauge_meta$station_name)),
                       id = aus_gauge_meta$station_id,
                       country = rep("Australia", length(aus_gauge_meta$station_name)),
                       source = rep("camels_aus", length(aus_gauge_meta$station_name)),
                       stringsAsFactors=FALSE)

#combine with grdc meta
meta_expo <- rbind(grdc_meta, lamah_meta, usgs_meta, brazil_meta, gb_meta, cl_meta, aus_meta)

#prevent duplicated latituds for selected via map
dup_lat <- which(duplicated(meta_expo$latitude))
meta_expo$latitude[dup_lat] <- meta_expo$latitude[dup_lat]  + rnorm(length(dup_lat), 0, 0.001)

#save meta information as table (to be read by app at start up)
write.table(meta_expo, file = disc_meta_path, sep = ";", row.names = F, quote = T)
