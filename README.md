# meltimr

Shiny web app to investigate GRDC runoff data with regard to changes in runoff timing.

The app can be viewed at: http://natriskchange.ad.umwelt.uni-potsdam.de:3838/HydroExplorer/


To run the app on your local machine, take the following steps:

1) Install R package: devtools::install_github("ERottler/meltimr")

2) Download folder with R-scripts for shiny app *inst/shinyapp*

3) Request runoff data from the Global Runoff Data Centre 56068 Koblenz, Germany (GRDC)

4) Set path to GRDC-files in 'server.R' Line 6

In order to get started without having GRDC data at hand, two synthetic data files in the GRDC-format are located in *inst/shinyapp/data*. Feel free to modify existing analytical tools and add new options and data sources.

