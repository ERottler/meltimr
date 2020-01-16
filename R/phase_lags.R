#' Phase lags
#'
#' Calculations of phase lags between mean hydrograph and individual years using package: devtools::install_github("laubblatt/phaselag").
#'
#' @param data_day Matrix with values ordered by day (see function ord_day()).
#' @param break_day Define start year (e.g. 274 is 1.October is start hydrological year in Switzerland).
#' @param sta_yea_cla Start year of entire time series
#' @param end_yea_cla End year of entire time series.
#' @export
f_phase_lag <- function(grdc_data, break_day, end_yea_cla, sta_yea_cla){
  sta_yea_cla <- as.numeric(format(grdc_data$date[1], "%Y"))
  end_yea_cla <- as.numeric(format(grdc_data$date[nrow(grdc_data)], "%Y"))

  #Order data by day (including break day to set start hydrologica year)
  data_day <- ord_day(data_in = grdc_data$value,
                      date = grdc_data$date,
                      start_y = sta_yea_cla,
                      end_y = end_yea_cla,
                      break_day = break_day_pha,
                      do_ma = do_ma,
                      window_width = ma_window)

  #Mean seasonal cycle discharge
  dis_mea <- apply(data_day, 2, mea_na)

  #calculate lag between mean cycle and all other yearly cycles
  dis_lag <- function(dat, ref, year_in = 2010, smo_ref = -1, smo_dat = -1){

    ind_sel <- which(format(dat$date, "%Y") == year_in)

    if(length(ind_sel) < 365 ){

      my_phaselag <- NA

    }else{

      if(length(which(is.na(dat$value[ind_sel])) > 0)){

        my_phaselag <- NA

      }else{

        dis_y <- smoothFFT(dat$value[ind_sel], sd = smo_dat)
        ref <- smoothFFT(ref, sd = smo_ref)

        if(length(dis_y) > 365){
          ref <- c(ref, ref[length(ref)])
        }

        dref <- c(NA, diff(ref))

        my_slope_1 <- coef(lm(dis_y ~ ref))[2]
        my_slope_2 <- coef(lm(dis_y ~ dref))[2]
        my_day <- 365 #number of measurements per period
        my_unit <- 365 #number of time steps per period

        my_phaselag <- phaselag_time(slope1 = my_slope_1, slope2 = my_slope_2, nday = my_day, timeunitperday = my_unit)
        # plot(dis_y, type = "l")
      }

    }

    return(my_phaselag * -1) #multiply with -1 so that positive values = earlier

  }

  lag_years <-sta_yea_cla:end_yea_cla
  my_lags <- rep(NA, length(lag_years))

  for(i in 1:length(lag_years)){
    print(lag_years[i])
    my_lags[i] <- dis_lag(dat = grdc_data, ref = dis_mea, year_in = lag_years[i],
                          smo_ref = -1, smo_dat = -1)

  }

  return(my_lags)

}
