#' Volume timing graph
#'
#' Plot option 'Volume timing' from shiny app melTim.
#'
#' @param day_cross Matrix with DOYs when certain fraction of annual runoff was recorded (currently 25, 50 and 75 \%).
#' @param break_day Define start year (e.g. 274 is 1.October is start hydrological year in Switzerland).
#' @param sta_yea_cla Start year of time series investigated.
#' @param end_yea_cla Endyear of time series investigated.
#' @param stat_name Plot title (e.g. station name)
#' @param day_cross_slo Trend in DOYs for fractions 25/50/75 \% of annual runoff in days/dec
#' @param day_cross_mea Mean DOY for fractions 25/50/75 \% of annual runoff.
#' @param day_cross_day Trend in DOYs for fractions 25/50/75 \% of annual runoff for the entire time frame.
#' @export
volu_time <- function(day_cross, sta_yea_cla, end_yea_cla, break_day, day_cross_slo, day_cross_mea, day_cross_day, stat_name){

  smo_val <- 0.25

  if(break_day > 0){end_yea_cla <- end_yea_cla-1}# if not 1.Jan one year cut

  cols_min <- grDevices::colorRampPalette(c(viridis::viridis(9, direction = 1)[1:4], "cadetblue3", "white"))(100)
  cols_max <- grDevices::colorRampPalette(c("white", "yellow2","gold2", "orange2", "orangered3", "orangered4", "red4"))(100)
  cols_hydro <- c(cols_min, cols_max)

  col_1 <- "darkred"
  col_2 <- "black"
  col_3 <- "steelblue4"

  graphics::par(mar = c(3.0, 3.0, 6, 0.1))

  graphics::plot(sta_yea_cla:end_yea_cla, day_cross[3, ], type = "n", ylim = c(min_na(day_cross[1, ]), max_na(day_cross[3, ])),
                 axes = F, ylab = "", xlab = "")
  graphics::lines(sta_yea_cla:end_yea_cla, day_cross[3, ], col = col_3, lwd = 1.5)
  graphics::lines(sta_yea_cla:end_yea_cla, day_cross[2, ], col = col_2, lwd = 1.5)
  graphics::lines(sta_yea_cla:end_yea_cla, day_cross[1, ], col = col_1, lwd = 1.5)
  graphics::lines(sta_yea_cla:end_yea_cla, loess_NA_restore(day_cross[3, ], smoo_val = smo_val), col = col_3, lty = "dashed")
  graphics::lines(sta_yea_cla:end_yea_cla, loess_NA_restore(day_cross[2, ], smoo_val = smo_val), col = col_2, lty = "dashed")
  graphics::lines(sta_yea_cla:end_yea_cla, loess_NA_restore(day_cross[1, ], smoo_val = smo_val), col = col_1, lty = "dashed")
  graphics::axis(2, mgp=c(3, 0.25, 0), tck = -0.01, cex.axis = 1.1)
  graphics::axis(1, mgp=c(3, 0.25, 0), tck = -0.01, cex.axis = 1.1)
  graphics::abline(v = seq(1800, 2020, 10), lty = "dashed", lwd = 0.8, col = "grey55")
  graphics::grid(nx= 0, ny = 5, col = "grey55", lty = "dashed", lwd = 0.8)
  graphics::box(lwd = 0.8)
  graphics::mtext(paste0(stat_name, " (", sta_yea_cla, "-", end_yea_cla, ")"), line = 4.0, side = 3, cex = 1.5)
  graphics::mtext("Day of the year (DOY)", line = 2.0, side = 2, cex = 1.2)
  graphics::mtext("Year", line = 2.0, side = 1, cex = 1.2)
  cex_dat <- 0.9
  decs <- length(sta_yea_cla:end_yea_cla)/10

  graphics::mtext("Volume:", side = 3, line = 3.0, adj = 0.00, col = "black", cex = cex_dat, padj = 0)
  graphics::mtext("Mean day:", side = 3, line = 2.0, adj = 0.00, col = "black", cex = cex_dat, padj = 0)
  graphics::mtext("Linear trend days earlier:", side = 3, line = 1.0, adj = 0.00, col = "black", cex = cex_dat, padj = 0)
  graphics::mtext("Days earlier total:", side = 3, line = 0.1, adj = 0.00, col = "black", cex = cex_dat, padj = 0)

  graphics::mtext("25 %", side = 3, line = 3.0, adj = 0.35, col = col_1, cex = cex_dat, padj = 0)
  graphics::mtext("50 %", side = 3, line = 3.0, adj = 0.65, col = col_2, cex = cex_dat, padj = 0)
  graphics::mtext("75 %", side = 3, line = 3.0, adj = 1.00, col = col_3, cex = cex_dat, padj = 0)

  graphics::mtext(paste0(round(day_cross_slo[1], 2), " days/dec"), side = 3, line = 1.0, adj = 0.35, col = col_1, cex = cex_dat, padj = 0)
  graphics::mtext(paste0(round(day_cross_slo[2], 2), " days/dec"), side = 3, line = 1.0, adj = 0.65, col = col_2, cex = cex_dat, padj = 0)
  graphics::mtext(paste0(round(day_cross_slo[3], 2), " days/dec"), side = 3, line = 1.0, adj = 1.00, col = col_3, cex = cex_dat, padj = 0)
  graphics::mtext(paste0(round(day_cross_mea[1], 2), " DOY"), side = 3, line = 2.0, adj = 0.35, col = col_1, cex = cex_dat, padj = 0)
  graphics::mtext(paste0(round(day_cross_mea[2], 2), " DOY"), side = 3, line = 2.0, adj = 0.65, col = col_2, cex = cex_dat, padj = 0)
  graphics::mtext(paste0(round(day_cross_mea[3], 2), " DOY"), side = 3, line = 2.0, adj = 1.00, col = col_3, cex = cex_dat, padj = 0)
  graphics::mtext(paste0(round(day_cross_slo[1]* decs, 2), " days"), side = 3, line = 0.1, adj = 0.35, col = col_1, cex = cex_dat, padj = 0)
  graphics::mtext(paste0(round(day_cross_slo[2]* decs, 2), " days"), side = 3, line = 0.1, adj = 0.65, col = col_2, cex = cex_dat, padj = 0)
  graphics::mtext(paste0(round(day_cross_slo[3]* decs, 2), " days"), side = 3, line = 0.1, adj = 1.00, col = col_3, cex = cex_dat, padj = 0)

}
