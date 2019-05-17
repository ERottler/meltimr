#' Buffer mean value
#'
#' Get mean elevation of squared buffer around grid point.
#'
#' @param point_in  Spatial point
#' @param radius  Set length side of square buffer (radius is distance center to side; half total length)
#' @param dem_in DEM
#' @export
elev_buff <- function(point_in, radius = 2500, dem_in){

  y_plu <-point_in@bbox[2,1] + radius
  x_plu <-point_in@bbox[1,1] + radius
  y_min <-point_in@bbox[2,1] - radius
  x_min <-point_in@bbox[1,1] - radius

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
