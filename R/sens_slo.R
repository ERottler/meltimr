#' Sen´s slope
#'
#' Calclation linear trend using Sen´s slope.
#'
#' @param data_in  Vector of input data
#' @param Trend only calculated when percentage of NAs in input vecotr does not exceed cover threshold (0-1)
#' @export
sens_slo <- function(data_in, cover_thresh = 0.9){

  if(length(which(is.na(data_in))) / length(data_in) > (1-cover_thresh)){
    sens_slo <-  NA
  }else{
    time_step <- 1:length(data_in)
    sens_slo <- as.numeric(zyp.sen(data_in~time_step)$coefficients[2])
    #sens_slo <- as.numeric(zyp.trend.vector(data_in, method = "zhang", conf.intervals = F)[2])
  }
  return(sens_slo)
}
