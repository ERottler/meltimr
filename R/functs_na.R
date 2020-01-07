



#' Arithmetic mean with NA values.
#'
#' Function for arithmetic mean automatically handling NAs. Calculates arithmetic mean value
#' disregarding NAs, except when all values are NA.
#'
#' @param x see arguments in R documentation for \link{mean}.
#' @return The arithmetic mean of values in \code{x}.
#' @examples
#' mea_na(c(2 ,3, NA))
#' mea_na(c(NA, NA, NA))
#' @export
mea_na <- function(x){
  ifelse (all(is.na(x)), NA, mean(x, na.rm = TRUE))
}




#' Minimum with NA values.
#'
#' Function to determine minimum value automatically handling NAs. Calculates
#' minimum value disregarding NAs, except when all values are NA.
#'
#' @param x numeric or character arguments; see also R documentation for \link{min}.
#' @return The minimum value in \code{x}.
#' @examples
#' min_na(c(2 ,3, NA))
#' min_na(c(NA, NA, NA))
#' @export
min_na <- function(x){
  ifelse (all(is.na(x)), NA, min(x, na.rm = TRUE))
}




#' Maximum with NA values.
#'
#' Function to determine maximum value automatically handling NAs. Calculates
#' maximum value disregarding NAs, except when all values are NA.
#'
#' @param x numeric or character arguments; see also R documentation for \link{min}.
#' @return The minimum value in \code{x}.
#' @examples
#' max_na(c(2 ,3, NA))
#' max_na(c(NA, NA, NA))
#' @export
max_na <- function(x){
  ifelse (all(is.na(x)), NA, max(x, na.rm = TRUE))
}




#' Median with NA values.
#'
#' Function to determine median value automatically handling NAs. Calculates
#' median value disregarding NAs, except when all values are NA.
#'
#' @param x see R documentation for \link{median}.
#' @return The median values in \code{x}.
#' @examples
#' med_na(c(2 ,3, NA))
#' med_na(c(NA, NA, NA))
#' @export
med_na <- function(x){
  ifelse (all(is.na(x)), NA, median(x, na.rm = TRUE))
}




#' Sum with NA values.
#'
#' Function to determine sum automatically handling NAs. Calculates
#' sum disregarding NAs, except when all values are NA.
#'
#' @param x numeric or complex or logical vectors; see R documentation for \link{sum}.
#' @return The sum of \code{x}.
#' @examples
#' sum_na(c(2 ,3, NA))
#' sum_na(c(NA, NA, NA))
#' @export
sum_na <- function(x){
  ifelse (all(is.na(x)), NA, sum(x, na.rm = TRUE))
}




#' Arithmetic mean with percentage threshold for NA values.
#'
#' Function for arithmetic mean automatically handling NAs. Calculates arithmetic mean value
#' only when percentage of NAs is below given threshold.
#'
#' @param x see arguments in R documentation for \link{mean}.
#' @param na_thres threshold value for percentage NAs in x; between 0 and 1
#' @return The arithmetic mean of values in \code{x}.
#' @examples
#' mea_na_thres(c(2 ,3, 4, NA), na_thres=0.5)
#' mea_na_thres(c(2 ,3, 4, NA), na_thres=0.1)
#' @export
mea_na_thres <- function(x, na_thres=0.5){
  na_percentage <- length(which(is.na(x))) / length(x)
  if(na_percentage > na_thres){
    mea_out <- NA}else{
      mea_out <- ifelse (all(is.na(x)), NA, mean(x, na.rm = TRUE))
    }
  return(mea_out)
}













