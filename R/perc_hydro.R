#' Percentile graph
#'
#' Plot option 'Percentile graph' from shiny app melTim.
#'
#' @param data_day Matrix with values ordered by day (see function ord_day()).
#' @param yea_per_1 Start year of time window 1.
#' @param yea_per_2 End year of time window 1.
#' @param yea_per_3 Start year of time window 2.
#' @param yea_per_4 End year of time window 2.
#' @param sta_yea_per Start year of entire time series
#' @param end_yea_per End year of entire time series.
#' @param stat_name Plot title (e.g. station name)
#' @param plot_per Plot type: Line plot showing one selected probability level (see parameter 'perc_sel') or image plot showing difference for all probability levels between the two time windows.
#' @param perc_sel Probablility level displayed (for option 'Line Plot' parameter 'plot_per')
#' @export
perc_hydro <- function(data_day, yea_per_1, yea_per_2, yea_per_3, yea_per_4,
                       end_yea_per, sta_yea_per, stat_name, plot_per, perc_sel){

  ind_break_1 <- (yea_per_1 - sta_yea_per) + 1
  ind_break_2 <- (yea_per_2 - sta_yea_per) + 1
  ind_break_3 <- (yea_per_3 - sta_yea_per) + 1
  ind_break_4 <- (yea_per_4 - sta_yea_per) + 1

  jan_cols <- 1:31
  feb_cols <- 32:59
  mar_cols <- 60:90
  apr_cols <- 91:120
  may_cols <- 121:151
  jun_cols <- 152:181
  jul_cols <- 182:212
  aug_cols <- 213:243
  sep_cols <- 244:273
  oct_cols <- 274:304
  nov_cols <- 305:334
  dec_cols <- 335:365

  month_cols <- list(jan_cols, feb_cols, mar_cols, apr_cols, may_cols, jun_cols, jul_cols, aug_cols, sep_cols, oct_cols, nov_cols, dec_cols)

  if(plot_per == "line"){

    qmon_1 <- rep(NA, 12)
    qmon_2 <- rep(NA, 12)
    for(i in 1:12){
      qmon_1[i] <- quantile(data_day[ind_break_1:ind_break_2, month_cols[[i]]], probs = perc_sel, type = 8, na.rm = T)
      qmon_2[i] <- quantile(data_day[ind_break_3:ind_break_4, month_cols[[i]]], probs = perc_sel, type = 8, na.rm = T)
    }

    plot(qmon_2, type = "n", ylim = range(c(qmon_1, qmon_2), na.rm = T), ylab = "", xlab = "", axes = F)
    lines(qmon_1, type = "l", col = "steelblue4", lwd = 2)
    lines(qmon_2, type = "l", col = "darkred", lwd = 2)
    points(qmon_1, pch = 19, col = "steelblue4", cex = 1.5)
    points(qmon_2, pch = 19, col = "darkred", cex = 1.5)
    mtext(stat_name, side = 3, line = 0.2, cex = 1.7, adj = 0)
    mtext(paste("Prob. =", perc_sel), side = 3, line = 0.2, cex = 1.5, adj = 1)
    abline(v = 1:12, lwd = 0.7, col = "grey55", lty = "dashed")
    grid(nx = 0, ny = 4)
    axis(2, mgp=c(3, 0.25, 0), tck = -0.009, cex.axis = 1.2)
    axis(1, mgp=c(3, 0.25, 0), tck = -0.009, cex.axis = 1.2)
    mtext("Month", side = 1, line = 2, cex = 1.5)
    mtext("Discharge [m³/s]", side = 2, line = 2, cex = 1.5)
    legend("topleft", c(paste0(yea_per_1, "-", yea_per_2), paste0(yea_per_3, "-", yea_per_4)),
           pch = 19, col = c("steelblue4", "darkred"), bg = "white")
    box(lwd = 0.7)


  }

  if(plot_per == "image"){


    f_quants_all <- function(data_in){

      probs <- seq(0.01, 0.99, 0.01)
      quants_all <- quantile(data_in,  probs = probs, type = 8, na.rm = T)

      return(quants_all)

    }

    qmon_1 <- matrix(NA, ncol = 12, nrow = length(seq(0.01, 0.99, 0.01)))
    qmon_2 <-  matrix(NA, ncol = 12, nrow = length(seq(0.01, 0.99, 0.01)))
    for(i in 1:12){
      qmon_1[ , i] <- f_quants_all(data_day[ind_break_1:ind_break_2, month_cols[[i]]])
      qmon_2[ , i] <- f_quants_all(data_day[ind_break_3:ind_break_4, month_cols[[i]]])
    }

    qdif <- qmon_2 - qmon_1

    # my_col <- colorRampPalette(c("white", viridis::viridis(9, direction = 1)[c(3,4)], "cadetblue3", "grey80",
    #                              "yellow2","gold", "orange2", "orangered2"))(200)

    x_axis_lab <- 1:12
    x_axis_tic <- (1:13)-0.5

    n_max <- 100
    n_min <- 100

    cols_min <- colorRampPalette(c("darkred", "firebrick4", "firebrick4", "orangered4", "gold3", "grey98"))(50)
    cols_max <- colorRampPalette(c("grey98", viridis::viridis(9, direction = 1)[c(4,3,2,1,1)]))(50)
    my_col <- colorRampPalette(c(cols_min, cols_max))(200)

    my_bre <- c(seq(-max_na(abs(qdif)), 0, length.out = n_min),
                seq(0, max_na(abs(qdif)), length.out = n_max+1))

    par(mar = c(1.6, 4.5, 2.5, 0.2))

    layout(matrix(c(1,1,1,1,1,1,1,1,2),
                  1, 9), widths=c(), heights=c())

    image(x = 1:12,
          y = seq(0.01, 0.99, 0.01),
          z = t(qdif), col = my_col, breaks = my_bre,
          ylab = "", xlab = "", axes = F)
    axis(1, at = x_axis_tic, c("","","","","","","","","","","","",""), tick = TRUE,
         col = "black", col.axis = "black", tck = -0.02)#plot ticks
    axis(1, at = x_axis_lab, c("J","F","M","A","M","J","J","A","S","O", "N", "D"), tick = FALSE,
         col="black", col.axis="black", mgp=c(3, 0.55, 0), cex.axis = 1.6)#plot labels
    axis(2, mgp=c(3, 0.25, 0), tck = -0.005, cex.axis = 1.5)
    mtext("Probability level", side = 2, line = 2.0, cex = 1.4)
    mtext(stat_name, side = 3, line = 0.5, cex = 1.8, adj = 0.0)
    mtext("[m³/s]", side = 3, line = 0.5, cex = 1.2, adj = 1)
    box()

    par(mar = c(1.6, 0.8, 2.5, 1.6))

    alptempr::image_scale(as.matrix(qdif), col = my_col, breaks = my_bre, horiz=F, ylab="", xlab="", yaxt="n", axes=F)
    axis(4, mgp=c(3, 0.75, 0), tck = -0.08, cex.axis = 1.4)
    # mtext("m³/s", side = 3, line = 0.3, cex = 1)

    box()

  }
}
