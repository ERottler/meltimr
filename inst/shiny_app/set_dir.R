###

#Shiny Web App to visualize daily discharge data from large data sets
#Define paths

###

### Path to shiny app
# app_dir <- "/home/rottler/ownCloud/RhineFlow/rhine_snow/R/meltimr/inst/shiny_app/"
app_dir <- "/home/erwin/ownCloud/RhineFlow/rhine_snow/R/meltimr/inst/shiny_app/"
# app_dir <- "/srv/shiny-server/melTim/"

### Path to discharge meta data file (generated with disc_meta.R)
disc_meta_path <- paste0(app_dir, "/disc_meta.csv")

### Path to folder with GRDC files with observed runoff
# grdc_dir <- "/media/rottler/data2/GRDC_DAY"
grdc_disc_dir <- "/home/erwin/Documents/storage_research/grdc_data/GRDC_DAY"
# grdc_dir <- "/srv/shiny-server/melTim/data"

###Path to folder with GRDC watershed boundaries
# catc_dir <- "/media/rottler/data2/basin_data/grdc_basins/"
grdc_catc_dir <- paste0("/home/erwin/Documents/storage_research/grdc_data/stat_bas_shp/")
# catc_dir <- "/srv/shiny-server/melTim/basins/"

### Path to LamaH
lamah_dir <- "/home/erwin/Documents/storage_research/lamah/CAMELS_AT"

### Path to CAMELS-US time series
camels_dir_disc <- "/home/erwin/Documents/storage_research/camels_us/basin_timeseries_v1p2_metForcing_obsFlow/basin_dataset_public_v1p2"

### Path to CAMELS-US watershed boundaries
camels_us_catch_dir <- "/home/erwin/Documents/storage_research/camels_us/basin_set_full_res/"

### Path to CAMELS-BR
camels_br_dir <- "/home/erwin/Documents/storage_research/camels_br/"

### Path to  CAMELS-GB
camels_gb_dir <- "/home/erwin/Documents/storage_research/camels_gb/"

### Path to  CAMELS-CL
camels_cl_dir <- "/home/erwin/Documents/storage_research/camels_cl/"

### Path to  CAMELS-AUS
camels_aus_dir <- "/home/erwin/Documents/storage_research/camels_aus/"




