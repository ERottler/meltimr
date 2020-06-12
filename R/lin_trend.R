#' Linear trend data
#'
#' Calculate linear trend using function glm for fitting generalized linear models.
#'
#' @param data_in  Numeric data vector.
#' @param index_in Index 1 to length of data vector.
#' @export
lin_trend <- function(data_in, index_in){

  stats::glm(data_in ~ index_in)$coefficients[2]

  }
