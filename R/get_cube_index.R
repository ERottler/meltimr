#' Cube index from points inside polygon.
#'
#' Get column number of matching point.
#'
#' @param val_in Longitude values
#' @param lons_in Longitude values of data cube points (matrix)
#' @export
get_cube_index_col <- function(val_in, lons_in = lon2D, col_or_row = "col"){

  if(col_or_row == "col"){
    index_out <- which(round(lons_in, digits =6) == round(val_in, digits =6), arr.ind = T)[1,1]
  }

  if(col_or_row == "row"){
    index_out <- which(round(lons_in, digits =6) == round(val_in, digits =6), arr.ind = T)[1,2]
  }

  return(index_out)

}


#' Cube index from points inside polygon.
#'
#' Get row number of matching point.
#'
#' @param val_in Longitude values
#' @param lons_in Longitude values of data cube points (matrix)
#' @export
get_cube_index_row <- function(val_in, lons_in = lon2D, col_or_row = "row"){
  if(col_or_row == "col"){
    index_out <- which(round(lons_in, digits =6) == round(val_in, digits =6), arr.ind = T)[1,1]
  }

  if(col_or_row == "row"){
    index_out <- which(round(lons_in, digits =6) == round(val_in, digits =6), arr.ind = T)[1,2]
  }

  return(index_out)
}
