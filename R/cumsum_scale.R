#' Scale array
#'
#' Scale array by dividing by last element.
#'
#' @param data_in  Numeric vector.
#' @export
cumsum_scale <- function(data_in){

  if(length(which(is.na(data_in))) > 0){
    data_out <- rep(NA, length(data_in))
  }else{
    data_out <- data_in / data_in[length(data_in)]
  }

  return(data_out)

}
