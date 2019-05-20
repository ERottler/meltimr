#' Analysis on daily level
#'
#' Apply functions on daily level. First, time series re-structured according to day of the year, then selected analytical function applied.
#'
#' @param data  Vector of input data
#' @param date Time vector
#' @param start_year Selected start year
#' @param end_year Seleced end year
#' @param do_ma Apply moving average filter before analysis (FALSE / TRUE)
#' @param window_width If do_ma is TRUE, then moving average filter with here selected window width applied
#' @param Selected analytical method('mean', 'median', 'sum', 'sens_slope')
#' @export
day_ana <- function(data, date, start_year, end_year, do_ma = F, window_width = 30, method_ana){

  data_day <- order_day(data_in = data, date = date,  start_y = start_year, end_y = end_year,
                        do_ma = do_ma, window_width = window_width)

  if(method_analys == "mean"){
    res <- apply(data_day[,-1], 2, mea_na)
  }

  if(method_analys == "median"){
    res <- apply(data_day[,-1], 2, med_na)
  }

  if(method_analys == "sum"){
    f_sum <- function(data_in){sum(data_in, na.rm = T)}
    res <- apply(data_day[,-1], 2, f_sum)
  }

  if(method_analys == "sens_slope"){

    res <- apply(data_day[,-1], 2, sens_slo)

  }

  return(res)

}
