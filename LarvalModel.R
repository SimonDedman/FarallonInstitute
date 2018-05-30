## Larval model
## SD 23/05/2018

# which machine are you on?
machine <- "/home" # linux desktop (& laptop?)
machine <- "C:/Users"# windows laptop

##1 Import, clean, set variables####
# read in csv created from Data Structure Template excel
Annual <- read.csv(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Data Structure Template 2018.05.23.csv'))

colnames(Annual)
# for reference:
# 1:4 admin
# 5:12 anchovy response variables
# 13:22 large indices
# 23:41 wind
# 42:43 upwelling
# 44:45 stability
# 46: thermocline/nutricline depth
# 47:52 temperature
# 53:58 plankton
# 59:71 predator abundances
# 72:84 predator consumption of anchovy 
# 85 Fisheries ladings
# 86:92 trophic indices i.e. other similar trophic level species' biomasses/catches

## remove dud columns: 
# 2 lat, don't need until spatialising later
# 3 lon, ditto
# 4 CalCOFI line station: ditto
# 7 A spawning bio jacobson:unreqd dupe
# 8 Recruitment: ditto
# 9 total: ditto
# 17 NOI use BUI
# 18 NPI Bill says axe it
# 19 NPC streamline lat: currently empty, remove from list later
# 20 NEI data quality currently unverified
# 35 wind surface speed & direction: CalCOFI, not going to use
# 44 stability strength: currently empty, remove from list later
# 45 stability duration: currently empty, remove from list later
# 46 thermocline/nutricline depth: currently empty, remove from list later 
# 47 SST CalCOFI: currently empty, remove from list IF USED
# 52 temp at depth: currently empty, remove from list later
# 53: chlA: currently empty, remove from list later
# 55:58: possible double/triplecounting or empty, remove later maybe
# 60: Jack mackerel, too few data, insufficient variation
# 65,67:69,71: chinook salmon, common murre, sooty shearwater, short beaked common dolphin, humboldt squid: currently empty, remove from list later
# 73,74,78,80,82,84 : Consumpton by jack, pacific mackerel, chinook salmon, common murre, short beaked common dolphin, humboldt squid: currently empty, remove from list later. Jack has data but too few.
dudcols <- c(2,3,4,7,8,9,17,18,19,20,35,44,45,46,47,52,53,55:58,60,65,67:69,71,73,74,78,80,82,84)
Annual <- Annual[, -dudcols] # remove dud columns

# set response variable
resvar <- 3 # anchovy larvae

# remove NA rows
Annual <- Annual[-which(is.na(Annual[resvar])),]

# set explantory variables - basically amost everything else!
colnames(Annual)
expvars <- c(7:length(Annual))

#Install pacages####
# install.packages("devtools")
library(devtools)
install_github("SimonDedman/gbm.auto") # update gbm.auto to latest
library(gbm.auto)

#Run code####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/"))

gbm.auto(expvar = expvars,
         resvar = resvar,
         samples = Annual,
         lr = c(0.001),
         ZI = F,
         fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         simp = F)

# Error in plot.new() : figure margins too large
# gbm.uto L502/515, and/or RStudio's fault?
# 
# Erik's optimiser?