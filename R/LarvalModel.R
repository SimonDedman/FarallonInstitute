## Larval model
## SD 19/06/2018

# which machine are you on?
machine <- "/home" # linux desktop (& laptop?)
machine <- "C:/Users"# windows laptop

##1 Import, clean, set variables####
# read in csv created from Data Structure Template excel
Annual <- read.csv(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Data Structure Template 2018.06.06.csv'))

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
#dudcols <- c(2,3,4,7,8,9,17,18,19,20,35,44,45,46,47,52,53,55:58,60,65,67:69,71,73,74,78,80,82,84)
#Annual <- Annual[, -dudcols] # remove dud columns

#Instead SELECT NAMED goodcols:
goodcols <- c("MEI_PreW","MEI_Spring", "NPGO_PreW", "NPGO_Spring","NPC_Str_Lat",
              "SeaLevLA_PreW","SeaLevLA_Spring", "Ek_PreW_46025","Ek_Spr_46025",
              "Ek_PreW_46011","Ek_Spr_46011","Ek_PreW_46012",
              "Ek_Spr_46012","FourDCP_PreW_46025","FourDCP_Spr_46025",
              "FourDCP_PreW_46011","FourDCP_Spr_46011","FourDCP_PreW_46012",
              "FourDCP_Spr_46012","CrsWnd_PreW_46025","CrsWnd_Spr_46025",
              "CrsWnd_PreW_46011","CrsWnd_Spr_46011","CrsWnd_PreW_46012",
              "CrsWnd_Spr_46012","BUI33N_PreW","BUI33N_Spring","PDO_PreW",
              "PDO_Spring","LaJ_T_PreW","LaJ_T_Spring","Sml_P","Euphausiids",
              "C_Hake","C_SeaLion","C_Albacore","C_Halibut",
              "C_SoShWa","C_HBW","FishLand","Catch_Sard","Biom_Sard_Alec",
              "Biom_Sard_Andre","Hake_Biom","Msquid_Biom","Rockfish_Biom","Krill_Biom")

# set response variable
resvar <- "Anch_Larvae" # anchovy larvae
resvar <- "A_Tot_B" # anchovy total biomass

# remove NA rows
Annual <- Annual[-which(is.na(Annual[resvar])),]

# set explantory variables - basically amost everything else!
expvars <- goodcols

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
         simp = T,
         multiplot = F,
         varint = F)

# Error in plot.new() : figure margins too large
# gbm.uto L502/515, and/or RStudio's fault?
# fixed with multiplot code addition
# 
# [1] "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX      Bar plots plotted      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
# gbm.interactions - version 2.9
# Cross tabulating interactions for gbm model with 48 predictors
# 1 Error in `contrasts<-`(`*tmp*`, value = contr.funs[1 + isOF[nn]]) : 
#   contrasts can be applied only to factors with 2 or more levels
#
#Turn off varint? Works but what's the 1 factor variable? Examine. None are...
#Works. List expvars by explantory percentage? See report!
#48 expvars, 33 w/ <1% inf, 40 w/ <2%, 8 w/ 83% total:
#Sml_P, Krill_Biom, Biom_Sard_Andre, C_Sablefish, Rockfish_Biom, FishLand, NPGO_Spring, LaJ_T_PreW
# Try simp

gbm.auto(expvar = expvars,
         resvar = resvar,
         samples = Annual,
         lr = c(0.001),
         ZI = F,
         fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = F)
# Check simp report: dropped small_p & sablefish, 2 of the most important variables!! And none of the shit!
# # In any case we need to discuss and prune & agglomerate variables cos this is too much.
# Total biomass not resolving, fitting w 50 trees, broken, why.
 
# Erik's optimiser?