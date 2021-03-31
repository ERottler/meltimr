###

#Shiny Web App to visualize daily discharge data from large data sets
#Data load at start-up

###

#save required data once as .RDate and load at start up
#load is faster than reading files individually

#GRDC watersheds boundaries
#total data set downloaded in five chunks
grdc_catch_1 <- rgdal::readOGR(paste0(grdc_catc_dir, "/stationbasins_1.geojson"))
grdc_catch_2 <- rgdal::readOGR(paste0(grdc_catc_dir, "/stationbasins_2.geojson"))
grdc_catch_3 <- rgdal::readOGR(paste0(grdc_catc_dir, "/stationbasins_3.geojson"))
grdc_catch_4 <- rgdal::readOGR(paste0(grdc_catc_dir, "/stationbasins_4.geojson"))
grdc_catch_5 <- rgdal::readOGR(paste0(grdc_catc_dir, "/stationbasins_5.geojson"))

grdc_catch <- rbind(grdc_catch_1, grdc_catch_2, grdc_catch_3, grdc_catch_4, grdc_catch_5)

#LamaH watershed boundaries
catch_lamah <- rgdal::readOGR(paste0(lamah_dir, "/A_basins_total_upstrm/3_shapefiles/Upstrm_area_total.shp"))

#CAMELS-US watershed boundaries
catch_usgs <- rgdal::readOGR(paste0(camels_us_catch_dir, "/HCDN_nhru_final_671.shp"))

#CAMELS-BR watershed boundaries
catch_brazil <- rgdal::readOGR(paste0(camels_br_dir, "/14_CAMELS_BR_catchment_boundaries/camels_br_catchments.shp"))

#CAMELS-BR watershed boundaries
catch_gb <- rgdal::readOGR(paste0(camels_gb_dir, "/data/CAMELS_GB_catchment_boundaries/CAMELS_GB_catchment_boundaries.shp"))

#CAMELS-CL discharge data
disc_data_cl <- read.csv(paste0(camels_cl_dir, "/2_CAMELScl_streamflow_m3s.txt"), header = T, sep ="\t", stringsAsFactors = F)

#CAMELS-BR watershed boundaries
catch_cl <- rgdal::readOGR(paste0(camels_cl_dir, "/CAMELScl_catchment_boundaries/catchments_camels_cl_v1.3.shp"))

#CAMELS-AUS discharge data
disc_data_aus <- read.csv(paste0(camels_aus_dir, "/03_streamflow/streamflow_MLd_inclInfilled.csv"),
                          header = T, sep =",", stringsAsFactors = F, na.strings = ("-99.99"))

#CAMELS-AUS discharge data
catch_aus <- rgdal::readOGR(paste0(camels_aus_dir, "/02_location_boundary_area/shp/CAMELS_AUS_Boundaries_adopted.shp"))

#save as .RData
save(grdc_catch, catch_lamah, catch_usgs, catch_brazil, catch_gb, disc_data_cl, catch_cl, disc_data_aus, catch_aus,
     file = paste0(app_dir, "data_explorer.RData"))
