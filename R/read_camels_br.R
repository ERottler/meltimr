#' Read CAMELS-BR data from file.
#'
#' Read in CAMELS-BR observed streamflow (https://zenodo.org/record/3964745).
#'
#' @param file_path  Path data time series data.
#' @export
read_camels_br <- function(file_path){

  data_camels_br <- utils::read.table(file_path, sep = "", header = T, stringsAsFactors = F,
                                      na.strings = c("nan"), dec = ".")

  #define date
  data_camels_date <- as.Date(strptime(paste(data_camels_br$year, data_camels_br$month,
                                             data_camels_br$day), "%Y%m%d", tz="UTC"))
  data_camels_br$date <- data_camels_date

  #fill possible gaps wiht NA
  start_date <- data_camels_date[1]
  end_date   <- data_camels_date[length(data_camels_date)]
  full_date  <- as.Date(seq(start_date, end_date, by="day"))

  data_camels_fill <- data.frame(date  = full_date,
                                 value = with(data_camels_br, streamflow_m3s[match(as.Date(full_date), as.Date(date))])
  )

  return(data_camels_fill)

}
