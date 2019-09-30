#' Grid around spatial point.
#'
#' Add points as 1 km grid around spatial point. One point turn into a spatial grind with 1 km  resolution. In total 25 spatial points returned.
#'
#' @param lon_lat_point_in  Lat-Lon input
#' @export
down_points <- function(lon_lat_point_in){

  res_new <- 1000 # new desirted resolution in [m]

  d_00 <- lon_lat_point_in
  d_01 <- d_00 + res_new * 1
  d_02 <- d_00 + res_new * 2
  d_03 <- d_00 - res_new * 1
  d_04 <- d_00 - res_new * 2
  d_05 <- d_00
  d_05[1] <- d_05[1] + res_new * 1
  d_05[2] <- d_05[2] - res_new * 1
  d_06 <- d_00
  d_06[1] <- d_06[1] + res_new * 2
  d_06[2] <- d_06[2] - res_new * 2
  d_07 <- d_00
  d_07[1] <- d_07[1] - res_new * 1
  d_07[2] <- d_07[2] + res_new * 1
  d_08 <- d_00
  d_08[1] <- d_08[1] - res_new * 2
  d_08[2] <- d_08[2] + res_new * 2
  d_09 <- d_00
  d_09[1] <- d_09[1] + res_new * 1
  d_09[2] <- d_07[2] + res_new * 0
  d_10 <- d_00
  d_10[1] <- d_10[1] + res_new * 2
  d_10[2] <- d_10[2] + res_new * 0
  d_11 <- d_00
  d_11[1] <- d_11[1] - res_new * 1
  d_11[2] <- d_11[2] + res_new * 0
  d_12 <- d_00
  d_12[1] <- d_12[1] - res_new * 2
  d_12[2] <- d_12[2] + res_new * 0
  d_13 <- d_00
  d_13[1] <- d_13[1] + res_new * 0
  d_13[2] <- d_13[2] - res_new * 1
  d_14 <- d_00
  d_14[1] <- d_14[1] + res_new * 0
  d_14[2] <- d_14[2] - res_new * 2
  d_15 <- d_00
  d_15[1] <- d_15[1] + res_new * 0
  d_15[2] <- d_15[2] + res_new * 1
  d_16 <- d_00
  d_16[1] <- d_16[1] + res_new * 0
  d_16[2] <- d_16[2] + res_new * 2
  d_17 <- d_00
  d_17[1] <- d_17[1] + res_new * 2
  d_17[2] <- d_17[2] + res_new * 1
  d_18 <- d_00
  d_18[1] <- d_18[1] + res_new * 2
  d_18[2] <- d_18[2] - res_new * 1
  d_19 <- d_00
  d_19[1] <- d_19[1] + res_new * 1
  d_19[2] <- d_19[2] - res_new * 2
  d_20 <- d_00
  d_20[1] <- d_20[1] - res_new * 1
  d_20[2] <- d_20[2] - res_new * 2
  d_21 <- d_00
  d_21[1] <- d_21[1] - res_new * 2
  d_21[2] <- d_21[2] - res_new * 1
  d_22 <- d_00
  d_22[1] <- d_22[1] - res_new * 2
  d_22[2] <- d_22[2] + res_new * 1
  d_23 <- d_00
  d_23[1] <- d_23[1] - res_new * 1
  d_23[2] <- d_23[2] + res_new * 2
  d_24 <- d_00
  d_24[1] <- d_24[1] + res_new * 1
  d_24[2] <- d_24[2] + res_new * 2

  d_points_raw <- rbind(d_00, d_01, d_02, d_03, d_04, d_05, d_06, d_07, d_08, d_09, d_10, d_11, d_12,
                        d_13, d_14, d_15, d_16, d_17, d_18, d_19, d_20, d_21, d_22, d_23, d_24)


  #spatial grip points from lat/lon info
  d_points <- sp::SpatialPoints(data.frame(lon = d_points_raw[, 1], lat = d_points_raw[, 2]), proj4string =  sp::CRS("+proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000
                    +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"))

  return(d_points)

}
