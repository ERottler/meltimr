#' Read LamaH data from file.
#'
#' Read in LamaH data time series (https://doi.org/10.5281/zenodo.452524) from file.
#'
#' @param file_path  Path data time series data.
#' @export
read_lamah <- function(file_path){

  data_lamah <- utils::read.table(file_path, sep = ";", header = T, stringsAsFactors = F, na.strings = c(-999))

  #define date
  data_lamah_date <- as.Date(strptime(paste(data_lamah$YYYY, data_lamah$MM, data_lamah$DD), "%Y%m%d", tz="UTC"))
  data_lamah$date <- data_lamah_date

  #fill possible gaps wiht NA
  start_date <- data_lamah_date[1]
  end_date   <- data_lamah_date[length(data_lamah_date)]
  full_date  <- as.Date(seq(start_date, end_date, by="day"))

  data_lamah_fill <- data.frame(date  = full_date,
                                value = with(data_lamah, qobs[match(as.Date(full_date), as.Date(date))])
                                )

  #in case na strings not recognized
  na_vals <- which(data_lamah_fill$value == -999)
  data_lamah_fill$value[na_vals] <- NA

  return(data_lamah_fill)

}
