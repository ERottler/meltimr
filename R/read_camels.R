#' Read CAMELS data from file.
#'
#' Read in CAMELS observed streamflow from USGS (https://ncar.github.io/hydrology/datasets/CAMELS_timeseries).
#'
#' @param file_path  Path data time series data.
#' @export
read_camels <- function(file_path){

  data_camels <- utils::read.table(file_path, sep = "", header = F, stringsAsFactors = F,
                                   na.strings = c(-999), dec = ".")

  #define date
  data_camels_date <- as.Date(strptime(paste(data_camels[, 2], data_camels[, 3], data_camels[, 4]), "%Y%m%d", tz="UTC"))
  data_camels$date <- data_camels_date

  #fill possible gaps wiht NA
  start_date <- data_camels_date[1]
  end_date   <- data_camels_date[length(data_camels_date)]
  full_date  <- as.Date(seq(start_date, end_date, by="day"))

  data_camels_fill <- data.frame(date  = full_date,
                                 value = with(data_camels, V5[match(as.Date(full_date), as.Date(date))])
  )

  #cubic feet to cubic meter
  data_camels_fill$value <- (data_camels_fill$value / 35.315)

  #in case na strings not recognized
  na_vals <- which(data_camels_fill$value == -999)
  data_camels_fill$value[na_vals] <- NA

  return(data_camels_fill)

}
