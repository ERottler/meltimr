#' Read GRDC data from file.
#'
#' Read in GRDC data time series from file.
#'
#' @param file_path  Path data table.
#' @export
read_grdc <- function(file_path){

  data_grdc <- read.table(file_path, sep = ";", header = T, stringsAsFactors = F, na.strings = c("-999.00","-999.000"))

  #define date
  data_grdc_date <- as.Date(strptime(data_grdc$YYYY.MM.DD, "%Y-%m-%d", tz="UTC"))

  #define value
  data_grdc_value <- data_grdc$Value

  data_grdc <- data.frame(date  = data_grdc_date,
                          value = data_grdc_value)

  #in case na strings not recognized
  na_vals <- which(data_grdc$value == -999)
  data_grdc$value[na_vals] <- NA

  return(data_grdc)

}
