# Processed ERDDAP CalCOFI Egg & Larval data: filling in missing seasons
# Using regression analysis across type (egg-larvae) and season (preWinter-spring)
# Simon Dedman 2018.08.05
# Data from ERDDAP, see processing in ERDDAP_EnL.R


#1 Open files####
# choose machine
machine <- "/home" # linux desktop (& laptop?)
machine <- "C:/Users"# windows laptop
# install/load tidyverse packages (see: http://r4ds.had.co.nz)
#install.packages("tidyverse")
#install.packages("lubridate")
library(tidyverse)
library(lubridate)

setwd(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Biological/Anchovy & Sardine Biomass/CalCOFI egg & larval trawl/')) #set wd for export
egg <- read_csv("ERDDAP_CalCOFI_EggMeans.csv")
larvae <- read_csv("ERDDAP_CalCOFI_LarvalMeans.csv")
# both datasets are missing years where there are no springdata for any season

# both are missing preWinter, spring and thus peak values in 1974 & 1977

# both have preW values but are missing spring in 1967 1970 1976
# 1967 & 70: has data for December 1966 only
# 1976: Sol's calcofi cruises timeseries plot shows cruises in
# Jan, Feb, Mar/Apr, Apr/May, and a day in Nov, but there's nothing in ERDDAP
# (hence nothing the imported sheets)

# both have spring values but are missing preW in 2016 & 2017
# Presumably 2016 & 17 are due to cruise data not yet being available - asked JT
# if we know if/when we're expecting the Jan 16 & 17 data to hit ERDDAP
# 
# Priorities:
# 1. Find out about 2016 & 2017 preW from JT. If acquirable would strengthen
# correlation and obviate the need to do spring->preW analysis & infill
# 2. Find out about 1976 from Sol. As above, 1 fewer point.
# 3. 1967 & 1970: see how preW compares to spring for E&L and ALSO see whether
# date of cruise within a season affects its relation to means and thus the
# preW-spring connection. Would have to go back to source data from previous sheet.
# Average by month bin instead of season. Plot bins with box&whisker/violin plots.