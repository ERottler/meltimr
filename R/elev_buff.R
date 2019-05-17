#' Buffer mean value
#'
#' Get mean elevation of squared buffer around grid point.
#'
#' @param points_in  Spatial points
#' @param radius  Length side of square buffer
#' @param point_index Index which point of Spatial points (points_in) used
#' @param dem_in DEM
#' @export
elev_buff <- function(point_index, radius = 2500, points_in = grid_points, dem_in = dem){

  y_plu <-points_in[point_index]@bbox[2,1] + radius
  x_plu <-points_in[point_index]@bbox[1,1] + radius
  y_min <-points_in[point_index]@bbox[2,1] - radius
  x_min <-points_in[point_index]@bbox[1,1] - radius

  square <- cbind(x_min, y_plu, #NW corner
                  x_plu, y_plu, #NE corner
                  x_plu, y_min, #SW corner
                  x_min, y_min, #SW corner
                  x_min, y_plu) #NW corner again to close polygon

  pol_sq <- Polygon(matrix(square, ncol = 2, byrow = T))
  sq_buf <- SpatialPolygons(list(Polygons(list(pol_sq), ID = "sq_buf")), proj4string = CRS(crs(basin, asText = T)))


  #get mean elevation in squared buffer...

  elev_square <- raster::extract(dem, sq_buf, fun = mean, na.rm = T)

  return(elev_square)

}
