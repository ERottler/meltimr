#' Linear trend data
#'
#' Calculate linear trend using function glm for fitting generalized linear models.
#'
#' @param file_path  Path data table.
#' @export
lin_trend <- function(data_in, index_in){

  glm(data_in ~ index_in)$coefficients[2]

  }
