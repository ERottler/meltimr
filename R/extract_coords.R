#' Extract coordinates from Polygon
#'
#' Extract coordinates from SpatialPolyognsDataFrame
#'
#' @param sp_df SpatialPolyognsDataFrame
#' @export
extract_coords <- function(sp_df){

  results <- list()

  for(i in 1:length(sp_df@polygons[[1]]@Polygons)){
    results[[i]] <- sp_df@polygons[[1]]@Polygons[[i]]@coords
  }

  results <- Reduce(rbind, results)

  return(results)

}
