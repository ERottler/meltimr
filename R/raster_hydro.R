#' Raster graph
#'
#' Plot option 'Raster graph' from shiny app melTim.
#'
#' @param data_day Matrix with values ordered by day (see function ord_day()).
#' @param break_day Define start year (e.g. 274 is 1.October is start hydrological year in Switzerland).
#' @param sta_yea_cla Start year of time series visualized.
#' @param end_yea_cla End year of time series visualized.
#' @param stat_name Plot title (e.g. station name)
#' @export
raster_hydro <- function(data_day, break_day, sta_yea_cla, end_yea_cla, stat_name){

  x_axis_lab <- c(16,46,74,105,135,166,196,227,258,288,319,349)
  x_axis_tic <- c(16,46,74,105,135,166,196,227,258,288,319,349,380)-15

  lab_unit <- "[m³/s]"

  cols_hydro <- colorRampPalette(c(viridis::viridis(20, direction = -1)))(200)

  max_break <- max_na(data_day)
  min_break <- min_na(data_day)
  qua_break <- quantile(data_day, probs = 0.70, type = 8, na.rm = T)

  breaks_1 <- seq(min_break, qua_break, length.out = length(cols_hydro)/2)
  breaks_2 <- exp(seq(qua_break+0.01, max_break, length.out = length(cols_hydro)/2 + 1))
  breaks_2[length(breaks_2)] <- breaks_2[length(breaks_2)] + 0.1


  breaks_hydro <- c(breaks_1, breaks_2)

  par(mar = c(1.6, 3.5, 2.5, 0.2))

  layout(matrix(c(1,1,1,1,1,1,1, 1,2),
                1, 9), widths=c(), heights=c())

  image(x = 1:ncol(data_day),
        y = sta_yea_cla:end_yea_cla,
        z = t(data_day),
        col = cols_hydro,
        breaks = breaks_hydro,
        ylab = "", xlab = "", axes = F)

  axis(1, at = x_axis_tic, c("","","","","","","","","","","","",""), tick = TRUE,
       col = "black", col.axis = "black", tck = -0.02)#plot ticks
  if(break_day == 274){
    axis(1, at = x_axis_lab, c("O","N","D","J","F","M","A","M","J","J","A","S"), tick = FALSE,
         col="black", col.axis="black", mgp=c(3, 0.55, 0), cex.axis = 1.6)#plot labels
  }
  if(break_day == 304){
    axis(1, at = x_axis_lab, c("N","D","J","F","M","A","M","J","J","A","S","O"), tick = FALSE,
         col="black", col.axis="black", mgp=c(3, 0.55, 0), cex.axis = 1.6)#plot labels
  }
  if(break_day == 334){
    axis(1, at = x_axis_lab, c("D","J","F","M","A","M","J","J","A","S","O","N"), tick = FALSE,
         col="black", col.axis="black", mgp=c(3, 0.55, 0), cex.axis = 1.6)#plot labels
  }
  if(break_day == 0){
    axis(1, at = x_axis_lab, c("J","F","M","A","M","J","J","A","S","O", "N", "D"), tick = FALSE,
         col="black", col.axis="black", mgp=c(3, 0.55, 0), cex.axis = 1.6)#plot labels
  }

  mtext("Year", side = 2, line = 2.0, cex = 1.2)
  axis(2, mgp=c(3, 0.25, 0), tck = -0.005, cex.axis = 1.5)
  mtext(paste0(stat_name, " (", sta_yea_cla, "-", end_yea_cla, ")"), side = 3, line = 0.5, cex = 1.5, adj = 0)
  mtext(lab_unit, side = 3, line = 0.5, cex = 1, adj = 1)
  box()

  par(mar = c(1.6, 0.8, 2.5, 1.6))

  alptempr::image_scale(as.matrix(data_day), col = cols_hydro, breaks = breaks_hydro, horiz=F, ylab="", xlab="", yaxt="n", axes=F)
  axis(4, mgp=c(3, 0.75, 0), tck = -0.08, cex.axis = 1.4)
  box()

}
