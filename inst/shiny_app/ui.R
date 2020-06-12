###

#Shiny Web App to visualize discharge data from GRDC
#User Interface
#Erwin Rottler, University of Potsdam, 2019/2020

###

#load packages
library(shiny)
library(shinythemes)
library(leaflet)
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

      leafletOutput("map", width="100%", height="100%"),

      tags$head(tags$style(
        HTML('
             #controls {background-color: rgba(255, 255, 255, 1)}'
      ))),
      # Shiny versions prior to 0.11 should use class = "modal" instead.
      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
        draggable = T, top = 80, left = "auto", right = 20, bottom = "auto",
        width = 650, height = "auto", style = "opacity: 0.99",

        h3("Hydro explorer"),

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
                                     min = 1800, max = 2020, step = 1, value = c(1800,2020))
        ),
        conditionalPanel("input.ana_method == 'meanhydro' && (input.condi_adjust == true)",
                         selectInput("break_day_mh", "Select break day:", choices = c("1.Oct", "1.Nov", "1.Dec","1.Jan"))
        ),
        conditionalPanel("input.ana_method == 'meanhydro' && (input.condi_adjust == true)",
                         sliderInput("break_year_mh1", label = "Select time frame 1:", animate = F,
                                     min = 1940, max = 2000, step = 1, value = c(1940, 1960))
        ),
        conditionalPanel("input.ana_method == 'meanhydro' && (input.condi_adjust == true)",
                         sliderInput("break_year_mh2", label = "Select time frame 2:", animate = F,
                                     min = 1940, max = 2000, step = 1, value = c(1970, 2000))
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
                                     min = 1940, max = 2000, step = 1, value = c(1940, 1960))
        ),
        conditionalPanel("input.ana_method == 'percenthydro' && (input.condi_adjust == true)",
                         sliderInput("break_year_ph2", label = "Select time frame 2:", animate = F,
                                     min = 1940, max = 2000, step = 1, value = c(1970, 2000))
        ),
        conditionalPanel("input.ana_method == 'percenthydro' && (input.condi_adjust == true)",
                         sliderInput("percent_ph", label = "Probability:", animate = T,
                                     min = 0.01, max = 0.99, step = 0.01, value = 0.75)
        ),
        conditionalPanel("input.ana_method == 'annmax' && (input.condi_adjust == true)",
                         selectInput("var_sel_ama", "Choose variable:", choices = c("Day of the year", "Magnitude", "Trend Monthly Maxima"))
        ),
        conditionalPanel("input.ana_method == 'annmax' && (input.condi_adjust == true)",
                         sliderInput("years_ama", label = "Select time frame:", animate = F,
                                     min = 1940, max = 2000, step = 1, value = c(1970, 2000))
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
                                     min = 1940, max = 2000, step = 1, value = c(1940,1965))
        ),
        conditionalPanel("input.ana_method == 'statsfilter'",
                         sliderInput("filter_sta_yea", "Minimum start year:",animate = F,
                                     min = 1850, max = 2016, step = 1, value = c(1945))
        ),
        conditionalPanel("input.ana_method == 'statsfilter'",
                         sliderInput("filter_end_yea", label = "Minimum end year:", animate = F,
                                     min = 1850, max = 2016, step = 1, value = c(1985))
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

        downloadButton(outputId = "down", label = "Download", height = "1.0cm")

    )
   )
  ),

  tabPanel("Summary",

           p("Climatic changes and anthropogenic modifications of the river network/basin have the potential to fundentally alter river runoff. In the framework of this study, we investigate historic changes in runoff seasonality and runoff timing observed at gauging stations all over the world. In this regard, we develop the 'HydroExplorer', an interactive shiny web app, which enables the investigation of >7000 time series. The available selection of tools inter alia enables the analysis of changes in mean annual cycles, inter- and intra-annual variability, the timing and magnitude of annual maxima and changes in quantile values over time. The interactive nature of the developed web app allows a quick comparison of gauges, regions, methods and times frames, and makes it possible to asses weaknesses and strenghts of individual analytical tools.")

           ),

  tabPanel("Tools",

           hr(),

           h3("Raster graph"),
           p("The raster graph is a three-dimensional surface plot where the x-axis is the day of the year, the y-axis the individual years and the z-axis the daily value of the investigated variable (e.g streamflow or snow depth). The visualization of the data recordings using raster graphs provides a quick first insight into the dynamics and processes controlling investigated variable at the selected site. This visualization tools enables the display of inter- and intra-annual variabilities in one single figure [1] [2]."),
           tags$b("Interactive options"),
           p(tags$a("Break day:"),  "Customize x-axis by selecting different break days. Currently available selection are 1.October (start hydrological year in Switzerland), 1.November (start hydrological year in Germany), 1.December and 1.January."),
           p(tags$a("Time frame:"), "Select start and end year of time frame displayed."),

           hr(),

           h3("Mean graph"),
           p("Mean annual cycles for two selected time windows (blue and red) are displayed. Vertical lines mark days of the year of annual maxima. The time lag between days of maximum runoff of the two selected time windows is noted top right. The display and comparison of mean annual cycles provides a very good first insight into changes in the seasonal redisbribution of water via seasonal snow packs. The tools simplicity is its strength and weakness at the same time."),
           tags$b("Interactive options"),
           p(tags$a("Break day:"),  "Customize x-axis by selecting different break days. Currently available selection are 1.October (start hydrological year in Switzerland), 1.November (start hydrological year in Germany), 1.December and 1.January."),
           p(tags$a("Time frame 1: "), "Select start and end year of time frame 1 (blue line)."),
           p(tags$a("Time frame 2: "), "Select start and end year of time frame 2 (red line)."),
           p(tags$a("Window width moving averages: "), "Prior the calculation of mean annual cycle a moving average filter can be moved over the time series."),

           hr(),

           h3("Volume timing"),
           p("One approach to investigate the earlier timing of runoff, is to determine the day of the year (DOY) when a certain fraction of the total annual volume passes the gauging station (e.g. [3] [4]). The 'Volume timing' tool displays the DOYs when 25/50/75 % of the total annual runoff were recorded. On top of the pannel, mean DOY, and a linear trend (Sens's slope) estimation (positve = earlier) are noted for each volume fraction. This approach gives a good insight into changes in the redistribution of water by a seasonal snow cover. However, caution has to be exercised interpreting changes, particularly in alpine river basins influenced by reservoirs used for hydro power production."),
           tags$b("Interactive options"),
           p(tags$a("Break day:"),  "Select start day of the year considered. Currently available selection are 1.October (start hydrological year in Switzerland), 1.November (start hydrological year in Germany), 1.December and 1.January."),
           p(tags$a("Time frame:"), "Select start and end year of time frame investigated."),

           hr(),

           h3("Annual Max"),
           p("'Annual Max' is a tool to investigate the timing and magnitude of annual maxima. Furhtermore, the investigation in monthly maxima is possible. Linear trends are calculated using the robust Theil-Sen-approach. For options 'Day of the year' and 'Magnitude', trend magnitudes (per decade) and change over the entire time frame selected are noted top right (positive values = earlier/higher). This tool focuses on the highest discharges and hence is particularly useful in detecting changes in flood characteristics. The interactive options help to get a feeling for the sensitivity of maxima-based approaches to years and months selected."),
           tags$b("Interactive options"),
           p(tags$a("Variable: "), "Select annual maxima characteristic to be investigated: 'Day of the year' or 'Magnitude'. The option 'Monthly Maxima' returns trends of magnitudes of monthly maxima."),
           p(tags$a("Time frame:"), "Select start and end year of time frame investigated."),
           p(tags$a("Break day: "),  "Select start day of years. Example: Selecting day 305 means that years are from 1.Nov - 30.Oct. If variable is 'Monthly Maxima' or individual months are selected (see next option), break day is automatically set to 1.Jan."),
           p(tags$a("Months: "),  "Only selected months are taken into account to determine maxima (1 to 12 = January to December). Example: Selecting 3 to 6 means that only values recorded from March to June are considered to determine annual maxima."),

           hr(),

           h3("Percentile graph"),
           p("Percentile graphs for two different time windows. Quantiles are estimated on a monthly level based on all daily of a month. In a 40-year time window, quantiles for the month of January, for example, base on 40 times 31 daily values. Quantiles are estimated empirically based on type 8 of the function 'quantile' in the R environment. The Percentile graph option is a powerful tool, as it offers the posibility to investigate changes along the entire runoff range. Changes in low flow situation as well as high flow can be investigated. However, a sufficient length of the time series is crucial. We recommend at least 30 years for each time window."),
           tags$b("Interactive options"),
           p(tags$a("Plot type:"),  "The option 'Line plot' enables the comparison of quantiles of a selected probability level (see option 'Probability'). The 'Image plot' shows the difference between quantile values of different time windows for all probability levels."),
           p(tags$a("Time frame 1: "), "Select start and end year of time frame 1 (blue line)."),
           p(tags$a("Time frame 2: "), "Select start and end year of time frame 2 (red line)."),
           p(tags$a("Probability"), "Select which quantile to compare (only relevant for 'Line plot')"),

           hr(),

           h3("Filter stations"),
           p("Filters gauging stations displayed according to minimum start year, minimum end year, minimum/maximum latitude, minimum/maximum longitude."),

           hr(),


           h3("References"),
           p("[1] Koehler, R. 2004. Raster Based Analysis and Visualization of Hydrologic Time Series. Ph.D. dissertation, University of Arizona. Tucson, AZ, 189 p."),

           p("[2] Strandhagen, E., Marcus, W.A., and Meacham, J.E. 2006. Views of the rivers: representing streamflow of the greater Yellowstone ecosystem (hotlink to http://geography.uoregon.edu/amarcus/Publications/Strandhagen-et-al_2006_Cart_Pers.pdf). Cartographic Perspectives, no. 55, Fall."),

           p("[3] Maurer, E. P., I. T. Stewart, C. Bonfils, P. B. Duffy, and D. Cayan (2007), Detection, attribution, and sensitivity of trends toward earlier streamflow in the Sierra Nevada, J. Geophys. Res., 112, D11118, doi:10.1029/2006JD008088"),

           p("[4] Déry, S. J., K. Stahl, R. D. Moore, P. H. Whitfield, B. Menounos, and J. E. Burford (2009), Detection of runoff timing changes in pluvial, nival, and glacial rivers of western Canada, Water Resour. Res., 45, W04426, doi:10.1029/2008WR006975.")

           ),

  tabPanel("Data & Code",

           h3("Data"),
           p("In the framework of this study, we focus on discharge data from the global runoff dataset provided by the Global Runoff Data Centre 56068 Koblenz, Germany (GRDC). This unique collection of discharge time series from all over the world represents a key dataset for hydrological research. For further information, please visit:"),
           tags$a(href="https://www.bafg.de/GRDC/EN/Home/homepage_node.html", "Global Runoff Database"),

           hr(),

           p("Watershed boundaries were derived by Bernhard Lehner based on the HydroSHEDS drainage network. For more information and access to the corresponding technical report within the GRDC Report Series, please visit:"),
           tags$a(href="https://www.bafg.de/GRDC/EN/02_srvcs/22_gslrs/222_WSB/watershedBoundaries_node.html", "GRDC Watershed Boundaries"),

           hr(),

           h3("Code"),
           p("Source code of this shiny web app comes in form of an R package and can be accessed at:"),
           tags$a(href= "https://github.com/ERottler/meltimr", "github.com/ERottler/meltimr")
  ),

  tabPanel("Contact",
           h3("Feedback"),
           p("Should you have any comments, questions or suggestions, please do not hesitate to contact us: rottler(at)uni-potsdam.de"),
           h3("Funding"),
           p("This research was funded by Deutsche Forschungsgemeinschaft (DFG) within the graduate research training group NatRiskChange (GRK 2043/1) at the University of Potsdam:"),
           tags$a(href="https://www.uni-potsdam.de/en/natriskchange", "RTG NatRiskChange")
  )

)
