###

#Shiny Web App to visualize discharge data from GRDC - Define paths
#Erwin Rottler, University of Potsdam, 2019/2020

###

#path to shiny app
app_dir <- "/home/rottler/ownCloud/RhineFlow/rhine_snow/R/meltimr/inst/shiny_app/"

#path to folder with GRDC files with observed runoff
grdc_dir <- paste0(app_dir, "/data")
# grdc_dir <- "/media/rottler/data2/GRDC_DAY"
# grdc_dir <- "/srv/shiny-server/melTim/data"

#Path to folder with watershed boundaries (can be empty)
catc_dir <- paste0(app_dir, "/basins")
# catc_dir <- "/media/rottler/data2/basin_data/grdc_basins/"
# catc_dir <- "/srv/shiny-server/melTim/basins/"

#path to grdc meta data file (generated with grdc_meta.R)
grdc_meta_path <- paste0(app_dir, "/grdc_meta.csv")
