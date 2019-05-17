#' Read GRDC data from file.
#'
#' Read in GRDC data table from repository.
#'
#' @param file_path  Path data table.
#' @export
read_grdc <- function(file_path){

  data_grdc <- read.table(file_path, sep = ";", header = T, stringsAsFactors = F, na.strings = "-999.000")

  #define date
  data_grdc_date <- as.Date(strptime(data_grdc$YYYY.MM.DD, "%Y-%m-%d", tz="UTC"))

  #define value
  data_grdc_value <- data_grdc$Value

  data_grdc <- data.frame(date  = data_grdc_date,
                             value = data_grdc_value)

  return(data_grdc)

}
