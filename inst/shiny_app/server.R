###

#Shiny Web App to visualize daily discharge data from large data sets
#Server file

###

#set_up----

#get folder paths defined in set_dir.R
source(paste0(getwd(), "/set_dir.R"))

#read discharge meta data
disc_meta <- read.table(file = disc_meta_path, sep = ";", header = T, stringsAsFactors = F)

#list GRDC watersheds available
catch_paths_grdc <- list.files(path = grdc_catc_dir, pattern = "*\\.shp$", full.names = T)
catch_names_grdc <- list.files(path = grdc_catc_dir, pattern = "*\\.shp$", full.names = F)

#LamaH watershed boundaries
catch_lamah <- rgdal::readOGR(paste0(lamah_dir, "/A_basins_total_upstrm/3_shapefiles/Upstrm_area_total.shp"))

#CAMELS-US watershed boundaries
catch_usgs <- rgdal::readOGR(paste0(camels_us_catch_dir, "/HCDN_nhru_final_671.shp"))

#CAMELS-BR watershed boundaries
catch_brazil <- rgdal::readOGR(paste0(camels_br_dir, "/14_CAMELS_BR_catchment_boundaries/camels_br_catchments.shp"))

#Initial dummy catchment
catch_sel <- sp::Polygon(matrix(rnorm(10, 0, 0.01), ncol = 2))

#server----

function(input, output, session) {

  query_modal <- modalDialog(
    title = "Welcome to the Hydro Explorer!",
    "Analyze daily resolution discharge time series with regard to runoff timing and runoff seasonality. Switch between tabs to read a short summary and get more information on available analytical tools, discharge data sets and source code.",
    easyClose = F,
    footer = tagList(
      actionButton("start_window", "Explore")
    )
  )

  # Show the model on start up ...
  showModal(query_modal)

  observeEvent(input$start_window, {
    removeModal()
  })

  #Leaflet map with station filter
  observe({

    filter_sta_yea <- input$filter_sta_yea
    filter_end_yea <- input$filter_end_yea
    filter_lat_upp <- input$filter_lat_upp
    filter_lat_low <- input$filter_lat_low
    filter_lon_left <- input$filter_lon_left
    filter_lon_right <- input$filter_lon_right

    disc_meta <- disc_meta[which(disc_meta$start_series <= filter_sta_yea), ]
    disc_meta <- disc_meta[which(disc_meta$end_series >= filter_end_yea), ]
    disc_meta <- disc_meta[which(disc_meta$latitude < filter_lat_upp), ]
    disc_meta <- disc_meta[which(disc_meta$latitude > filter_lat_low), ]
    disc_meta <- disc_meta[which(disc_meta$longitude > filter_lon_left), ]
    disc_meta <- disc_meta[which(disc_meta$longitude < filter_lon_right), ]

    #Leaflet map with all stations
    output$map <- renderLeaflet({

      m = leaflet() %>%
        addProviderTiles(providers$Stamen.TerrainBackground, group = "Terrain Background") %>%
        addProviderTiles(providers$OpenStreetMap.HOT,        group = "Open Street Map") %>%
        # addProviderTiles(providers$Stamen.TonerBackground,   group = "Toner Background") %>%
        addPolygons(data = catch_sel, layerId = "watershed", group = "Watershed") %>%

        addLayersControl(
          baseGroups = c("Terrain Background", "Open Street Map"),
          overlayGroups = c("GRDC", "LamaH", "CAMELS-US", "CAMELS-BR", "Watershed"),
          position = "bottomleft",
          options = layersControlOptions(collapsed = F)
        ) %>%
        # hideGroup("Watershed") %>%

        fitBounds(lng1 = -50, lng2 = 50, lat1 = -30, lat2 = 60)

        if(length(which(disc_meta$source == "grdc")) > 0){
          m = m %>%
              addCircleMarkers(disc_meta$longitude[which(disc_meta$source == "grdc")],
                               disc_meta$latitude[which(disc_meta$source == "grdc")],
                               label = disc_meta$name[which(disc_meta$source == "grdc")],
                               labelOptions = labelOptions(noHide = F, textOnly = F, direction = "top"),
                               stroke = F, group = "GRDC", fillOpacity = 0.8, fillColor = "#993300",
                               popup = disc_meta$name[which(disc_meta$source == "grdc")],
                               clusterOptions = markerClusterOptions(iconCreateFunction=JS("function (cluster) {
                                                                   var childCount = cluster.getChildCount();
                                                                   if (childCount < 100) {
                                                                     c = '#993300;'
                                                                   } else if (childCount < 200) {
                                                                     c = '#993300;'
                                                                   } else {
                                                                     c = '#993300;'
                                                                   }
                                                                   return new L.DivIcon({ html: '<div style=\"background-color:'+c+' color: #FFFFFF\"><span>' + childCount + '</span></div>', className: 'marker-cluster', iconSize: new L.Point(50, 50) }) ;}"
                                  )
                                  )
                               )
        }

        if(length(which(disc_meta$source == "lamah")) > 0){

          m = m %>%
              addCircleMarkers(disc_meta$longitude[which(disc_meta$source == "lamah")],
                               disc_meta$latitude[which(disc_meta$source == "lamah")],
                               label = disc_meta$name[which(disc_meta$source == "lamah")],
                               labelOptions = labelOptions(noHide = F, textOnly = F, direction = "top"),
                               stroke = F, group = "LamaH", fillOpacity = 0.8, fillColor = '#006699',
                               popup = disc_meta$name[which(disc_meta$source == "lamah")],
                               clusterOptions = markerClusterOptions(iconCreateFunction=JS("function (cluster) {
                                                                   var childCount = cluster.getChildCount();
                                                                   if (childCount < 50) {
                                                                     c = '#006699;'
                                                                   } else if (childCount < 100) {
                                                                     c = '#006699;'
                                                                   } else {
                                                                     c = '#006699;'
                                                                   }
                                                                   return new L.DivIcon({ html: '<div style=\"background-color:'+c+' color: #FFFFFF\"><span>' + childCount + '</span></div>', className: 'marker-cluster', iconSize: new L.Point(50, 50) });}"
                         )
                         )
              )
        }

        if(length(which(disc_meta$source == "usgs")) > 0){
          m = m %>%
              addCircleMarkers(disc_meta$longitude[which(disc_meta$source == "usgs")],
                               disc_meta$latitude[which(disc_meta$source == "usgs")],
                               label = disc_meta$name[which(disc_meta$source == "usgs")],
                               labelOptions = labelOptions(noHide = F, textOnly = F, direction = "top"),
                               stroke = F, group = "CAMELS-US", fillOpacity = 0.8, fillColor = '#FFCC33',
                               popup = disc_meta$name[which(disc_meta$source == "usgs")],
                               clusterOptions = markerClusterOptions(iconCreateFunction=JS("function (cluster) {
                                                                   var childCount = cluster.getChildCount();
                                                                   if (childCount < 50) {
                                                                     c = '#FFCC33;'
                                                                   } else if (childCount < 100) {
                                                                     c = '#FFCC33;'
                                                                   } else {
                                                                     c = '#FFCC33;'
                                                                   }
                                                                   return new L.DivIcon({ html: '<div style=\"background-color:'+c+'\"><span>' + childCount + '</span></div>', className: 'marker-cluster', iconSize: new L.Point(50, 50) });}"
                         )
                         )
              )
          }

        if(length(which(disc_meta$source == "camel_br")) > 0){

          m = m %>%
              addCircleMarkers(disc_meta$longitude[which(disc_meta$source == "camel_br")],
                               disc_meta$latitude[which(disc_meta$source == "camel_br")],
                               label = disc_meta$name[which(disc_meta$source == "camel_br")],
                               labelOptions = labelOptions(noHide = F, textOnly = F, direction = "top"),
                               stroke = F, group = "CAMELS-BR", fillOpacity = 0.8, fillColor = '#333333',
                               popup = disc_meta$name[which(disc_meta$source == "camel_br")],
                               clusterOptions = markerClusterOptions(iconCreateFunction=JS("function (cluster) {
                                                                   var childCount = cluster.getChildCount();
                                                                   if (childCount < 50) {
                                                                     c = '#333333;'
                                                                   } else if (childCount < 100) {
                                                                     c = '#333333;'
                                                                   } else {
                                                                     c = '#333333;'
                                                                   }
                                                                   return new L.DivIcon({ html: '<div style=\"background-color:'+c+' color: #FFFFFF\"><span>' + childCount + '</span></div>', className: 'marker-cluster', iconSize: new L.Point(50, 50) });}"
                         )
                         )
              )
          }

      m #retrun map

    })

  })

  #Initial conditions: 'Select station on map.'
  f_plot <- function(){

    plot(1:10, 1:10, type = "n", axes = F, ylab = "", xlab = "")
    mtext("Select station on map.", line = -1, cex = 1.5)

  }

  output$hydro_plot <- renderPlot({f_plot()})

  #Dummy which gets selected gauge
  gauge_sel <-  shiny::reactiveValues(clicked_gauge = "XXX")

  #Reaction to selection of station on map
  observeEvent(input$map_marker_click,{

    gauge_sel$clicked_gauge <- input$map_marker_click

    stat_sel <- which(disc_meta$latitude == gauge_sel$clicked_gauge$lat)

    stat_name <- disc_meta$name[stat_sel] #station name
    sta_id <- disc_meta$id[stat_sel] #station id

    if(disc_meta$source[stat_sel] == "grdc"){

      #read discharge time series
      disc_data <- read_grdc(disc_meta$file_path[stat_sel])

      #read watershed boundaries for selected gauge
      catch_path <- grep(sta_id, catch_paths_grdc, value = T)

      if(length(catch_path) !=1){catch_path <- "xxx"}

      if(file.exists(catch_path)){

        catch_sel <- rgdal::readOGR(catch_path)

      }else{

        catch_sel <- sp::Polygon(matrix(rnorm(10, 0, 0.01), ncol =2))

        }
    }

    if(disc_meta$source[stat_sel] == "lamah"){

      #read discharge time series
      disc_data <- read_lamah(disc_meta$file_path[stat_sel])

      #select watershed boundaries for selected gauge
      sel_ind <- which(catch_lamah@data$ID == sta_id)

      crswgs84 <- sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
      catch_sel_lae <- catch_lamah[sel_ind, ]
      catch_sel <- spTransform(catch_sel_lae, crswgs84)

    }

    if(disc_meta$source[stat_sel] == "usgs"){

      #read discharge time series
      disc_data <- read_camels(disc_meta$file_path[stat_sel])

      #select watershed boundaries for selected gauge
      sel_ind <- which(catch_usgs@data$hru_id == sta_id)

      crswgs84 <- sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
      catch_sel_raw <- catch_usgs[sel_ind, ]
      catch_sel <- spTransform(catch_sel_raw, crswgs84)

    }

    if(disc_meta$source[stat_sel] == "camel_br"){

      #read discharge time series
      disc_data <- read_camels_br(disc_meta$file_path[stat_sel])

      # select watershed boundaries for selected gauge
      if(length(which(catch_brazil@data$gauge_id == sta_id)) > 0){

        sel_ind <- which(catch_brazil@data$gauge_id == sta_id)
        crswgs84 <- sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
        catch_sel_raw <- catch_brazil[sel_ind, ]
        catch_sel <- spTransform(catch_sel_raw, crswgs84)

      }else{

        catch_sel <- sp::Polygon(matrix(rnorm(10, 0, 0.01), ncol =2))

      }


    }

    #Update leaflat map and show watershed selected
    leafletProxy("map") %>%
      removeShape(layerId = "watershed") %>%
      addPolygons(data = catch_sel, layerId = "watershed", fill = F,
                  color = "#366488", opacity = 0.9, group = "Watershed") %>%
    addLayersControl(
      baseGroups = c("Terrain Background", "Open Street Map"),
      overlayGroups = c("GRDC", "LamaH", "CAMELS-US", "CAMELS-BR", "Watershed"),
      position = "bottomleft",
      options = layersControlOptions(collapsed = F)
    )

    #Raster graph: Reset parameter at selection of new station
    observe({

      sta_yea_cla <- as.numeric(format(disc_data$date[1], "%Y"))

      end_yea_cla <- as.numeric(format(disc_data$date[nrow(disc_data)], "%Y"))

      rast_time_init <- c(sta_yea_cla, end_yea_cla)

      updateSliderInput(session, "raster_time", label = "Select time frame:",
                        min = sta_yea_cla, max = end_yea_cla, step = 1, value = rast_time_init)
    })

    #Mean graph: Reset parameter at selection of new station
    observe({

      sta_yea_cla <- as.numeric(format(disc_data$date[1], "%Y"))

      end_yea_cla <- as.numeric(format(disc_data$date[nrow(disc_data)], "%Y"))

      rast_time_init <- c(sta_yea_cla, end_yea_cla)

      updateSliderInput(session, "break_year_mh1", label = "Select time frame 1:",
                        min = sta_yea_cla, max = end_yea_cla, step = 1, value = c(1981, 1995))

      updateSliderInput(session, "break_year_mh2", label = "Select time frame 2:",
                        min = sta_yea_cla, max = end_yea_cla, step = 1, value = c(1996, 2010))

    })

    #Percentile graph: Reset parameter at selection of new station
    observe({

      sta_yea_cla <- as.numeric(format(disc_data$date[1], "%Y"))

      end_yea_cla <- as.numeric(format(disc_data$date[nrow(disc_data)], "%Y"))

      rast_time_init <- c(sta_yea_cla, end_yea_cla)

      updateSliderInput(session, "break_year_ph1", label = "Select time frame 1:",
                        min = sta_yea_cla, max = end_yea_cla, step = 1, value = c(1927, 1971))

      updateSliderInput(session, "break_year_ph2", label = "Select time frame 2:",
                        min = sta_yea_cla, max = end_yea_cla, step = 1, value = c(1972, 2016))
    })

    #Annual Max graph: Reset parameter at selection of new station
    observe({

      if(input$break_day_ama == 1){
        sta_yea_ama <- as.numeric(format(disc_data$date[1], "%Y"))
      }else{
        sta_yea_ama <- as.numeric(format(disc_data$date[1], "%Y")) + 1
      }

      end_yea_ama <- as.numeric(format(disc_data$date[nrow(disc_data)], "%Y"))

      if(input$break_day_ama == 1){
        sta_yea_ama <- as.numeric(format(disc_data$date[1], "%Y"))
      }else{
        sta_yea_ama <- as.numeric(format(disc_data$date[1], "%Y")) + 1
      }

      updateSliderInput(session, "years_ama", label = "Select time frame:",
                        min = sta_yea_ama, max = end_yea_ama, step = 1, value = c(sta_yea_ama, end_yea_ama))

    })

    #Volume timing: Reset parameter at selection of new station
    observe({

      sta_yea_cla <- as.numeric(format(disc_data$date[1], "%Y"))

      end_yea_cla <- as.numeric(format(disc_data$date[nrow(disc_data)], "%Y"))

      rast_time_init <- c(sta_yea_cla, end_yea_cla)

      updateSliderInput(session, "vol_frame", label = "Select time frame:",
                        min = sta_yea_cla, max = end_yea_cla, step = 1, value = rast_time_init)
    })

    f_plot <- function(){

      if(input$ana_method == "rasterhydro"){

          sta_yea_cla <- as.numeric(format(disc_data$date[1], "%Y"))

          end_yea_cla <- as.numeric(format(disc_data$date[nrow(disc_data)], "%Y"))

          if(input$break_day_rh == "1.Oct"){my_break_day = 274}
          if(input$break_day_rh == "1.Nov"){my_break_day = 304}
          if(input$break_day_rh == "1.Dec"){my_break_day = 334}
          if(input$break_day_rh == "1.Jan"){my_break_day =   0}

          #Order data by day (including break day to set start hydrologica year)
          data_day <- ord_day(data_in = disc_data$value,
                              date = disc_data$date,
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

        sta_yea_cla <- as.numeric(format(disc_data$date[1], "%Y"))

        end_yea_cla <- as.numeric(format(disc_data$date[nrow(disc_data)], "%Y"))

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
        data_day <- ord_day(data_in = disc_data$value,
                            date = disc_data$date,
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
        data_day <- ord_day(data_in = disc_data$value,
                            date = disc_data$date,
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
              day_cross[p, i] <- min(which(data_cumsum_scale[, i] > percents[p]))
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

        sta_yea_per <- as.numeric(format(disc_data$date[1], "%Y"))

        end_yea_per <- as.numeric(format(disc_data$date[nrow(disc_data)], "%Y"))

        yea_per_1 <- input$break_year_ph1[1]
        yea_per_2 <- input$break_year_ph1[2]
        yea_per_3 <- input$break_year_ph2[1]
        yea_per_4 <- input$break_year_ph2[2]
        perc_sel <- input$percent_ph

        if(input$plo_sel_per == "Line plot"){plot_per <- "line"}
        if(input$plo_sel_per == "Image plot"){plot_per <- "image"}

        #Order data by day (including break day to set start hydrologica year)
        data_day <- ord_day(data_in = disc_data$value,
                            date = disc_data$date,
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

        sta_yea_ama <- as.numeric(format(disc_data$date[1], "%Y"))

        end_yea_ama <- as.numeric(format(disc_data$date[nrow(disc_data)], "%Y"))

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
        data_day <- ord_day(data_in = disc_data$value,
                            date = disc_data$date,
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

        paste0("hydro_explorer.png")

      },
      content = function(file){

        png(file, width = 800, height = 450) #open device

        f_plot()#creat plot

        dev.off() #close device

      }

      )

  })

}
