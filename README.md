# Summary

Climatic changes and anthropogenic modifications of the river basin or river network have the potential to fundamentally alter river runoff. In the framework of this study, we aim to investigate historic changes in runoff timing and runoff seasonality observed at discharge gauges all over the world. In this regard, we develop the Hydro Explorer, an interactive web app, which enables the investigation of daily resolution discharge time series. The available selection of analytical tools inter alia enables the investigation of changes in mean annual cycles, inter- and intra-annual variability, the timing and magnitude of annual maxima and changes in quantile values over time. The interactive nature of the developed web app allows a quick comparison of gauges, regions, methods and times frames and makes it possible to assess weaknesses and strengths of individual analytical tools. The tool framework can be re-used to visualise other data sets, existing analytical approaches modified and new methods added.

# Hydro Explorer

The web app can be viewed at: http://natriskchange.ad.umwelt.uni-potsdam.de:3838/HydroExplorer/

Key component of the shiny web app is an interactive leaflet map. On click, observations of the selected gauging station are displayed in the draggable viewer panel. Via a dropdown menu, different analytical tools can be selected. A short description of available tools and interactive options can be found in the tab 'TOOLS'. The dropdown menu for selecting analytical tools also contains the option to filter stations displayed on the map. Selections can be made according to data coverage and location. Using the layer control on the bottom left of the map, different basemaps can be selected and watershed boundaries displayed. Figures can be downloaded clicking the download button below the graph displayed. A rearch article including a detailed description of the interactive web app and available tools can be found at: https://doi.org/10.1002/rra.3772

# Data

Initially, the focus was on discharge data from the global runoff dataset provided by the Global Runoff Data Centre 56068 Koblenz, Germany (GRDC). This unique collection of discharge time series (including watershed boundaries for most of the gauges) from all over the world represents a key dataset for hydrological research and can be downloaded via the [GRDC Data Portal](https://portal.grdc.bafg.de/).

As part of the development towards Hydro Explorer v2.0, daily resolution streamflow recordings provided within other large-sample data sets for hydrology were implemented. These include streamflow observations from [CAMELS-US](https://doi.org/10.5194/hess-21-5293-2017), [CAMELS-BR](https://doi.org/10.5194/essd-12-2075-2020), [CAMELS-GB](https://doi.org/10.5194/essd-12-2459-2020), [CAMELS-CL](https://doi.org/10.5194/hess-22-5817-2018), [CAMELS-AUS](https://doi.org/10.5194/essd-2020-228) amd [LamaH](https://doi.org/10.5194/essd-2021-72).

# Architecture

The web app was implemented based on the R package [Shiny](https://shiny.rstudio.com/). The core of the Hydro Explorer consists of the typical two-file structure of a Shiny web app. One R-file defines the layout and the appearance of the web app (ui.R) and another one contains all computational instructions (server.R). The Hydro Explorer is part of the R package 'meltimr'. All functions the Hydro Explorer needs are incorporated in this R package. We chose this set-up to enable easy sharing and installation of the programme code. Existing tools can be easily modified and new analytical approaches added. All analytical tools also can be used outside the web app environment.

As a first step to get the web app running, a table containing all meta information about all discharge time series from all data sources needs to be compiled (disc_meta.R). All necessary file paths are define in (set_dir.R). All data that is read in at start-up of the web app is saved in data_load.R.

# Modify and add analytical tools/data sources

Feel free to modify existing analytical tools and add new options and data sources! User feedback and contributions are highly welcome. Should you have questions or encounter problems, please report using the [GitHub Issue Tracker](https://github.com/ERottler/meltimr/issues) or write an email: erwin.rottler(a)uni-potsdam.de To fix a bug or make other improvements, please consider sending a [pull request](https://github.com/ERottler/meltimr/pulls).

# Funding

This research was funded by Deutsche Forschungsgemeinschaft (DFG) within the graduate research training group NatRiskChange (GRK 2043/1) at the University of Potsdam: https://www.uni-potsdam.de/en/natriskchange
