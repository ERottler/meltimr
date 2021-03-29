#' Read CAMELS-GB data from file.
#'
#' Read in CAMELS-GB observed streamflow (https://doi.org/10.5285/8344e4f3-d2ea-44f5-8afa-86d2987543a9).
#'
#' @param file_path  Path data time series data.
#' @export
read_camels_gb <- function(file_path){

  data_camels_gb <- utils::read.table(file_path, sep = ",", header = T, stringsAsFactors = F,
                                      na.strings = c("NaN"), dec = ".")

  #define date
  data_camels_date <- as.Date(strptime(data_camels_gb$date, "%Y-%m-%d", tz="UTC"))
  data_camels_gb$date <- data_camels_date

  #fill possible gaps wiht NA
  start_date <- data_camels_date[1]
  end_date   <- data_camels_date[length(data_camels_date)]
  full_date  <- as.Date(seq(start_date, end_date, by="day"))

  data_camels_fill <- data.frame(date  = full_date,
                                 value = with(data_camels_gb, discharge_vol[match(as.Date(full_date), as.Date(date))])
  )

  return(data_camels_fill)

}
