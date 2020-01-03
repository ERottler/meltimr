#' Check for NA
#'
#' Check vector if NAs. Only use arrays with no NAs. If one NA all put to NA.
#'
#' @param file_path  Path data table.
#' @export
na_check <- function(data_in){

  if(length(which(is.na(data_in))) > 0){
    data_in <- rep(NA, length(data_in))
  }

  return(data_in)

}
