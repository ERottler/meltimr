#' Local Polynomial Regression Fitting.
#'
#' Local Polynomial Regression Fitting with NA-restoring.
#'
#' @param data_in Input vector to be smoothed
#' @param smoo_val Smoothing value.
#' @param NA_restore Restore NAs yes or no (T or F)
#' @return Smoothed vector.
#' @export
loess_NA_restore <- function(data_in, smoo_val = 0.2, NA_restore = TRUE){

  #find NAs
  NAs <- which(is.na(data_in))

  #approximate NAs
  data_in_sm <- na.approx(data_in, na.rm=F)

  #smooth wiht loess
  x <- 1:length(data_in_sm)
  smooth_mod <- loess(data_in_sm ~ x, span=smoo_val)

  data_in_sm[which(!is.na(data_in_sm))] <- predict(smooth_mod)

  #restore NAs
  if(NA_restore){data_in_sm[NAs] <- NA}

  return(data_in_sm)
}
