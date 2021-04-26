###

#Shiny Web App to visualize daily discharge data from large data sets
#User Interface

###

#load packages
library(shiny)
library(shinythemes)
library(leaflet)
# library(leaflet.providers)
library(meltimr)
library(zyp)
library(Kendall)
library(zoo)
library(readr)
library(viridisLite)
library(RColorBrewer)
library(rgdal)
library(sp)

navbarPage("Hydro Explorer", id="nav", theme = shinytheme("sandstone"),

  tabPanel("Interactive map",
    div(class="outer",

      tags$head(
        includeCSS("styles.css")
      ),

      tags$style(type="text/css",
                 ".shiny-output-error { visibility: hidden; }",
                 ".shiny-output-error:before { visibility: hidden; }"
      ),

      leafletOutput("map", width="100%", height="100%"),

      tags$head(tags$style(
        HTML('
             #controls {background-color: rgba(255, 255, 255, 1)}'
      ))),

      # Shiny versions prior to 0.11 should use class = "modal" instead.
      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
        draggable = T, top = 80, left = "auto", right = 20, bottom = "auto",
        width = 650, height = "auto", style = "opacity: 0.99",

        h3("Hydro Explorer"),

        selectInput("ana_method", "Analytical tool", c(
          "Raster graph" = "rasterhydro",
          "Mean graph" = "meanhydro",
          "Volume timing" = "volutime",
          "Annual Max" = "annmax",
          "Percentile graph" = "percenthydro",
          "Filter stations" = "statsfilter"
        )),

        checkboxInput(inputId = "condi_adjust", label = "Interactive options"),

        conditionalPanel("input.ana_method == 'rasterhydro' && (input.condi_adjust == true)",
                         selectInput("break_day_rh", "Select break day:", choices = c("1.Oct", "1.Nov", "1.Dec", "1.Jan"))
        ),
        conditionalPanel("input.ana_method == 'rasterhydro' && (input.condi_adjust == true)",
                         sliderInput("raster_time", label = "Select time frame:", animate = F,
                                     min = 1800, max = 2020, step = 1, value = c(1800,2020), sep = "")
        ),
        conditionalPanel("input.ana_method == 'meanhydro' && (input.condi_adjust == true)",
                         selectInput("break_day_mh", "Select break day:", choices = c("1.Oct", "1.Nov", "1.Dec","1.Jan"))
        ),
        conditionalPanel("input.ana_method == 'meanhydro' && (input.condi_adjust == true)",
                         sliderInput("break_year_mh1", label = "Select time frame 1:", animate = F,
                                     min = 1940, max = 2000, step = 1, value = c(1971, 1990), sep = "")
        ),
        conditionalPanel("input.ana_method == 'meanhydro' && (input.condi_adjust == true)",
                         sliderInput("break_year_mh2", label = "Select time frame 2:", animate = F,
                                     min = 1940, max = 2000, step = 1, value = c(1991, 2010), sep = "")
        ),
        conditionalPanel("input.ana_method == 'meanhydro' && (input.condi_adjust == true)",
                         sliderInput("window_mh", label = "Window width moving averages:", animate = T,
                                     min = 1, max = 90, step = 1, value = 30)
        ),
        conditionalPanel("input.ana_method == 'percenthydro' && (input.condi_adjust == true)",
                         selectInput("plo_sel_per", "Choose plot type:", choices = c("Line plot", "Image plot"))
        ),
        conditionalPanel("input.ana_method == 'percenthydro' && (input.condi_adjust == true)",
                         sliderInput("break_year_ph1", label = "Select time frame 1:", animate = F,
                                     min = 1940, max = 2000, step = 1, value = c(1940, 1960), sep = "")
        ),
        conditionalPanel("input.ana_method == 'percenthydro' && (input.condi_adjust == true)",
                         sliderInput("break_year_ph2", label = "Select time frame 2:", animate = F,
                                     min = 1940, max = 2000, step = 1, value = c(1970, 2000), sep = "")
        ),
        conditionalPanel("input.ana_method == 'percenthydro' && (input.condi_adjust == true) && (input.plo_sel_per == 'Line plot')",
                         sliderInput("percent_ph", label = "Probability:", animate = T,
                                     min = 0.01, max = 0.99, step = 0.01, value = 0.75)
        ),
        conditionalPanel("input.ana_method == 'annmax' && (input.condi_adjust == true)",
                         selectInput("var_sel_ama", "Choose variable:", choices = c("Day of the year", "Magnitude", "Trend Monthly Maxima"))
        ),
        conditionalPanel("input.ana_method == 'annmax' && (input.condi_adjust == true)",
                         sliderInput("years_ama", label = "Select time frame:", animate = F,
                                     min = 1940, max = 2000, step = 1, value = c(1970, 2000), sep = "")
        ),
        conditionalPanel("input.ana_method == 'annmax' && (input.condi_adjust == true)",
                         sliderInput("break_day_ama", "Select break day:", animate = F,
                                     min = 1, max = 365, step = 1, value = 1)
        ),
        conditionalPanel("input.ana_method == 'annmax' && (input.condi_adjust == true)",
                         sliderInput("month_sel_ama", "Select months:", animate = F,
                                     min = 1, max = 12, step = 1, value = c(1, 12))
        ),
        conditionalPanel("input.ana_method == 'volutime' && (input.condi_adjust == true)",
                         selectInput("break_day_vt", "Select break day:", choices = c("1.Oct", "1.Nov", "1.Dec","1.Jan"))
        ),
        conditionalPanel("input.ana_method == 'volutime' && (input.condi_adjust == true)",
                         sliderInput("vol_frame", label = "Select periods to compare:", animate = F,
                                     min = 1940, max = 2000, step = 1, value = c(1940,1965), sep = "")
        ),
        conditionalPanel("input.ana_method == 'statsfilter'",
                         sliderInput("filter_sta_yea", "Maximum start year:",animate = F,
                                     min = 1850, max = 2020, step = 1, value = c(2020), sep = "")
        ),
        conditionalPanel("input.ana_method == 'statsfilter'",
                         sliderInput("filter_end_yea", label = "Minimum end year:", animate = F,
                                     min = 1850, max = 2020, step = 1, value = c(1900), sep = "")
        ),
        conditionalPanel("input.ana_method == 'statsfilter'",
                         sliderInput("filter_lat_upp", label = "Maximum latitude:", animate = F,
                                     min = 0, max = 90, step = 1, value = c(90))
        ),
        conditionalPanel("input.ana_method == 'statsfilter'",
                         sliderInput("filter_lat_low", label = "Minimum latitude:", animate = F,
                                     min = -90, max = 0, step = 1, value = c(-90))
        ),
        conditionalPanel("input.ana_method == 'statsfilter'",
                         sliderInput("filter_lon_left", label = "Minimum longitude:", animate = F,
                                     min = -180, max = 0, step = 1, value = c(-180))
        ),
        conditionalPanel("input.ana_method == 'statsfilter'",
                         sliderInput("filter_lon_right", label = "Maximum longitude:", animate = F,
                                     min = 0, max = 180, step = 1, value = c(180))
        ),

        plotOutput("hydro_plot", width = "100%"),

        downloadButton(outputId = "down", label = "Save Plot", height = "1.0cm")

    )
   )
  ),

  tabPanel("Summary",

           p(style="text-align: justify; font-size: 30px; width: 99%",
             "Short summary"),

           p(style="text-align: justify; font-size: 16px; width: 99%",
             "Climatic changes and anthropogenic modifications of the river network/basin have the potential to fundentally alter river runoff.
             In the framework of this study, we investigate historic changes in runoff seasonality and runoff timing observed at gauging stations all over the world.
             In this regard, we develop the 'HydroExplorer', an interactive shiny web app, which enables the investigation of daily resolution discharge time series from large hydrological data sets.
             The available selection of tools inter alia enables the analysis of changes in mean annual cycles, inter- and intra-annual variability, the timing and magnitude of annual maxima and changes in quantile values over time.
             The interactive nature of the developed web app allows a quick comparison of gauges, regions, methods and times frames, and makes it possible to asses weaknesses and strenghts of individual analytical tools.")

  ),

  tabPanel("Tools",

           HTML("<br><br>"),

           h2("Raster graph"),

           p(style="text-align: justify; font-size: 16px; width: 99%",
             "The raster graph is a three-dimensional surface plot, where the x-axis is the day of the year, the y-axis the individual years and the z-axis the daily value of the investigated variable (e.g streamflow or snow depth). The visualization of the data recordings using raster graphs provides a quick first insight into the dynamics and processes controlling investigated variable at the selected site. This visualization tools enables the display of inter- and intra-annual variabilities in one single figure [1] [2]."),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Interactive options")),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Break day:", style="color:CadetBlue"),  "Customize x-axis by selecting different break days. Currently available selection are 1.October (start hydrological year in Switzerland), 1.November (start hydrological year in Germany), 1.December and 1.January."),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Time frame:", style="color:CadetBlue"), "Select start and end year of time frame displayed."),

           HTML("<br><br>"),

           h2("Mean graph"),

           p(style="text-align: justify; font-size: 16px; width: 99%",
             "Mean annual cycles for two selected time windows (blue and red) are displayed. Vertical lines mark days of the year of annual maxima. The time lag between days of maximum runoff of the two selected time windows is noted top right. The display and comparison of mean annual cycles provides a very good first insight into changes in the seasonal redisbribution of water via seasonal snow packs. The tools simplicity is its strength and weakness at the same time."),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Interactive options")),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Break day:", style="color:CadetBlue"),  "Customize x-axis by selecting different break days. Currently available selection are 1.October (start hydrological year in Switzerland), 1.November (start hydrological year in Germany), 1.December and 1.January."),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Time frame 1: ", style="color:CadetBlue"), "Select start and end year of time frame 1 (blue line)."),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Time frame 2: ", style="color:CadetBlue"), "Select start and end year of time frame 2 (red line)."),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Window width moving averages: ", style="color:CadetBlue"), "Prior the calculation of mean annual cycle a moving average filter can be moved over the time series."),

           HTML("<br><br>"),

           h2("Volume timing"),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             "One approach to investigate the earlier timing of runoff, is to determine the day of the year (DOY) when a certain fraction of the total annual volume passes the gauging station (e.g. [3] [4]). The 'Volume timing' tool displays the DOYs when 25/50/75 % of the total annual runoff were recorded. On top of the pannel, mean DOY, and a linear trend estimation following the Theil-Sen approach (positve = earlier) are noted for each volume fraction. This approach gives a good insight into changes in the redistribution of water by a seasonal snow cover. However, caution has to be exercised interpreting changes, particularly in alpine river basins influenced by reservoirs used for hydro power production."),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Interactive options")),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Break day:", style="color:CadetBlue"),  "Select start day of the year considered. Currently available selection are 1.October (start hydrological year in Switzerland), 1.November (start hydrological year in Germany), 1.December and 1.January."),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Time frame:", style="color:CadetBlue"), "Select start and end year of time frame investigated."),

           HTML("<br><br>"),

           h2("Annual Max"),

           p(style="text-align: justify; font-size: 16px; width: 99%",
             "'Annual Max' is a tool to investigate the timing and magnitude of annual maxima. Furhtermore, the investigation in monthly maxima is possible. Linear trends are calculated using the robust Theil-Sen-approach. For options 'Day of the year' and 'Magnitude', trend magnitudes (per decade) and change over the entire time frame selected are noted top right (positive values = earlier/higher). This tool focuses on the highest discharges and hence is particularly useful in detecting changes in flood characteristics. The interactive options help to get a feeling for the sensitivity of maxima-based approaches to years and months selected."),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Interactive options")),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Variable: ", style="color:CadetBlue"), "Select annual maxima characteristic to be investigated: 'Day of the year' or 'Magnitude'. The option 'Monthly Maxima' returns trends of magnitudes of monthly maxima."),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Time frame:", style="color:CadetBlue"), "Select start and end year of time frame investigated."),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Break day: ", style="color:CadetBlue"),  "Select start day of years. Example: Selecting day 305 means that years are from 1.Nov - 30.Oct. If variable is 'Monthly Maxima' or individual months are selected (see next option), break day is automatically set to 1.Jan."),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Months: ", style="color:CadetBlue"),  "Only selected months are taken into account to determine maxima (1 to 12 = January to December). Example: Selecting 3 to 6 means that only values recorded from March to June are considered to determine annual maxima."),

           HTML("<br><br>"),

           h2("Percentile graph"),

           p(style="text-align: justify; font-size: 16px; width: 99%",
             "Percentile graphs for two different time windows. Quantiles are estimated on a monthly level based on all daily values of a month. In a 40-year time window, quantiles for the month of January, for example, base on 40 times 31 daily values. Quantiles are estimated empirically based on type 8 of the function 'quantile' in the R environment. The Percentile graph option is a powerful tool, as it offers the posibility to investigate changes along the entire runoff range. Changes in low flow situation as well as high flow can be investigated. However, a sufficient length of the time series is crucial. We recommend at least 30 years for each time window."),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Interactive options")),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Plot type:", style="color:CadetBlue"),  "The option 'Line plot' enables the comparison of quantiles of a selected probability level (see option 'Probability'). The 'Image plot' shows the difference between quantile values of different time windows for all probability levels."),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Time frame 1: ", style="color:CadetBlue"), "Select start and end year of time frame 1 (blue line)."),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Time frame 2: ", style="color:CadetBlue"), "Select start and end year of time frame 2 (red line)."),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$b("Probability", style="color:CadetBlue"), "Select which quantile to compare (only relevant for 'Line plot')"),

           HTML("<br><br>"),

           h2("Filter stations"),

           p(style="text-align: justify; font-size: 16px; width: 99%",
             "Filters gauging stations displayed according to minimum start year, minimum end year, minimum/maximum latitude, minimum/maximum longitude."),

           HTML("<br><br>"),

           h2("References"),

           p(style="text-align: justify; font-size: 16px; width: 99%",
             "[1] Koehler, R. 2004. Raster Based Analysis and Visualization of Hydrologic Time Series. Ph.D. dissertation, University of Arizona. Tucson, AZ, 189 p."),

           p(style="text-align: justify; font-size: 16px; width: 99%",
             "[2] Strandhagen, E., Marcus, W.A., and Meacham, J.E. 2006. Views of the rivers: representing streamflow of the greater Yellowstone ecosystem (hotlink to http://geography.uoregon.edu/amarcus/Publications/Strandhagen-et-al_2006_Cart_Pers.pdf). Cartographic Perspectives, no. 55, Fall."),

           p(style="text-align: justify; font-size: 16px; width: 99%",
             "[3] Maurer, E. P., I. T. Stewart, C. Bonfils, P. B. Duffy, and D. Cayan (2007), Detection, attribution, and sensitivity of trends toward earlier streamflow in the Sierra Nevada, J. Geophys. Res., 112, D11118, doi:10.1029/2006JD008088"),

           p(style="text-align: justify; font-size: 16px; width: 99%",
             "[4] Déry, S. J., K. Stahl, R. D. Moore, P. H. Whitfield, B. Menounos, and J. E. Burford (2009), Detection of runoff timing changes in pluvial, nival, and glacial rivers of western Canada, Water Resour. Res., 45, W04426, doi:10.1029/2008WR006975."),

           HTML("<br><br>")

           ),


  tabPanel("Data & Code",

           h1("Data"),

           p(style="text-align: justify; font-size: 16px; width: 99%",
             "The Hydro Explorer enables the investigation of daily resolution streamflow recordings. In the following, an overview on data sets used within the web app. The visualisation and analysis of meteorological time series such as precipitaiton, snow water equivalent or evapotranspiration is not (yet) possible."),

           HTML("<br>"),

           h4("GRDC"),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             "In the framework of this study, we focus on discharge data from the global runoff dataset provided by the",
             tags$a(href="https://www.bafg.de/GRDC/EN/Home/homepage_node.html", "Global Runoff Data Center",
                    style="color:CadetBlue;
                         font-weight: bold;", target="_blank"),
             "56068 Koblenz, Germany (GRDC). This unique collection of discharge time series from all over the world represents a key dataset for hydrological research.",
             tags$a(href="https://www.bafg.de/GRDC/EN/02_srvcs/22_gslrs/222_WSB/watershedBoundaries_node.html",
                    "GRDC Watershed Boundaries",
                    style="color:CadetBlue;
                         font-weight: bold;", target="_blank"),
             "were derived by Bernhard Lehner based on the HydroSHEDS drainage network. The GRDC data displayed was obtained March 2021."),

           HTML("<br>"),

           h4("CAMELS-US"),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$a(href="https://ral.ucar.edu/solutions/products/camels", "CAMELS-US",
                    style="color:CadetBlue;
                         font-weight: bold;", target="_blank"),
             "is a data set of attributes for 671 catchments in the contiguous United States (CONUS). The data set also includes hydrometeorological time series provided by",
             tags$a(href="https://hess.copernicus.org/articles/19/209/2015/", "Newman et al. 2015.",
                    style="color:CadetBlue;
                         font-weight: bold;", target="_blank"),
             "Detailed informatin on the entire data set can be found in ",
             tags$a(href="https://doi.org/10.5194/hess-21-5293-2017", "Addor et al. 2017.",
                    style="color:CadetBlue;
                         font-weight: bold;", target="_blank")
           ),

           HTML("<br>"),

           h4("CAMELS-CL"),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$a(href="https://doi.pangaea.de/10.1594/PANGAEA.894885", "CAMELS-CL",
                    style="color:CadetBlue;
                         font-weight: bold;", target="_blank"),
             "is a  catchment data set for large sample studies in Chile. The data set includes 516 catchments. Apart from measured streamflow the data set includes information on precipitation, temperature, potential evapotranspiration and snow water equivalent. For more information on CAMELS-CL visit the",
             tags$a(href="http://camels.cr2.cl", "CAMELS-CL viewer",
                    style="color:CadetBlue;
                         font-weight: bold;", target="_blank"),
             " or read the related research article by",
             tags$a(href="https://doi.org/10.5194/hess-22-5817-2018", "Alvarez-Garreton et al. 2018.",
                    style="color:CadetBlue;
                         font-weight: bold;", target="_blank")
           ),

           HTML("<br>"),

           h4("CAMELS-BR"),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$a(href="https://doi.org/10.5281/zenodo.3709337", "CAMELS-BR",
                    style="color:CadetBlue;
                         font-weight: bold;", target="_blank"),
             "provides daily observed streamflow for 3679 gauges and meteorological time series and catchment attributes for 897 selected catchments in Brazil. Detailed information are provided in",
             tags$a(href="https://doi.org/10.5194/hess-22-5817-2018", "Chagas et al. 2020",
                    style="color:CadetBlue;
                         font-weight: bold;", target="_blank")
           ),

           HTML("<br>"),

           h4("CAMELS-GB"),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$a(href="https://doi.org/10.5285/8344e4f3-d2ea-44f5-8afa-86d2987543a9", "CAMELS-GB",
                    style="color:CadetBlue;
                         font-weight: bold;", target="_blank"),
             "is the first large-sample catchment hydrology dataset for Great Britian. The datasets provides river flows, catchment attributes and catchment boundaries from the UK National River Flow Archive together with a suite of new meteorological time series and catchment attributes for 671 catchments. A detailed description of the dataset can be found in",
             tags$a(href="https://doi.org/10.5194/essd-12-2459-2020", "Coxon et al. 2020",
                    style="color:CadetBlue;
                         font-weight: bold;", target="_blank"),
             "."
           ),

           HTML("<br>"),

           h4("CAMELS-AUS"),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$a(href="https://doi.pangaea.de/10.1594/PANGAEA.921850", "CAMELS-AUS",
                    style="color:CadetBlue;
                         font-weight: bold;", target="_blank"),
             "is the Australian edition of the Catchment Attributes and Meteorology for Large-sample Studies (CAMELS) series of datasets. The data set comprises 222 unregulated catchments combining hydrometeorological timeseries (streamflow and 18 climatic variables) with 134 attributes related to geology, soil, topography, land cover, anthropogenic influence, and hydroclimatology. A detailed description of the data set can be found in",
             tags$a(href="https://doi.org/10.5194/essd-2020-228", "Keirnan et al. 2021.",
                    style="color:CadetBlue;
                         font-weight: bold;", target="_blank"),
             "."
           ),

           HTML("<br>"),

           h4("LamaH"),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             tags$a(href="https://doi.org/10.5281/zenodo.4525244", "LamaH",
                    style="color:CadetBlue;
                         font-weight: bold;", target="_blank"),
             "(Large-Sample Data for Hydrology and Environmental Sciences for Central Europe) is a new dataset for large-sample studies and comparative hydrology in Central Europe. The data set also contains catchment attributes (topography, climatology, hydrology, land cover, vegetation, soil and geological properties) as well as meteorological time series. For further information, please have a look at the corresponding research article by",
             tags$a(href="https://doi.org/10.5194/essd-2021-72", "Klinger et al. 2021",
                    style="color:CadetBlue;
                         font-weight: bold;", target="_blank"),
             "."
           ),

           HTML("<br><br>"),

           h1("Code"),
           p(style="text-align: justify; font-size: 16px; width: 99%",
             "Source code of this Shiny web app comes in form of an R package and can be accessed at:",
           tags$a(href= "https://github.com/ERottler/meltimr", "github.com/ERottler/meltimr",
                  style="color:CadetBlue;
                         font-weight: bold;", target="_blank")
           ),

           HTML("<br><br><br><br>")
  ),

  tabPanel("Contact",

           p(style="text-align: justify; font-size: 30px; width: 99%",
             "Feedback"),

           p(style="text-align: justify; font-size: 16px; width: 99%",
             "Should you have any comments, questions or suggestions, please do not hesitate to write an email to", tags$b("rottler(at)uni-potsdam.de"), "or visit the repository on GitHub: ",
             tags$a(href= "https://github.com/ERottler/meltimr", "github.com/ERottler/meltimr",
                    style="color:CadetBlue;
                         font-weight: bold;", target="_blank")
           ),

           HTML("<br><br>"),

           p(style="text-align: justify; font-size: 30px; width: 99%",
             "Funding"),

           p(style="text-align: justify; font-size: 16px; width: 99%",
             "This research was funded by Deutsche Forschungsgemeinschaft (DFG) within the graduate research training group",
             tags$a(href="https://www.uni-potsdam.de/en/natriskchange", "NatRiskChange",
                    style="color:CadetBlue;
                         font-weight: bold;", target="_blank"),
             "(GRK 2043/1-P2) at the University of Potsdam.")
  )

)
