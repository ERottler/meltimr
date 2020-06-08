###

#Shiny Web App to visualize discharge data from GRDC - Server

###

#set_up----

grdc_dir <- "/media/rottler/data2/GRDC_DAY" #Path to folder with GRDC data
# grdc_dir <- "/srv/shiny-server/melTim/data" #Path to folder with GRDC data
catc_dir <- "/media/rottler/data2/basin_data/grdc_basins/"
# catc_dir <- "/srv/shiny-server/melTim/basins"

#read grdc meta data
grdc_meta_path <- "/home/rottler/ownCloud/RhineFlow/rhine_snow/R/meltimr/inst/shiny_app/grdc_meta.csv"
grdc_meta <- read.table(file = grdc_meta_path, sep = ";", header = T, stringsAsFactors = F)

#list watersheds available
catch_paths <- list.files(path = catc_dir, pattern = "*\\.shp$", full.names = T)
catch_names <- list.files(path = catc_dir, pattern = "*\\.shp$", full.names = F)

#paths/names GRDC data files
file_paths <- list.files(path = grdc_dir, pattern = "*\\.Cmd", full.names = T)
file_names <- list.files(path = grdc_dir, pattern = "*\\.Cmd", full.names = F)

#Initial dummy catchment
catch_sel <- sp::Polygon(matrix(rep(0, 6), ncol = 2))

#server----

function(input, output, session) {

  #Leaflet map with station filter
  observe({

    filter_sta_yea <- input$filter_sta_yea
    filter_end_yea <- input$filter_end_yea
    filter_lat_upp <- input$filter_lat_upp
    filter_lat_low <- input$filter_lat_low
    filter_lon_left <- input$filter_lon_left
    filter_lon_right <- input$filter_lon_right

    grdc_meta <- grdc_meta[which(grdc_meta$start_series <= filter_sta_yea), ]
    grdc_meta <- grdc_meta[which(grdc_meta$end_series >= filter_end_yea), ]
    grdc_meta <- grdc_meta[which(grdc_meta$latitude < filter_lat_upp), ]
    grdc_meta <- grdc_meta[which(grdc_meta$latitude > filter_lat_low), ]
    grdc_meta <- grdc_meta[which(grdc_meta$longitude > filter_lon_left), ]
    grdc_meta <- grdc_meta[which(grdc_meta$longitude < filter_lon_right), ]

    #Leaflet map with all stations
    output$map <- renderLeaflet({

      leaflet() %>%
        addProviderTiles(providers$Stamen.TerrainBackground, group = "Terrain Background") %>%
        addProviderTiles(providers$OpenStreetMap.HOT,           group = "Open Street Map") %>%

        addCircleMarkers(grdc_meta$longitude, grdc_meta$latitude, label = grdc_meta$name,
                         labelOptions = labelOptions(noHide = F, textOnly = F, direction = "top"),
                         stroke = F, group = "Runoff", fillOpacity = 0.8, fillColor = "darkred",
                         popup = grdc_meta$name,
                         clusterOptions = markerClusterOptions(iconCreateFunction=JS("function (cluster) {
                                                                   var childCount = cluster.getChildCount();
                                                                   if (childCount < 50) {
                                                                     c = 'rgba(210, 10, 10, 255);'
                                                                   } else if (childCount < 100) {
                                                                     c = 'rgba(210, 10, 10, 255);'
                                                                   } else {
                                                                     c = 'rgba(160, 10, 10, 255);'
                                                                   }
                                                                   return new L.DivIcon({ html: '<div style=\"background-color:'+c+'\"><span>' + childCount + '</span></div>', className: 'marker-cluster', iconSize: new L.Point(50, 50) });}"
                         )
                         )
        )  %>%
        addPolygons(data = catch_sel, layerId = "watershed", group = "Watershed") %>%

        addLayersControl(
          baseGroups = c("Terrain Background", "Open Street Map"),
          overlayGroups = c("Watershed"),
          position = "bottomleft",
          options = layersControlOptions(collapsed = TRUE)
        ) %>%
        hideGroup("Watershed") %>%

        fitBounds(lng1 = -50, lng2 = 50, lat1 = -30, lat2 = 60)

    })

  })

  #Initial conditions: 'Select station on map.'
  f_plot <- function(){

    plot(1:10, 1:10, type = "n", axes = F, ylab = "", xlab = "")
    mtext("Select station on map.", line = -1, cex = 1.5)

  }

  output$hydro_plot <- renderPlot({f_plot()})

  #Dummy which gets selected gauge
  gauge_sel <-  shiny::reactiveValues(clicked_gauge = "Basel, Rheinhalle")

  #Reaction to selection of station on map
  observeEvent(input$map_marker_click,{

    gauge_sel$clicked_gauge <- input$map_marker_click

    stat_sel <- which(grdc_meta$latitude == gauge_sel$clicked_gauge$lat)

    grdc_data <- read_grdc(grdc_meta$file_path[stat_sel])
    stat_name <- grdc_meta$name[stat_sel]

    sta_id <- grdc_meta$id[stat_sel]

    #Read catchment
    catch_path <- grep(sta_id, catch_paths, value = T)

    if(length(catch_path) !=1){catch_path <- "xxx"}

    if(file.exists(catch_path)){

      # crswgs84 <- sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
      catch_sel <- rgdal::readOGR(catch_path)
      # catch_sel <- sp::spTransform(catch_sel_raw, CRS = crswgs84)

      # #Set map view to boudary limits
      # map_view <- raster::extent(sp::bbox(catch_sel)) + c(0, 2, -1.5, 1.5)
    }else{
      catch_sel <- sp::Polygon(matrix(rep(0, 6), ncol =2))
    }

    leafletProxy("map") %>%
      removeShape(layerId = "watershed") %>%
      addPolygons(data = catch_sel, layerId = "watershed", fill = F,
                  color = "#366488", opacity = 0.9, group = "Watershed") %>%
    addLayersControl(
      baseGroups = c("Terrain Background", "Open Street Map"),
      overlayGroups = c("Watershed"),
      position = "bottomleft",
      options = layersControlOptions(collapsed = TRUE)
    )

    #Raster graph: Reset parameter at selection of new station
    observe({

      sta_yea_cla <- as.numeric(format(grdc_data$date[1], "%Y"))

      end_yea_cla <- as.numeric(format(grdc_data$date[nrow(grdc_data)], "%Y"))

      rast_time_init <- c(sta_yea_cla, end_yea_cla)

      updateSliderInput(session, "raster_time", label = "Select time frame:",
                        min = sta_yea_cla, max = end_yea_cla, step = 1, value = rast_time_init)
    })

    #Mean graph: Reset parameter at selection of new station
    observe({

      sta_yea_cla <- as.numeric(format(grdc_data$date[1], "%Y"))

      end_yea_cla <- as.numeric(format(grdc_data$date[nrow(grdc_data)], "%Y"))

      rast_time_init <- c(sta_yea_cla, end_yea_cla)

      updateSliderInput(session, "break_year_mh1", label = "Select time frame 1:",
                        min = sta_yea_cla, max = end_yea_cla, step = 1, value = c(1927, 1981))

      updateSliderInput(session, "break_year_mh2", label = "Select time frame 2:",
                        min = sta_yea_cla, max = end_yea_cla, step = 1, value = c(1982, 2016))

    })

    #Percentile graph: Reset parameter at selection of new station
    observe({

      sta_yea_cla <- as.numeric(format(grdc_data$date[1], "%Y"))

      end_yea_cla <- as.numeric(format(grdc_data$date[nrow(grdc_data)], "%Y"))

      rast_time_init <- c(sta_yea_cla, end_yea_cla)

      updateSliderInput(session, "break_year_ph1", label = "Select time frame 1:",
                        min = sta_yea_cla, max = end_yea_cla, step = 1, value = c(1927, 1971))

      updateSliderInput(session, "break_year_ph2", label = "Select time frame 2:",
                        min = sta_yea_cla, max = end_yea_cla, step = 1, value = c(1972, 2016))
    })

    #Annual Max graph: Reset parameter at selection of new station
    observe({

      if(input$break_day_ama == 1){
        sta_yea_ama <- as.numeric(format(grdc_data$date[1], "%Y"))
      }else{
        sta_yea_ama <- as.numeric(format(grdc_data$date[1], "%Y")) + 1
      }

      end_yea_ama <- as.numeric(format(grdc_data$date[nrow(grdc_data)], "%Y"))

      if(input$break_day_ama == 1){
        sta_yea_ama <- as.numeric(format(grdc_data$date[1], "%Y"))
      }else{
        sta_yea_ama <- as.numeric(format(grdc_data$date[1], "%Y")) + 1
      }

      updateSliderInput(session, "years_ama", label = "Select time frame:",
                        min = sta_yea_ama, max = end_yea_ama, step = 1, value = c(sta_yea_ama, end_yea_ama))

    })

    #Volume timing: Reset parameter at selection of new station
    observe({

      sta_yea_cla <- as.numeric(format(grdc_data$date[1], "%Y"))

      end_yea_cla <- as.numeric(format(grdc_data$date[nrow(grdc_data)], "%Y"))

      rast_time_init <- c(sta_yea_cla, end_yea_cla)

      updateSliderInput(session, "vol_frame", label = "Select time frame:",
                        min = sta_yea_cla, max = end_yea_cla, step = 1, value = rast_time_init)
    })

    f_plot <- function(){

      if(input$ana_method == "rasterhydro"){

          sta_yea_cla <- as.numeric(format(grdc_data$date[1], "%Y"))

          end_yea_cla <- as.numeric(format(grdc_data$date[nrow(grdc_data)], "%Y"))

          if(input$break_day_rh == "1.Oct"){my_break_day = 274}
          if(input$break_day_rh == "1.Nov"){my_break_day = 304}
          if(input$break_day_rh == "1.Dec"){my_break_day = 334}
          if(input$break_day_rh == "1.Jan"){my_break_day =   0}

          #Order data by day (including break day to set start hydrologica year)
          data_day <- ord_day(data_in = grdc_data$value,
                              date = grdc_data$date,
                              start_y = input$raster_time[1],
                              end_y = input$raster_time[2],
                              break_day = my_break_day,
                              do_ma = F,
                              window_width = 30)

          raster_hydro(data_day = data_day,
                       break_day = my_break_day,
                       sta_yea_cla = input$raster_time[1],
                       end_yea_cla = input$raster_time[2],
                       stat_name = stat_name)

        }

      if(input$ana_method == "meanhydro"){

        sta_yea_cla <- as.numeric(format(grdc_data$date[1], "%Y"))

        end_yea_cla <- as.numeric(format(grdc_data$date[nrow(grdc_data)], "%Y"))

        if(input$break_day_mh == "1.Oct"){my_break_day = 274}
        if(input$break_day_mh == "1.Nov"){my_break_day = 304}
        if(input$break_day_mh == "1.Dec"){my_break_day = 334}
        if(input$break_day_mh == "1.Jan"){my_break_day =   0}

        yea_cla_1 <- input$break_year_mh1[1]
        yea_cla_2 <- input$break_year_mh1[2]
        yea_cla_3 <- input$break_year_mh2[1]
        yea_cla_4 <- input$break_year_mh2[2]
        my_window <- input$window_mh

        #Order data by day (including break day to set start hydrologica year)
        data_day <- ord_day(data_in = grdc_data$value,
                            date = grdc_data$date,
                            start_y = sta_yea_cla,
                            end_y = end_yea_cla,
                            break_day = my_break_day,
                            do_ma = T,
                            window_width = my_window)

        mean_hydro(data_day = data_day,
                   break_day = my_break_day,
                   yea_cla_1 = yea_cla_1,
                   yea_cla_2 = yea_cla_2,
                   yea_cla_3 = yea_cla_3,
                   yea_cla_4 = yea_cla_4,
                   end_yea_cla = end_yea_cla,
                   sta_yea_cla = sta_yea_cla,
                   stat_name = stat_name
                   )

      }

      if(input$ana_method == "volutime"){

        if(input$break_day_vt == "1.Oct"){my_break_day = 274}
        if(input$break_day_vt == "1.Nov"){my_break_day = 304}
        if(input$break_day_vt == "1.Dec"){my_break_day = 334}
        if(input$break_day_vt == "1.Jan"){my_break_day =   0}

        sta_yea_cla <- input$vol_frame[1]
        end_yea_cla <- input$vol_frame[2]

        #Order data by day (including break day to set start hydrologica year)
        data_day <- ord_day(data_in = grdc_data$value,
                            date = grdc_data$date,
                            start_y = sta_yea_cla,
                            end_y = end_yea_cla,
                            break_day = my_break_day,
                            do_ma = F,
                            window_width = 30
        )

        #only years with complete recordings
        for(i in 1:nrow(data_day)){

          data_day[i, ] <- na_check(data_day[i, ])

        }

        #Cumulative sum discharges per year
        data_cumsum <- apply(data_day, 1, cumsum)

        #Scale cumsums by deviding by last element array
        data_cumsum_scale <- apply(data_cumsum, 2, cumsum_scale)

        #DOY percentage discharge through

        percents <- c(0.25, 0.50, 0.75)
        day_cross <- matrix(nrow = length(percents), ncol = ncol(data_cumsum_scale))

        for(p in 1:length(percents)){

          for(i in 1:ncol(data_cumsum_scale)){

            if(length(which(is.na(data_cumsum_scale[, i]))) > 0){
              day_cross[p, i] <- NA
            }else{
              day_cross[p, i] <- day_cross[p, i] <- min(which(data_cumsum_scale[, i] > percents[p]))
            }
          }
        }

        #Slope and mean of crossing days
        decs <- length(sta_yea_cla:end_yea_cla)/10
        day_cross_slo <- apply(day_cross, 1, sens_slo) * 10 * -1 # [day/dec]
        day_cross_day <- apply(day_cross, 1, sens_slo) * 10 * -1 *decs # [days]
        day_cross_mea <- apply(day_cross, 1, mea_na)

        volu_time(day_cross = day_cross,
                  sta_yea_cla = sta_yea_cla,
                  end_yea_cla = end_yea_cla,
                  break_day = my_break_day,
                  day_cross_slo = day_cross_slo,
                  day_cross_mea = day_cross_mea,
                  day_cross_day = day_cross_day,
                  stat_name = stat_name)

      }

      if(input$ana_method == "percenthydro"){

        sta_yea_per <- as.numeric(format(grdc_data$date[1], "%Y"))

        end_yea_per <- as.numeric(format(grdc_data$date[nrow(grdc_data)], "%Y"))

        yea_per_1 <- input$break_year_ph1[1]
        yea_per_2 <- input$break_year_ph1[2]
        yea_per_3 <- input$break_year_ph2[1]
        yea_per_4 <- input$break_year_ph2[2]
        perc_sel <- input$percent_ph

        if(input$plo_sel_per == "Line plot"){plot_per <- "line"}
        if(input$plo_sel_per == "Image plot"){plot_per <- "image"}

        #Order data by day (including break day to set start hydrologica year)
        data_day <- ord_day(data_in = grdc_data$value,
                            date = grdc_data$date,
                            start_y = sta_yea_per,
                            end_y = end_yea_per,
                            break_day = 0,
                            do_ma = F,
                            window_width = 30)

        perc_hydro(data_day = data_day,
                   perc_sel = perc_sel,
                   yea_per_1 = yea_per_1,
                   yea_per_2 = yea_per_2,
                   yea_per_3 = yea_per_3,
                   yea_per_4 = yea_per_4,
                   end_yea_per = end_yea_per,
                   sta_yea_per = sta_yea_per,
                   stat_name = stat_name,
                   plot_per = plot_per)

      }

      if(input$ana_method == "annmax"){

        if(input$var_sel_ama == "Day of the year"){ama_var <- "ama_doy"}
        if(input$var_sel_ama == "Magnitude"){ama_var <- "ama_mag"}
        if(input$var_sel_ama == "Trend Monthly Maxima"){ama_var <- "ama_mon"}

        my_break_day <- input$break_day_ama - 1 # minus 1, so that 1 is 1st Jan

        sta_yea_ama <- as.numeric(format(grdc_data$date[1], "%Y"))

        end_yea_ama <- as.numeric(format(grdc_data$date[nrow(grdc_data)], "%Y"))

        yea_ama_1 <- input$years_ama[1]
        yea_ama_2 <- input$years_ama[2]

        month_sel_1 <- input$month_sel_ama[1]
        month_sel_2 <- input$month_sel_ama[2]

        if(length(month_sel_1:month_sel_2) < 12){#if months selected, then break day to 1.Jan
          my_break_day <- 0
        }

        if(ama_var == "ama_mon"){#if monthly mangitudes, then break day to 1.Jan
          my_break_day <- 0
        }

        #Order data by day (including break day to set start hydrologica year)
        data_day <- ord_day(data_in = grdc_data$value,
                            date = grdc_data$date,
                            start_y = sta_yea_ama,
                            end_y = end_yea_ama,
                            break_day = my_break_day,
                            do_ma = F,
                            window_width = 30)

        annmax_plot(data_day = data_day,
                    break_day = my_break_day,
                    yea_ama_1 = yea_ama_1,
                    yea_ama_2 = yea_ama_2,
                    end_yea_ama = end_yea_ama,
                    sta_yea_ama = sta_yea_ama,
                    stat_name = stat_name,
                    month_sel_1 = month_sel_1,
                    month_sel_2 = month_sel_2,
                    ama_var = ama_var)

      }

      if(input$ana_method == "statsfilter"){

        plot(1:10, 1:10, type = "n", axes = F, ylab = "", xlab = "")
        mtext("Filter stations using options above.", line = -1, cex = 1.5)

      }
    }

    output$hydro_plot <- renderPlot({f_plot()})

    output$down <- downloadHandler(

      filename = function(){

        paste0("meltim.png")

      },
      content = function(file){

        png(file, width = 800, height = 450) #open device

        f_plot()#creat plot

        dev.off() #close device

      }

      )

  })

}
