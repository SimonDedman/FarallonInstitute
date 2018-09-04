# CalCOFI Egg & Larval data processing and analysis
# Simon Dedman 2018.08.04



#1 Acquire data####
# ERDDAP Egg:
# https://coastwatch.pfeg.noaa.gov/erddap/tabledap/erdCalCOFIeggcnt.html
# drag time slider to left to get whole extent
# Click right hand side scientific_name dropdown & select Engraulis Mordax
# Deselect eggs_1000m3, eggs_count_raw, calcofi speceis code, itis tsn, common name
# file type change to csvp
# 
# ERDDAP larvae
# https://coastwatch.pfeg.noaa.gov/erddap/tabledap/erdCalCOFIlrvcntEDtoEU.html
# repeat as above
# 
# I moved files & changed filenames, will be obvious in next section



#2 Open files####
# choose machine
machine <- "/home" # linux desktop (& laptop?)
machine <- "C:/Users"# windows laptop
# install/load tidyverse packages (see: http://r4ds.had.co.nz)
#install.packages("tidyverse")
#install.packages("lubridate")
library(tidyverse)
library(lubridate)
egg <- read_csv(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Biological/Anchovy & Sardine Biomass/CalCOFI egg & larval trawl/erdCalCOFIeggcntAnch51-20170422.csv'))
# Parsed with column specification:
#   cols(
#     cruise = col_integer(),
#     ship = col_character(),
#     ship_code = col_character(),
#     order_occupied = col_integer(),
#     tow_type = col_character(),
#     net_type = col_character(),
#     tow_number = col_integer(),
#     net_location = col_character(),
#     standard_haul_factor = col_double(),
#     `volume_sampled (cubic meters)` = col_double(),
#     `percent_sorted (%/100)` = col_double(),
#     sample_quality = col_double(),
#     `latitude (degrees_north)` = col_double(),
#     `longitude (degrees_east)` = col_double(),
#     line = col_double(),
#     station = col_double(),
#     `time (UTC)` = col_datetime(format = ""),
#     scientific_name = col_character(),
#     `eggs_10m2 (Eggs per ten meters squared of water sampled)` = col_double()
#   )
larvae <- read_csv(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Biological/Anchovy & Sardine Biomass/CalCOFI egg & larval trawl/erdCalCOFIlrvcntAnch51-20170422.csv'))
# Parsed with column specification:
#   cols(
#     cruise = col_integer(),
#     ship = col_character(),
#     ship_code = col_character(),
#     order_occupied = col_integer(),
#     tow_type = col_character(),
#     net_type = col_character(),
#     tow_number = col_integer(),
#     net_location = col_character(),
#     standard_haul_factor = col_double(),
#     `volume_sampled (cubic meters)` = col_double(),
#     `percent_sorted (%/100)` = col_double(),
#     sample_quality = col_double(),
#     `latitude (degrees_north)` = col_double(),
#     `longitude (degrees_east)` = col_double(),
#     line = col_double(),
#     station = col_double(),
#     `time (UTC)` = col_datetime(format = ""),
#     scientific_name = col_character(),
#     `larvae_10m2 (Fish larvae per ten meters squared of water sampled)` = col_double()
#   )



#3 rename columns####
colnames(egg)
# [1] "cruise"                        "ship"                          "ship_code"                     "order_occupied"               
# [5] "tow_type"                      "net_type"                      "tow_number"                    "net_location"                 
# [9] "standard_haul_factor"          "volume_sampled (cubic meters)" "percent_sorted (%/100)"        "sample_quality"               
# [13] "latitude (degrees_north)"      "longitude (degrees_east)"      "line"                          "station"                      
# [17] "time (UTC)"                    "scientific_name"               "eggs_10m2..Eggs.per.ten.meters.squared.of.water.sampled."
colnames(egg)[19] <- "Eggs10m2"
colnames(larvae)
# [1] "cruise" "ship"                                                             
# [3] "ship_code" "order_occupied"                                                   
# [5] "tow_type" "net_type"                                                         
# [7] "tow_number" "net_location"                                                     
# [9] "standard_haul_factor" "volume_sampled (cubic meters)"                                    
# [11] "percent_sorted (%/100)" "sample_quality"                                                   
# [13] "latitude (degrees_north)" "longitude (degrees_east)"                                         
# [15] "line" "station"                                                          
# [17] "time (UTC)" "scientific_name"                                                  
# [19] "larvae_10m2 (Fish larvae per ten meters squared of water sampled)"
colnames(larvae)[19] <- "Larvae10m2"
colnames(egg)[10] <- "VolSampledM3"
colnames(larvae)[10] <- "VolSampledM3"
colnames(egg)[11] <- "PctSorted"
colnames(larvae)[11] <- "PctSorted"
colnames(egg)[13] <- "latitude"
colnames(larvae)[13] <- "latitude"
colnames(egg)[14] <- "longitude"
colnames(larvae)[14] <- "longitude"
colnames(egg)[17] <- "datetime"
colnames(larvae)[17] <- "datetime"



#4 %sorted to %####
egg[,11] <- egg[,11]*100
larvae[,11] <- larvae[,11]*100



#5 add month & year columns####
egg$year <- year(egg$datetime)
larvae$year <- year(larvae$datetime)
egg$month <- month(egg$datetime)
larvae$month <- month(larvae$datetime)



#6 Calc seasonal values####
# average seasonal per10m2 values
# Current processing of CalCOFI cruise data bins data into seasons:
# Winter: Jan to March
# Spring: April to June
# Summer: July to September
# Autumn: October to December
# See Sol's colour scheme
# (C:\Users\simon\Dropbox\Farallon Institute\Data & Analysis\Biological\Anchovy & Sardine Biomass\CalCOFI egg & larval trawl\date_ranges_calcoficruises_E&LresvarPeriods.png)
# Adult abundance tesselations by Pete Davison & Alec MacCall ostensibly use
# 'touching January' and 'touching April' to apportion data to the two key seasons
# However the spreadsheets don't bear that out, e.g. 1983 has cruises touching 
# Jan and April yet has no data.
# Given CalCOFI cruise schedules have calcified around January/April/July/November
# since the 90s/00s, I propose DJF/MAM/JJA/SON (12,1,2/3,4,5/6,7,8/9,10,11)are the logical month thresholds
# by which to bin data that represent the central months during which cruises are
# (since the 90s) conducted.
# 
# Therefore for each year we want the
# - per10m2 for all available cruise data (existing rows)
# - per year
# - per season as defined by date ranges
# Averaged within those ranges.
# dataframe format: year (rows), season (columns), average (values)

yearrange <- range(year(egg$datetime)) # year range
allyears <- seq(from = yearrange[1], to = yearrange[2], by = 1) # year range vector

eggSeason <- data.frame("DJF" = rep(NA, length(allyears)),
                        "MAM" = rep(NA, length(allyears)),
                        "JJA" = rep(NA, length(allyears)),
                        "SON" = rep(NA, length(allyears)),
                        row.names = allyears) #blank dataframe
larvalSeason <- data.frame("DJF" = rep(NA, length(allyears)),
                        "MAM" = rep(NA, length(allyears)),
                        "JJA" = rep(NA, length(allyears)),
                        "SON" = rep(NA, length(allyears)),
                        row.names = allyears)

# need to populate
# DJF = average of subset of egg$Eggs10m2 where subset is
#  year = rowyear-1 AND month = dec
#  AND
#  year = rowyear AND month = jan OR feb
# MAM = average of subset of egg$Eggs10m2 where subset is
#  year = rowyear AND month = mar OR apr OR may
#  JJA: year = rowyear AND month = june or july or august
#  SON sept oct nov
#  
#  To get around the december problem i need to create an index column which i can then use to easily subset the data
#  can then just use aggregate: aggregate(Eggs10m2 ~ year + season, egg, mean)
#  i need december's yearseason to be the next year.
#  So just change all december values to the following year? Simply add 1 to year value for december months?!
egg[egg$month == 12,"year"] <- egg[egg$month == 12,"year"] + 1
# only affects year column doesn't mess with datetime
larvae[larvae$month == 12,"year"] <- larvae[larvae$month == 12,"year"] + 1
# create season lookup table to populate final columns
seasons <- data.frame("month" = c(12, 1:11), "season" = c(rep("PreWinter",3), rep("Spring", 3), rep("Summer", 3), rep("Autumn", 3)))
egg$season <- seasons$season[match(egg$month,seasons$month)]
larvae$season <- seasons$season[match(larvae$month,seasons$month)]

eggMeans <- aggregate(Eggs10m2 ~ year + season, egg, mean) # new df, means by year and season
eggMeans$season <- factor(eggMeans$season, levels = c("PreWinter", "Spring", "Summer", "Autumn")) # reorder season factors
eggMeans <- eggMeans[with(eggMeans, order(year, season)),] # reorder df by year then season
eggMeans <- spread(eggMeans, key = season, value = Eggs10m2) # spread AKA cast kindaAKA reshape df to wide format

larvalMeans <- aggregate(Larvae10m2 ~ year + season, larvae, mean) # new df, means by year and season
larvalMeans$season <- factor(larvalMeans$season, levels = c("PreWinter", "Spring", "Summer", "Autumn")) # reorder season factors
larvalMeans <- larvalMeans[with(larvalMeans, order(year, season)),] # reorder df by year then season
larvalMeans <- spread(larvalMeans, key = season, value = Larvae10m2) # spread AKA cast kindaAKA reshape df to wide format

# similar exercise to average from December to May
peakseasons <- data.frame("month" = c(12, 1:11), "season" = c(rep("Peak",6), rep("NonPeak", 6)))
egg$peakseason <- peakseasons$season[match(egg$month,peakseasons$month)]
larvae$peakseason <- peakseasons$season[match(larvae$month,peakseasons$month)]

eggMeans2 <- aggregate(Eggs10m2 ~ year + peakseason, egg, mean) # new df, means by year and season
eggMeans2 <- spread(eggMeans2, key = peakseason, value = Eggs10m2) # spread AKA cast kindaAKA reshape df to wide format
larvalMeans2 <- aggregate(Larvae10m2 ~ year + peakseason, larvae, mean) # new df, means by year and season
larvalMeans2 <- spread(larvalMeans2, key = peakseason, value = Larvae10m2) # spread AKA cast kindaAKA reshape df to wide format

eggMeans <- cbind(eggMeans, eggMeans2[,2:3]) #bind peak/nonpeak to 4 seasons
larvalMeans <- cbind(larvalMeans, larvalMeans2[,2:3])

setwd(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Biological/Anchovy & Sardine Biomass/CalCOFI egg & larval trawl/')) #set wd for export
write_csv(x = eggMeans, path = "ERDDAP_CalCOFI_EggMeans.csv", na = "") # export
write_csv(x = larvalMeans, path = "ERDDAP_CalCOFI_LarvalMeans.csv", na = "")
