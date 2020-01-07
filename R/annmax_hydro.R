#' Annual/Montly maxima graph
#'
#' Plot option 'Annual Max' from shiny app melTim.
#'
#' @param data_day Matrix with values ordered by day (see function ord_day()).
#' @param break_day Define start year (e.g. 274 is 1.October is start hydrological year in Switzerland).
#' @param ama_var Select plot type: 1) Day of the year of annual maxima (timing), 2) Magnitudes of annual maxima or 3) Montly maxima.
#' @param yea_ama_1 Start year selected time window.
#' @param yea_ama_2 End year selected time window.
#' @param sta_yea_cla Start year of entire time series
#' @param end_yea_cla End year of entire time series.
#' @param month_sel_1 Start month to use for calculating maxima.
#' @param month_sel_2 End month to use for calculating maxima.
#' @param stat_name Plot title (e.g. station name)
#' @export
annmax_plot <- function(data_day, break_day, yea_ama_1, yea_ama_2, end_yea_ama, sta_yea_ama,
                        month_sel_1, month_sel_2, stat_name, ama_var){
  if(break_day > 0){
    sta_yea_ama <- sta_yea_ama + 1#sta_yea_ama from original input data, when break no 1 Jan, first year lost
  }

  ind_break_1 <- (yea_ama_1 - sta_yea_ama) + 1
  ind_break_2 <- (yea_ama_2 - sta_yea_ama) + 1

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

  if(ama_var == "ama_mon"){

    f_mon_max <- function(data_in){

      dat_max <- max_na(data_in)

      return(dat_max)

    }
    mon_max_slo <- rep(NA, 12)

    for(i in 1:12){

      mon_max <- apply(data_day[ind_break_1:ind_break_2, month_cols[[i]]], 1, f_mon_max)
      mon_max_slo[i] <- sens_slo(mon_max) * 10

    }


    plot(mon_max_slo, type = "l", lwd = 2, axes = F, ylab = "", xlab = "")
    points(mon_max_slo, pch = 19, cex = 2)
    axis(2, mgp=c(3, 0.25, 0), tck = -0.01, cex.axis = 1.1)
    axis(1, mgp=c(3, 0.25, 0), tck = -0.01, cex.axis = 1.1)

    abline (h = 0, lwd = 1, col = "grey55", lty = 2)
    mtext("Trend discharge [(m³/s)/dec]", line = 2.0, side = 2, cex = 1.2)
    mtext("Month", line = 2.0, side = 1, cex = 1.2)
    mtext(paste0(stat_name, " (", yea_ama_1, "-", yea_ama_2, ")"), line = 0.5, side = 3, cex = 1.5, adj = 0)
    box(lwd = 0.8)

  }else{

    months_sel <- month_sel_1:month_sel_2

    for(i in 1:length(months_sel)){

      if(i == 1){
        cols_sel <- month_cols[[months_sel[i]]]
      }else{
        cols_sel <- c(cols_sel, month_cols[[months_sel[i]]])
      }

    }

    if(ama_var == "ama_doy"){

      f_ama <- function(data_in){

        ind_max <- min_na(which(data_in == max_na(data_in)))

        return(ind_max)

      }

    }
    if(ama_var == "ama_mag"){

      f_ama <- function(data_in){

        dat_max <- max_na(data_in)

        return(dat_max)

      }

    }

    ama_res <- apply(data_day[ind_break_1:ind_break_2, cols_sel], 1, f_ama)

    #Slope DOY annual maxima
    decs <- length(yea_ama_1:yea_ama_2)/10

    ama_res_slo <- sens_slo(ama_res) * 10 * -1 # [day/dec]

    smo_val <- 0.25
    days <- seq(as.Date("2014-01-01"), to = as.Date("2014-12-31"), by = "days")

    par(mar = c(3.0, 3.0, 6, 0.1))

    plot(yea_ama_1:yea_ama_2, ama_res, type = "n", axes = F, ylab = "", xlab = "")
    lines(yea_ama_1:yea_ama_2, ama_res, col = "black", lwd = 2)
    points(yea_ama_1:yea_ama_2, ama_res, col = "black", pch = 19, cex = 0.6)
    lines(yea_ama_1:yea_ama_2, loess_NA_restore(ama_res, smoo_val = smo_val), col = "black")

    axis(2, mgp=c(3, 0.25, 0), tck = -0.01, cex.axis = 1.1)
    axis(1, mgp=c(3, 0.25, 0), tck = -0.01, cex.axis = 1.1)
    abline(v = seq(1800, 2020, 10), lty = "dashed", lwd = 0.8, col = "grey55")
    grid(nx= 0, ny = 5, col = "grey55", lty = "dashed", lwd = 0.8)
    box(lwd = 0.8)
    mtext(paste0(stat_name, " (", sta_yea_ama, "-", end_yea_ama, ")"), line = 3.0, side = 3, cex = 1.5)

    if(ama_var == "ama_doy"){
      mtext("Day of the year (DOY)", line = 2.0, side = 2, cex = 1.2)
      mtext("Year", line = 2.0, side = 1, cex = 1.2)
      mtext(paste0(" Day Zero: ", format(days[break_day + cols_sel[1]], "%d-%m")), side = 3, line = 1.5, adj = 0, cex = 1.2)
      mtext(paste0(" Months: ", month_sel_1, " to ", month_sel_2), side = 3, line = 0.2, adj = 0.0, cex = 1.2)
      mtext(paste0(" Sen's slope: ", round(ama_res_slo, 2),  " days/dec"), side = 3, line = 1.5, adj = 1.0, cex = 1.2)
      mtext(paste0(" Days earlier: ", round(ama_res_slo * decs, 2),  " days"), side = 3, line = 0.2, adj = 1.0, cex = 1.2)
    }

    if(ama_var == "ama_mag"){
      mtext("Discharge [m³/s]", line = 2.0, side = 2, cex = 1.2)
      mtext("Year", line = 2.0, side = 1, cex = 1.2)
      mtext(paste0(" Day Zero: ", format(days[break_day + cols_sel[1]], "%d-%m")), side = 3, line = 1.5, adj = 0, cex = 1.2)
      mtext(paste0(" Months: ", month_sel_1, " to ", month_sel_2), side = 3, line = 0.2, adj = 0.0, cex = 1.2)
      mtext(paste0(" Sen's slope: ", round(ama_res_slo * -1, 2),  " (m³/s)/dec"), side = 3, line = 1.5, adj = 1.0, cex = 1.2)
      mtext(paste0(" Change total: ", round(ama_res_slo * -1 * decs, 2),  " m³/s"), side = 3, line = 0.2, adj = 1.0, cex = 1.2)
    }

  }


}