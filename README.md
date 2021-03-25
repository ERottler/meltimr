# Summary

Climatic changes and anthropogenic modifications of the river basin or river network have the potential to fundamentally alter river runoff. In the framework of this study, we aim to investigate historic changes in runoff timing and runoff seasonality observed at discharge gauges all over the world. In this regard, we develop the Hydro Explorer, an interactive web app, which enables the investigation of daily resolution discharge time series. The available selection of analytical tools inter alia enables the investigation of changes in mean annual cycles, inter- and intra-annual variability, the timing and magnitude of annual maxima and changes in quantile values over time. The interactive nature of the developed web app allows a quick comparison of gauges, regions, methods and times frames and makes it possible to assess weaknesses and strengths of individual analytical tools. The tool framework can be re-used to visualise other data sets, existing analytical approaches modified and new methods added.

# Hydro Explorer

The web app can be viewed at: http://natriskchange.ad.umwelt.uni-potsdam.de:3838/HydroExplorer/

Key component of the shiny web app is an interactive leaflet map. On click, observations of the selected gauging station are displayed in the draggable viewer panel. Via a dropdown menu, different analytical tools can be selected. A short description of available tools and interactive options can be found in the tab 'TOOLS'. The dropdown menu for selecting analytical tools also contains the option to filter stations displayed on the map. Selections can be made according to data coverage and location. Using the layer control on the bottom left of the map, different basemaps can be selected and watershed boundaries displayed. Figures can be downloaded clicking the download button below the graph displayed. A rearch article including a detailed description of the interactive web app and available tools can be found at: https://doi.org/10.1002/rra.3772

# Data

In the framework of this study, we focus on discharge data from the global runoff dataset provided by the Global Runoff Data Centre 56068 Koblenz, Germany (GRDC). This unique collection of discharge time series from all over the world represents a key dataset for hydrological research. For further information, please visit:

https://www.bafg.de/GRDC/EN/Home/homepage_node.html

Watershed boundaries were derived by Bernhard Lehner based on the HydroSHEDS drainage network. For more information and access to the corresponding technical report within the GRDC Report Series, please visit:

https://www.bafg.de/GRDC/EN/02_srvcs/22_gslrs/222_WSB/watershedBoundaries_node.html

# Test functionality

To test the app on your local machine, take the following steps:

1) Make sure up-to-date versions of [R](https://www.r-project.org/) and [RStudio](https://rstudio.com/) are installed.

2) Install this R package: ```devtools::install_github("ERottler/meltimr")``` Other R packages needed in order to run the Hydro Explorer are listed in the DESCRIPTION of the package and get installed automatically. 

3) Download this git repository, extract files and open the R-project by clicking on 'meltimr.Rproj'

4) Navigate to the shiny app folder *inst/shiny_app* and add the full app directory path in *inst/shiny_app/set_dir.R*

5) Run the the script *inst/shiny_app/grdc_meta.R*. This script reads meta information from GRDC-files and saves them in a table, which provides all informationen needed in the Hydro Explorer.

6) Run the following command: ```shiny::runApp(paste0(getwd(), "/inst/shiny_app/"))```

The app should start showing two artificial gauging stations.

# Run app with your own GRDC data

The test run uses two artificial GRDC dummy data files located in *inst/shiny_app/data*. Shoud you have GRDC files at hand already, either copy them into this folder or change the GRDC folder path in *inst/shiny_app/set_dir.R*. Should you need (more) data, send a request to the [Global Runoff Data Centre 56068 Koblenz, Germany (GRDC)](https://www.bafg.de/GRDC/EN/01_GRDC/grdc_node.html). In order for the app to run, the meta information stored in the headers of the individual GRDC files needs to be provided as table (see *inst/shinyapp/grdc_meta.csv*). This data table can be created by running the script *inst/shinyapp/grdc_meta.R*. Should you want to display watershed boundaries of your gauging stations on click, add them as shapefiles (station ID as name, e.g. 1234567.shp) into the folder containing watershed boundaries defined in *inst/shinyapp/set_dir.R*. 

# Modify and add analytical tools/data sources

Feel free to modify existing analytical tools and add new options and data sources! User feedback and contributions are highly welcome. Should you have questions or encounter problems, please report using the [GitHub Issue Tracker](https://github.com/ERottler/meltimr/issues) or write an email: erwin.rottler(a)uni-potsdam.de To fix a bug or make other improvements, please consider sending a [pull request](https://github.com/ERottler/meltimr/pulls).

# Funding

This research was funded by Deutsche Forschungsgemeinschaft (DFG) within the graduate research training group NatRiskChange (GRK 2043/1) at the University of Potsdam: https://www.uni-potsdam.de/en/natriskchange
