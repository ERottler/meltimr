#' Order time series by day
#'
#' Order time series according to day of the year and return as matrix with columns is days of the year and rows years.
#'
#' @param data_in  Vector of data values.
#' @param date Date vector as character with form YYYY-MM_DD
#' @param start_y Selected start year.
#' @param end_y Selected end year.
#' @export
ord_day <- function(data_in, date, start_y, end_y){

  input_data_full <- data.frame(date = date, value = data_in)

  #Clip selected time period
  input_data <- input_data_full[as.numeric(format(input_data_full$date,'%Y')) >= start_y, ]
  input_data <- input_data[as.numeric(format(input_data$date,'%Y')) <= end_y, ]

  #Fill possible gaps
  start_date <- as.POSIXct(strptime(paste0(start_y,"-01-01"), "%Y-%m-%d", tz="UTC"))
  end_date   <- as.POSIXct(strptime(paste0(end_y,"-12-31"),   "%Y-%m-%d", tz="UTC"))
  full_date  <- seq(start_date, end_date, by="day")

  input_data <- data.frame(dates  = full_date,
                           values = with(input_data, value[match(as.Date(full_date), as.Date(date))])
  )

  #Remove 29th of February
  input_data <- input_data[-which(format(input_data$date, "%m%d") == "0229"),]

  #Vector with the 365 days of the year
  days <- seq(as.Date('2014-01-01'), to=as.Date('2014-12-31'), by='days')
  days <- format(days,"%m-%d")

  #Order data by day
  data_day <-  matrix(NA, nrow = length(start_y:end_y), ncol = 365)
  colnames(data_day) <- c(days)

  for(i in 0:(length(start_y:end_y)-1)) {

    data_day[i, 1:365] <- input_data$values[(i*365+1):((i+1)*365)]

  }

  return(data_day)

}
