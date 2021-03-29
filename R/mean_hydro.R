#' Mean graph
#'
#' Plot option 'Mean graph' from shiny app 'Hydro Explorer'.
#'
#' @param data_day Matrix with values ordered by day (see function \code{\link{ord_day}}).
#' @param break_day Define start day (e.g. 274 is 1.October, is start of the hydrological year in Switzerland).
#' @param yea_cla_1 Start year of time window 1.
#' @param yea_cla_2 End year of time window 1.
#' @param yea_cla_3 Start year of time window 2.
#' @param yea_cla_4 End year of time window 2.
#' @param sta_yea_cla Start year of entire time series
#' @param end_yea_cla End year of entire time series.
#' @param stat_name Plot title (e.g. station name)
#' @export
mean_hydro <- function(data_day, break_day, yea_cla_1, yea_cla_2, yea_cla_3, yea_cla_4,
                       end_yea_cla, sta_yea_cla, stat_name){

  #minimum of two years each selected time window to do calculations
  if(length(yea_cla_1:yea_cla_2) > 2 && length(yea_cla_3:yea_cla_4) > 2){

    #Mean seasonal cycles
    ind_break_1 <- (yea_cla_1 - sta_yea_cla) + 1
    ind_break_2 <- (yea_cla_2 - sta_yea_cla) + 0
    ind_break_3 <- (yea_cla_3 - sta_yea_cla) + 1
    ind_break_4 <- (yea_cla_4 - sta_yea_cla) + 0

    if(break_day == 0){#when break not 1.Jan one year less available to analyse
      ind_break_1 <- (yea_cla_1 - sta_yea_cla) + 1
      ind_break_2 <- (yea_cla_2 - sta_yea_cla) + 1
      ind_break_3 <- (yea_cla_3 - sta_yea_cla) + 1
      ind_break_4 <- (yea_cla_4 - sta_yea_cla) + 1
    }

    data_mea   <- apply(data_day[, ], 2, mea_na)
    data_mea_1 <- apply(data_day[c(ind_break_1:ind_break_2), ], 2, mea_na)
    data_mea_2 <- apply(data_day[c(ind_break_3:ind_break_4), ], 2, mea_na)

    diff_mea   <- diff(data_mea)
    diff_mea_1 <- diff(data_mea_1)
    diff_mea_2 <- diff(data_mea_2)

    sub_diff_mea <- diff_mea_1 - diff_mea_2

    #vertical ablines at maximum
    doy_max_1 <- which(data_mea_1 == max_na(data_mea_1))
    doy_max_2 <- which(data_mea_2 == max_na(data_mea_2))

    #Plot: Mean graph

    x_axis_lab <- c(16,46,74,105,135,166,196,227,258,288,319,349)
    x_axis_tic <- c(16,46,74,105,135,166,196,227,258,288,319,349,380)-15

    y_max <- max(c(data_mea, data_mea_1, data_mea_2))
    y_min <- min(c(data_mea, data_mea_1, data_mea_2))

    graphics::plot(data_mea_1, type = "n", col ="blue3",
                   axes = F, ylab = "", xlab = "", ylim = c(y_min, y_max))
    graphics::lines(data_mea_1, col = "steelblue4", lwd = 2.5)
    graphics::lines(data_mea_2, col = "darkred", lwd = 2.5)
    graphics::abline(v = doy_max_1, col = "steelblue4", lty = "dashed", lwd = 2)
    graphics::abline(v = doy_max_2, col = "darkred",  lty = "dashed", lwd = 2)
    graphics::mtext(paste0("Peak lag: ", (doy_max_1-doy_max_2), " days"), side = 3, line = 0.2, adj = 1, cex = 1.2)

    graphics::mtext(expression(paste("Discharge [m"^"3", " s"^"-1", "]")), side = 2, line = 2.0, cex = 1.2)
    legend_posi <- "topleft"

    graphics::axis(2, mgp=c(3, 0.25, 0), tck = -0.009, cex.axis = 1.2)
    graphics::axis(1, at = x_axis_tic, c("","","","","","","","","","","","",""), tick = TRUE,
                   col = "black", col.axis = "black", tck = -0.06)#plot ticks
    if(break_day == 274){
      graphics::axis(1, at = x_axis_lab, c("O","N","D","J","F","M","A","M","J","J","A","S"), tick = FALSE,
                     col="black", col.axis="black", mgp=c(3, 0.15, 0))#plot labels
    }
    if(break_day == 304){
      graphics::axis(1, at = x_axis_lab, c("N","D","J","F","M","A","M","J","J","A","S","O"), tick = FALSE,
                     col="black", col.axis="black", mgp=c(3, 0.15, 0))#plot labels
    }
    if(break_day == 334){
      graphics::axis(1, at = x_axis_lab, c("D","J","F","M","A","M","J","J","A","S", "O","N"), tick = FALSE,
                     col="black", col.axis="black", mgp=c(3, 0.15, 0))#plot labels
    }
    if(break_day == 0){
      graphics::axis(1, at = x_axis_lab, c("J","F","M","A","M","J","J","A","S","O", "N", "D"), tick = FALSE,
                     col="black", col.axis="black", mgp=c(3, 0.15, 0))#plot labels
    }
    # graphics::mtext(paste0(stat_name, " (", sta_yea_cla, "-", end_yea_cla, ")"), line = 0.2, side = 3, cex = 1.5, adj = 0)
    graphics::mtext(paste0(stat_name), line = 0.2, side = 3, cex = 1.5, adj = 0)
    graphics::abline(v = x_axis_tic, col = "grey55", lty = "dashed", lwd = 0.8)
    graphics::grid(nx = 0, ny = 5, lty = "dashed", col = "grey55", lwd = 0.8)
    graphics::legend(legend_posi, c(paste0(yea_cla_1, "-", yea_cla_2), paste0(yea_cla_3, "-", yea_cla_4)),
                     pch = 19, col = c("steelblue4", "darkred"),
                     bg = "white")
    graphics::box(lwd = 0.7)

  }else{

    plot(1:10, 1:10, type = "n", axes = F, ylab = "", xlab = "")
    mtext("Time series too short to analyse.", line = -1, cex = 1.5)
    mtext("Please select a different time window or station.", line = -3, cex = 1.5)

    }

}
