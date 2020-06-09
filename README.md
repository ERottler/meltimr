# Summary

Climatic changes and anthropogenic modifications of the river network or basin have the potential to fundamentally alter river runoff. In the framework of this study, we investigate historic changes in runoff seasonality and runoff timing observed at gauging stations all over the world. In this regard, we develop the 'HydroExplorer', an interactive shiny web app, which enables the investigation of >7000 time series. The available selection of tools inter alia enables the analysis of changes in mean annual cycles, inter- and intra-annual variability, the timing and magnitude of annual maxima and changes in quantile values over time. The interactive nature of the developed web app allows a quick comparison of gauges, regions, methods and times frames and makes it possible to asses weaknesses and strenghts of individual analytical tools.

# Hydro Explorer

The web app can be viewed at: http://natriskchange.ad.umwelt.uni-potsdam.de:3838/HydroExplorer/

Key component of the shiny web app is an interactive lealet map. On click, observations of the selected gauging station are displayed in the draggable viewer panel. Via a dropdown menu, different analytical tools can be selected. A short description of available tools and interactive options can be found in the tab 'TOOLS'. The dropdown menu for selecting analytical tools also contains the option to filter stations displayed on the map. Seletions can be made according to data coverage and location. Using the layer control on the bottom left of the map, different basemaps can be selected and watershed boundaries displayed.
Figures can be downloaded clicking the download button below the graph displayed.

# Data

In the framework of this study, we focus on discharge data from the global runoff dataset provided by the Global Runoff Data Centre 56068 Koblenz, Germany (GRDC). This unique collection of discharge time series from all over the world represents a key dataset for hydrological research. For further information, please visit:

https://www.bafg.de/GRDC/EN/Home/homepage_node.html

Watershed boundaries were derived by Bernhard Lehner based on the HydroSHEDS drainage network. For more information and access to the corresponding technical report within the GRDC Report Series, please visit:

https://www.bafg.de/GRDC/EN/02_srvcs/22_gslrs/222_WSB/watershedBoundaries_node.html


# Run locally

To run the app on your local machine, take the following steps:

1) Install this R package: ```devtools::install_github("ERottler/meltimr")```

2) Download folder with R-scripts for shiny app *inst/shinyapp*

3) Request runoff data from the Global Runoff Data Centre 56068 Koblenz, Germany (GRDC)

4) Read GRDC meta data from files using *inst/shinyapp/grdc_meta.R*. Therefore, set folder path to GRDC files at the beginning of the script (and optionally also to watershed basins).

5) Open the server file *inst/shinyapp/server.R* and add the paths to the GRDC file directory and the meta data table. Optionally also add the path to the watershed boundaries.

In order to get started without having GRDC data at hand, two synthetic data files in the GRDC-format are located in *inst/shinyapp/data*. Feel free to modify existing analytical tools and add new options and data sources!

# Contact

Should you have any comments, questions or suggestions, please do not hesitate to contact us: rottler(a)uni-potsdam.de

# Funding

This research was funded by Deutsche Forschungsgemeinschaft (DFG) within the graduate research training group NatRiskChange (GRK 2043/1) at the University of Potsdam: https://www.uni-potsdam.de/en/natriskchange
