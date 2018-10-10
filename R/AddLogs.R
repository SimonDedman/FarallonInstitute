# Add columns of logged data to data series, appends cols to existing dataframe,
# returns df to be designated as a named object
## Simon Dedman 2018.10.10

AddLogs <- function(x, # dataframe with columns you want to log within it
                    toLog){ # single or vector of column names within x to log 
  for (i in toLog){ #loop through variable columns for each log variable
    x <- cbind(x, log1p(x[i])) #bind that as the final column of x
    colno <- length(colnames(x)) #get that col number
    colnames(x)[colno] <- paste0(i, "_log") #name new col name_log
  } #close i, all variables logged
  return(x) #output updated dataframe
} #close function
