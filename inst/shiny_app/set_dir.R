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

### Path to LamaH discharge data
lamah_disc_dir <- "/home/erwin/Documents/storage_research/lamah/CAMELS_AT/A_basins_total_upstrm/2_timeseries/"

### Path to LamaH watershed boundaries
lamah_dir <- "/home/erwin/Documents/storage_research/lamah/CAMELS_AT"
