# Convert Sol enviro csvs into column per variable per area, row per year
# As opposed to column per variable, row per year, area as categorical variable
# Simon Dedman 2018.09.18
rm(list = ls()) # remove everything if you crashed before
# choose machine
#machine <- "/home" # linux desktop (& laptop?)
machine <- "C:/Users"# windows laptop 
# install/load tidyverse packages (see: http://r4ds.had.co.nz)
#install.packages("tidyverse")
#install.packages("lubridate")
library(tidyverse)
library(lubridate)

setwd(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Environmental'))
enviros <- read_csv('calcofi_timeseries_TSC_6regions_Jan-Apr_1949-2017 inc O2.csv', na = "NaN") #read data
envalnames <- c("Temp", "Sal", "ChlA", "O2", "Stab") # shorter names no spaces
colnames(enviros)[4:8] <- envalnames # assign names to cols
regNames <- c("CentCal", "Nearsh", "NCoast", "Offsh", "South", "Transition") #shorter region names
SpreadData <- unique(enviros["Year"]) # starting table to bind data to

for (i in envalnames){
  itmp <- enviros[c("Year", "Region", i)] # subset table for spread
  spreadtmp <- spread(itmp, key = Region, value = i) # spread to wide format, name per variable
  SpreadData <- cbind(SpreadData, spreadtmp[,2:7]) # bind data columns (not year) to existing df
  colstmp <- (length(SpreadData)-5):(length(SpreadData)) #range of column numbers in current SpreadData to name next
  nametmp <- paste0(i, "_", regNames) # vector of variable (dynamic) + region (static 6)
  colnames(SpreadData)[colstmp] <- nametmp # name columns
}

SpreadData <- SpreadData[-c(1,2),] # remove years 1949 & 1950
write_csv(SpreadData, "CalCOFI_Env_SpreadRegions.csv", na = "")