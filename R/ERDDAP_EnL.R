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



#4 pct as actual pct####
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
#6.1 create dfs####
yearrange <- range(year(egg$datetime)) # min & max of all years
allyears <- seq(from = yearrange[1], to = yearrange[2], by = 1) # year range, includes all missing years some of which may be absent in dataset

eggSeason <- data.frame("DJF" = rep(NA, length(allyears)),
                        "MAM" = rep(NA, length(allyears)),
                        "JJA" = rep(NA, length(allyears)),
                        "SON" = rep(NA, length(allyears)),
                        row.names = allyears) #blank dataframe
larvalSeason <- eggSeason #duplicate for larvae

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
#6.2 december to next year####
#  To get around the december problem i need to create an index column which i can then use to easily subset the data
#  can then just use aggregate: aggregate(Eggs10m2 ~ year + season, egg, mean)
#  i need december's yearseason to be the next year.
#  So just change all december values to the following year: Simply add 1 to year value for december months
egg[egg$month == 12,"year"] <- egg[egg$month == 12,"year"] + 1
# only affects year column doesn't mess with datetime
larvae[larvae$month == 12,"year"] <- larvae[larvae$month == 12,"year"] + 1

#6.3 lookup table####
# create lookup table to populate season bins columns
seasons <- data.frame("month" = c(12, 1:11), "season" = c(rep("PreWinter",3), rep("Spring", 3), rep("Summer", 3), rep("Autumn", 3)))
egg$season <- seasons$season[match(egg$month,seasons$month)]
larvae$season <- seasons$season[match(larvae$month,seasons$month)]


#SUBSET BY LINE+STATION####
lineStations <- read_csv(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Biological/Anchovy & Sardine Biomass/CalCOFI egg & larval trawl/CoreSCB_lineStationsList.csv'))
egg$LineStation <- paste0(as.character(egg$line), "+", as.character(egg$station))
larvae$LineStation <- paste0(as.character(larvae$line), "+", as.character(larvae$station))
#class(lineStations)
lineStations <- as.vector(lineStations$`Line+Station`)

# filter for rows whereegg/larval line+stations are in core list (TRUE)
tmp <- egg$LineStation  %in% lineStations
egg <- egg[tmp,]

tmp <- larvae$LineStation  %in% lineStations
larvae <- larvae[tmp,]


#6.4 compute annual season bin averages####
eggMeans <- aggregate(Eggs10m2 ~ year + season, egg, mean) # new df, means by year and season aggregating all lines&stations
eggMeans$season <- factor(eggMeans$season, levels = c("PreWinter", "Spring", "Summer", "Autumn")) # reorder season factors
eggMeans <- eggMeans[with(eggMeans, order(year, season)),] # reorder df by year then season
eggMeans <- spread(eggMeans, key = season, value = Eggs10m2) # spread AKA cast kindaAKA reshape df to wide format

larvalMeans <- aggregate(Larvae10m2 ~ year + season, larvae, mean)
larvalMeans$season <- factor(larvalMeans$season, levels = c("PreWinter", "Spring", "Summer", "Autumn"))
larvalMeans <- larvalMeans[with(larvalMeans, order(year, season)),]
larvalMeans <- spread(larvalMeans, key = season, value = Larvae10m2)

#6.5 compute peak (5mo) averages####
#Changed from Dec-May to Jan-May
peakseasons <- data.frame("month" = c(12, 1:11), "season" = c("NonPeak", rep("Peak",5), rep("NonPeak", 6)))
egg$peakseason <- peakseasons$season[match(egg$month,peakseasons$month)]
larvae$peakseason <- peakseasons$season[match(larvae$month,peakseasons$month)]

eggMeans2 <- aggregate(Eggs10m2 ~ year + peakseason, egg, mean) # new df, means by year and season
eggMeans2 <- spread(eggMeans2, key = peakseason, value = Eggs10m2) # spread AKA cast kindaAKA reshape df to wide format
larvalMeans2 <- aggregate(Larvae10m2 ~ year + peakseason, larvae, mean)
larvalMeans2 <- spread(larvalMeans2, key = peakseason, value = Larvae10m2)

eggMeans <- cbind(eggMeans, eggMeans2[,2:3]) #bind peak/nonpeak to 4 seasons
larvalMeans <- cbind(larvalMeans, larvalMeans2[,2:3])

#6.6 compute monthly bin averages####
eggMeans3 <- aggregate(Eggs10m2 ~ year + month, egg, mean) # new df, means by year and season
eggMeans3 <- spread(eggMeans3, key = month, value = Eggs10m2) # spread AKA cast kindaAKA reshape df to wide format
larvalMeans3 <- aggregate(Larvae10m2 ~ year + month, larvae, mean)
larvalMeans3 <- spread(larvalMeans3, key = month, value = Larvae10m2)

#column names months
jfmam <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
colnames(eggMeans3)[2:13] <- jfmam
colnames(larvalMeans3)[2:13] <- jfmam
# move dec to before jan
eggMeans3 <- eggMeans3[,c(1, 13, 2:12)]
larvalMeans3 <- larvalMeans3[,c(1, 13, 2:12)]

eggMeans <- cbind(eggMeans, eggMeans3[,2:13]) #bind peak/nonpeak to 4 seasons
larvalMeans <- cbind(larvalMeans, larvalMeans3[,2:13])



#7 month2month change factor?####
# jan divided by dec for each month til may, n=5
# feb divided by dec ditto, n=4
# how many do I actually need to do? How many originally missing which I've imputed currently with season ranges?
# 11 jan 8 april
# How many of these newly imputed values were from peak season (Feb/Mar not touching Jan or Apr)?
# 1957 no jan now poulated, Sol jan & feb cruises, ERDDAP dec:may
# 1967 no jan or apr, now jan from Dec, figure v low
# 1968 no april but 2 april cruises, populated but figure low
# 1970 nothing now preW from Dec figure normal
# 1971/3/4 nothing nothing
# 1975 no apr now populated v high. Cruise from Jan to 31 mar & all May. Poster child for current technique? May values should average down March ones; Dec & Feb should average out for Jan.
# 1976 nothing now PreW from dec.
# 1977 nothing nothing
# 1980 nothing now both, makes no sense per Sol's plot as apparently no cruises from aug 78 til dec 80 (counts as 81). ERDDAP values exist from Feb to Jun suggesting a cruise.
# 1982 no jan now populated; again SOl plot says no cruises but data from Jan to Apr
# 1983 nothing now both; Sol plot says mini cruises in Jan Mar Apr May, ERDDAP has Jan:Apr data
# 1985 nothing/both; Sol cruise Feb-Mar, ERDDAP jan:may
# 1986 no spring; Sol feb mar & may but no touch apr, ERDDAP jan feb may
# 1987 no jan; Sol mar & apr/may, ERDDAP jan:may
# 1990 no jan, sol concurs, now 0, ERDDAP 1 zero val in Jan. Check source data for that zero. How many points? Fair to discard? Better to have NA than 0?
tmp90 <- subset(x = egg, year == 1990 & month == 1) # 99 hauls, well enough
# 1991 no apr now present, Sol feb/mar cruise, ERDDAP mar:apr
# 2006 no jan now present, Sol Feb cruise, ERDDAP feb, very low figure
# 2009 no apr now present, Sol mar cruise, ERDDAP Mar:May
tmp09 <- subset(x = egg, year == 2009 & month >= 3 & month <= 5) # n=402
# 2016 nothing now spring, Sol all jan & all apr, ERDDAP mar:apr; preW cruise not yet available
# 2017 per 2016

# Season bin technique more defensible than touching technique:
## touching is missing data in years where cruises were done in key months e.g. 1968, 1980
## risk of only high feb data populating touchingJan (or Mar for TouchApr) balanced against benefit of averaging data from e.g. dec AND feb in a jan-absent year instead of nothing (1975)
## ERDDAP has no single instance of a high Feb value populating TouchingJan when no Jan or Jan+Dec values aren't also present
## 1 instance of high March but no April but balanced by presence of also-previously-ignored May data (1975)
## THEREFORE: postulated risks not realised in practice. New technique improves and grows dataset.
## THEREFORE: do not attempt to impute missing seasons using another technique.

#8 writecsv####
setwd(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Biological/Anchovy & Sardine Biomass/CalCOFI egg & larval trawl/')) #set wd for export
write_csv(x = eggMeans, path = "ERDDAP_CalCOFI_EggMeans3.csv", na = "") # export
write_csv(x = larvalMeans, path = "ERDDAP_CalCOFI_LarvalMeans3.csv", na = "")


#9 check no directionality in absent line+stations per year####
#pivottable, linestation as rows, years as columns, data as counts per year & linestation
library(reshape2)
larvae_lnSt_Yrs = dcast(larvae, LineStation ~ year, value.var = "Larvae10m2")
# Aggregation function missing: defaulting to length. Fine that's what I want: count of occurrences of data.
write_csv(x = larvae_lnSt_Yrs, path = "Larvae_LineStations_years.csv", na = "")

#END####