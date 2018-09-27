# Add n rows years?) of lags to data series, appends cols to existing dataframe,
# returns df to be designated as a named object
## Simon Dedman 2018.09.25

AddLags <- function(x, # dataframe with columns you want to lag within it
                    lagYears = 1, # integer or vector of number of years to lag, can be nonsequential
                    toLag){ # single or vector of column names within x to lag 
  for(n in lagYears){ #start loop trough numbers of years to lag
    for (i in toLag){ #loop through variable columns for each lag year
      len <- length(x[,i])-n #length of variable i minus n rows, within x
      tmpcolname <- c(rep(NA, n), x[(1:len), i]) #create vec w/ n NAs @ front then variable minus n rows
      x <- cbind(x, tmpcolname) #bind that as the final column of x
      colno <- length(colnames(x)) #get that col number
      colnames(x)[colno] <- paste0(i, "_lag_", n) #name new col name_lag_n
    } #close i, all variables for that year of lag
  } #close n, final year of lag series
  return(x) #output updated dataframe
} #close function
