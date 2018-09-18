## Larval model
## SD started 19/06/2018
## Latest edit 29/08/2018

rm(list = ls()) # remove everything if you crashed before

#Install packages####
# install.packages("devtools")
library(devtools)
#install_github("SimonDedman/gbm.auto") # update gbm.auto to latest
library(gbm.auto)

# which machine are you on?
#machine <- "/home" # linux desktop (& laptop?)
machine <- "C:/Users"# windows laptop

##1 Import, clean, set variables####
# read in csv created from Data Structure Template excel
Annual <- read.csv(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Data Structure Template 2018.09.05.csv'),
                   na.strings = "")
# Annual <- Annual[5:nrow(Annual),] # Trim first 4 rows. Now done beforehand so data columns aren't imported as factors
# clip off dud rows year 2018 & beyond if present
Annual <- Annual[1:(match(2017, Annual$Year)),]


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
AdultResvar <- "A_Tot_B"
AdultExpvars <- c("A_Tot_B_Y.1", "MEI_PreW", "MEI_Spring", "NPGO_PreW",
                  "NPGO_Spring","NPC_Str_Lat", "SeaLevLA_PreW","SeaLevLA_Spring",
                  "Ek_PreW_46025","Ek_Spr_46025", "Ek_PreW_46011","Ek_Spr_46011",
                  "Ek_PreW_46012", "Ek_Spr_46012","FourDCP_PreW_46025","FourDCP_Spr_46025",
                  "FourDCP_PreW_46011","FourDCP_Spr_46011","FourDCP_PreW_46012",
                  "FourDCP_Spr_46012","CrsWnd_PreW_46025","CrsWnd_Spr_46025",
                  "CrsWnd_PreW_46011","CrsWnd_Spr_46011","CrsWnd_PreW_46012",
                  "CrsWnd_Spr_46012","BUI33N_PreW","BUI33N_Spring","Stability_all",
                  "Stability_nearshore", "PDO_PreW",
                  "PDO_Spring","LaJ_T_PreW","LaJ_T_Spring","TempAtDep_all",
                  "TempAtDep_nearshore", "SalAtDep_all", "SalAtDep_nearshore",
                  "O2AtDep_all", "O2AtDep_nearshore",
                  "ChlA_all", "ChlA_nearshore","Sml_P", "Euphausiids",
                  "Hake", "C_SeaLion","Albacore","Halibut","C_Murre",
                  "SoShWa","HBW","Hsquid", "FishLand","MktSqdCatch",
                  "Catch_Sard","Biom_Sard_Alec", "Msquid_CPUE", "Krill_CPUE", "Krill_mgCm2")

LarvalResvar <- "Anch_Larvae_Peak"
LarvalExpvars <- c("Anch_Egg_Peak", "A_Tot_B", "MEI_PreW", "MEI_Spring", "NPGO_PreW",
                  "NPGO_Spring","NPC_Str_Lat", "SeaLevLA_PreW","SeaLevLA_Spring",
                  "Ek_PreW_46025","Ek_Spr_46025", "Ek_PreW_46011","Ek_Spr_46011",
                  "Ek_PreW_46012", "Ek_Spr_46012","FourDCP_PreW_46025","FourDCP_Spr_46025",
                  "FourDCP_PreW_46011","FourDCP_Spr_46011","FourDCP_PreW_46012",
                  "FourDCP_Spr_46012","CrsWnd_PreW_46025","CrsWnd_Spr_46025",
                  "CrsWnd_PreW_46011","CrsWnd_Spr_46011","CrsWnd_PreW_46012",
                  "CrsWnd_Spr_46012","BUI33N_PreW","BUI33N_Spring","Stability_all",
                  "Stability_nearshore", "PDO_PreW",
                  "PDO_Spring","LaJ_T_PreW","LaJ_T_Spring","TempAtDep_all",
                  "TempAtDep_nearshore", "SalAtDep_all", "SalAtDep_nearshore",
                  "O2AtDep_all", "O2AtDep_nearshore", "ChlA_all", "ChlA_nearshore","Sml_P", "Lrg_P",
                  "Hake", "Jmac", "Cmac", "Catch_Sard","Biom_Sard_Alec", "Krill_CPUE", "Krill_mgCm2")

EggResvar <- "Anch_Egg_Peak"
EggExpvars <- c("A_Tot_B", "MEI_PreW", "MEI_Spring", "NPGO_PreW",
                   "NPGO_Spring","NPC_Str_Lat", "SeaLevLA_PreW","SeaLevLA_Spring",
                   "Ek_PreW_46025","Ek_Spr_46025", "Ek_PreW_46011","Ek_Spr_46011",
                   "Ek_PreW_46012", "Ek_Spr_46012","FourDCP_PreW_46025","FourDCP_Spr_46025",
                   "FourDCP_PreW_46011","FourDCP_Spr_46011","FourDCP_PreW_46012",
                   "FourDCP_Spr_46012","CrsWnd_PreW_46025","CrsWnd_Spr_46025",
                   "CrsWnd_PreW_46011","CrsWnd_Spr_46011","CrsWnd_PreW_46012",
                   "CrsWnd_Spr_46012","BUI33N_PreW","BUI33N_Spring","Stability_all",
                   "Stability_nearshore", "PDO_PreW",
                   "PDO_Spring","LaJ_T_PreW","LaJ_T_Spring","TempAtDep_all",
                   "TempAtDep_nearshore", "SalAtDep_all", "SalAtDep_nearshore",
                   "O2AtDep_all", "O2AtDep_nearshore", "Lrg_P", "Hake", "Jmac",
                   "Cmac", "Catch_Sard","Biom_Sard_Alec", "Krill_CPUE", "Krill_mgCm2")

AdultResvarCol <- match(AdultResvar, names(Annual))
AdultExpvarsCols <- match(AdultExpvars, names(Annual))
LarvalResvarCol <- match(LarvalResvar, names(Annual))
LarvalExpvarsCols <- match(LarvalExpvars, names(Annual))
EggResvarCol <- match(EggResvar, names(Annual))
EggExpvarsCols <- match(EggExpvars, names(Annual))

# remove NA rows
AdultSamples <- Annual[-which(is.na(Annual[AdultResvar])),]
LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]

#2 Run code####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/"))
#2.1 Adult####
# dir.create("Adults")
setwd("Adults")
# 57 obs

gbm.auto(expvar = AdultExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamples,
         lr = c(0.000001),
         ZI = F,
         fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = F)
#!AdultRunNote!####
#Can't get adults to run and produce deviance curve plots i.e. model can't differentiate causes of changes
#remove redundant variables

AdultExpvars <- c("A_Tot_B_Y.1", "MEI_PreW", "MEI_Spring", "NPGO_PreW",
                  "NPGO_Spring","NPC_Str_Lat", "SeaLevLA_PreW","SeaLevLA_Spring",
                  "Ek_PreW_46025","Ek_Spr_46025", "Ek_PreW_46011","Ek_Spr_46011",
                  "Ek_PreW_46012", "Ek_Spr_46012","FourDCP_PreW_46025","FourDCP_Spr_46025",
                  "FourDCP_PreW_46011","FourDCP_Spr_46011","FourDCP_PreW_46012",
                  "FourDCP_Spr_46012","CrsWnd_PreW_46025","CrsWnd_Spr_46025",
                  "CrsWnd_PreW_46011","CrsWnd_Spr_46011","CrsWnd_PreW_46012",
                  "CrsWnd_Spr_46012","BUI33N_PreW","BUI33N_Spring","Stability_all",
                  "Stability_nearshore", "PDO_PreW",
                  "PDO_Spring","LaJ_T_PreW","LaJ_T_Spring","TempAtDep_all",
                  "TempAtDep_nearshore", "SalAtDep_all", "SalAtDep_nearshore",
                  "O2AtDep_all", "O2AtDep_nearshore",
                  "ChlA_all", "ChlA_nearshore","Sml_P", "Euphausiids",
                  "Hake", "C_SeaLion","Albacore","Halibut","C_Murre",
                  "SoShWa","HBW","Hsquid", "FishLand","MktSqdCatch",
                  "Catch_Sard","Biom_Sard_Alec", "Msquid_CPUE", "Krill_CPUE", "Krill_mgCm2")
AdultExpvars <- c("A_Tot_B_Y.1", "MEI_Spring","NPGO_Spring","NPC_Str_Lat",
                  "SeaLevLA_Spring", "Ek_Spr_46025","FourDCP_Spr_46025",
                  "CrsWnd_Spr_46025","BUI33N_Spring",
                  "Stability_nearshore", "TempAtDep_nearshore", "SalAtDep_nearshore",
                  "O2AtDep_nearshore","ChlA_nearshore","Sml_P", "Euphausiids",
                  "Hake", "C_SeaLion","Albacore","Halibut","C_Murre",
                  "SoShWa","HBW","Hsquid", "FishLand","MktSqdCatch",
                  "Biom_Sard_Alec","Krill_Biom", "Msquid_CPUE", "Krill_CPUE")
AdultExpvars <- c("A_Tot_B_Y.1", "NPGO_Spring","Sml_P","C_SeaLion","Catch_Sard","Biom_Sard_Alec", "Krill_mgCm2")
AdultExpvarsCols <- match(AdultExpvars, names(Annual))


setwd("../")


#2.2 Larvae####
# 44 obs
# dir.create("Larvae")
setwd("Larvae")

gbm.auto(expvar = LarvalExpvarsCols,
         resvar = LarvalResvar,
         samples = LarvalSamples,
         lr = c(0.00001),
         bf = 0.8,
         ZI = F,
         fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = F)

# 2018.08.29 dataset size is too small or subsampling rate is too large: nTrain*bag.fraction <= n.minobsinnode
# changed bf to 0.8
# Error: $ operator is invalid for atomic vectors

LarvalExpvars <- c("Anch_Egg_Peak", "A_Tot_B", "O2AtDep_all","Biom_Sard_Alec")
LarvalExpvarsCols <- match(LarvalExpvars, names(Annual))
#from here####
# sort out peak resvar with peak expvars

setwd("../")
#2.3 Eggs####
#56 obs
# dir.create("Eggs")
setwd("Eggs")

gbm.auto(expvar = EggExpvarsCols,
         resvar = EggResvar,
         samples = EggSamples,
         lr = c(0.001),
         ZI = F,
         fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = F)

setwd("../")

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
# In any case we need to discuss and prune & agglomerate variables cos this is too much.
# Total biomass not resolving, fitting w 50 trees, broken, why.
 
# Erik's optimiser?

#3 whittle variables####
#3.1 pairplots####
# Do the massive pairplot analysis to see autocorrelated variables. They should
# be intuitively obvious anyway e.g. 20 wind variables!
# C:\Users\simon\Dropbox\Galway\Analysis\R\James' R code\pair_plots_with_panel_options.R
# shouldn't use colnumbers since they change, should use colnames. All below are wrong except o2 @ 2018.08.29
colnames(Annual)

pairs(Annual,
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# Error in plot.new() : figure margins too large
# too many variables. Split into sections
# 
pairs(Annual[c(14:17,20,22:23)], #large enviro indices THESE WILL BE WRONG IF CSV CHANGES
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables",
      cex.labels = 1.5)
# MEI_PreW vs Spring 0.95, vs SeaLevLAPreW 0.79 sealevspring 0.68
# MEI_Spring vs sealevprew 0.78, spring 0.74
# NPGO_PreW vs Spring 0.77
# NPGO_Spring
# NPC_Str_Lat
# SeaLevLA_PreW vs spring 0.80
# SeaLevLA_Spring
# 
# Choose EITHER spring OR winter AND NOT both.
# Start with spring (edited in section 3)

pairs(Annual[c(24:35,37:46)], #wind upwelling stability
lower.panel = panel.lm,
upper.panel = panel.cor,
diag.panel = panel.hist,
main = "pair plots of variables")
# Too small to see. Do subsets

pairs(Annual[c(24:29)], #Ekman transport only
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# Low correlations at same buoys winter/spring (0.41 max, otherwise 20s)
# Still use correct season though: use spring to start, section3
# High corr same season different buoys: 60 to 80. Only use one buoy? 25 is LA,
# 11 is SL Obispo. So only spring 25

# NA issue section####
cor(Annual$Sablefish, Annual$C_Sablefish)
# NA
cor(Annual$Sablefish, Annual$C_Sablefish, use = "complete.obs")
# 1. So I need to include complete.obs in the pairs. See James' script edit.
# 
mod <- lm(Ek_Spr_46025 ~ FourDCP_Spr_46025,  data = Annual)
# Coefficients:
#   (Intercept)  FourDCP_Spr_46025  
# 1816.9362            -0.7616
summary(mod)
# Residuals:
#   Min       1Q   Median       3Q      Max 
# -1520.83  -242.14    47.85   344.18   641.46 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept)       1816.9362   305.1203   5.955 9.86e-07 ***
#   FourDCP_Spr_46025   -0.7616     6.8052  -0.112    0.912    
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 499 on 34 degrees of freedom
# (32 observations deleted due to missingness)
# Multiple R-squared:  0.0003683,	Adjusted R-squared:  -0.02903 
# F-statistic: 0.01253 on 1 and 34 DF,  p-value: 0.9115
mod <- lm(Ek_Spr_46025 ~ CrsWnd_Spr_46025,  data = Annual)
# Coefficients:
#   (Intercept)  CrsWnd_Spr_46025  
# 1931.8             269.1  
summary(mod)
# Residuals:
#   Min       1Q   Median       3Q      Max 
# -1643.28  -275.92    32.82   346.80   671.58 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept)        1931.8      176.5  10.943  1.1e-12 ***
#   CrsWnd_Spr_46025    269.1      284.7   0.945    0.351    
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 492.6 on 34 degrees of freedom
# (32 observations deleted due to missingness)
# Multiple R-squared:  0.02561,	Adjusted R-squared:  -0.003044 
# F-statistic: 0.8938 on 1 and 34 DF,  p-value: 0.3511
mod <- lm(FourDCP_Spr_46025 ~ CrsWnd_Spr_46025,  data = Annual)
# Coefficients:
#   (Intercept)  CrsWnd_Spr_46025  
# 47.92              8.71  
summary(mod)
# Residuals:
#   Min      1Q  Median      3Q     Max 
# -30.747  -5.262   0.890   6.569  23.675 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept)        47.921      4.410  10.867 1.33e-12 ***
#   CrsWnd_Spr_46025    8.710      7.111   1.225    0.229    
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 12.31 on 34 degrees of freedom
# (32 observations deleted due to missingness)
# Multiple R-squared:  0.04227,	Adjusted R-squared:  0.0141 
# F-statistic:   1.5 on 1 and 34 DF,  p-value: 0.229

# Maybe they really ARE insignificant...
# Try the pair that came out as significant, MEI_PreW vs SeaLevLA_PreW
mod <- lm(MEI_PreW ~ SeaLevLA_PreW, data = Annual)
summary(mod)
# Residuals:
#   Min       1Q   Median       3Q      Max 
# -1.46905 -0.41892  0.00592  0.50229  1.49715 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept)   -0.16098    0.08598  -1.872   0.0656 .  
# SeaLevLA_PreW 15.18120    1.45681  10.421 1.41e-15 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 0.6799 on 66 degrees of freedom
# Multiple R-squared:  0.622,	Adjusted R-squared:  0.6163 
# F-statistic: 108.6 on 1 and 66 DF,  p-value: 1.405e-15

# Pairs() gives MEI_PreW vs SeaLevLA_PreW an R2 of 0.79, lm gives 0.622 / 0.6163

pairs(Annual[c(30:35,37:42)], #4DCP & CrsWnd
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# 4DCP winter & spring mostly strong correlations same buoy
# Not for CrsWnd. Strong corr same season all buoys esp spring
# Take Spring 25s

pairs(Annual[c(43:46)], #BUI & stability
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# Minimal correlations. Use BUI spring & stability inshore

colnames(Annual)
pairs(Annual[c(48:53)], #PDO & Temp
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# PDO_PreW vs LaJ_T_PreW 0.19 all else NA
# pdo prew spring 0.8
# LaJ temp prew spring 0.35
# PDO pring LaJ spring 0.74. Only use PDO spring? LaJ temp?
# LaJ spring t@d_all 0.65, t@d nearshore 0.68
# T@D nearshore vs all: 0.81
# Just use T@D nearshore, until/unless doing expansion/contraction

pairs(Annual[c(54:55)], #Sal
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# 0.89 use nearshore
 
colnames(Annual)
pairs(Annual[c(55:56)], #o2
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# 0.5 could use both, use nearshore for the time being

pairs(Annual[c(56:58,63,65)], #Plankton
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# chlA all/nearshore 0.89 use nearshore
# smallP largeP 0.59 keep both
# smalP euphausiids 0.46 keep both
# chlA all euphausiids 0.43

pairs(Annual[c(66:75,77:79,82:88,90:93)], #Predators & fishery landings
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# corr=1 for hake/Chake, sablefish, salmon, halibut, SOSH, HBW, Hsquid.
# Fine, not using both concurrently.
# Check FishLand vs anchovy metrics

pairs(Annual[c(5:11,92)], #Anchovy & landings
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# Error in cor.test.default(x, y) : not enough finite observations c(5:13,92)
# Remove ATM
# E&L 0.67
# E & AtotB 0.9 y-1 0.46
# L & AtotB 0.72
# Fishland correlated w/ JCB but nowt else
# AtotB & y-1 0.63 

pairs(Annual[c(56:65,100)], #plankton vs krill
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# krill 0.4 to 0.5 w/ others. Include.

pairs(Annual[c(92,94:96)], #sardine
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# alec & andre 0.98 use 1 Alec
# Alec vs catch 0.62 use Alec or both? Alec.

#DO KRILL PAIRPLOTS####

#3.2 lm plots####
source(paste0(machine, '/simon/Dropbox/Galway/Analysis/R/My Misc Scripts/LinearModelPlot.R')) # load my lm plotting function
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/"))
dir.create("lm plots")
setwd("lm plots")
dir.create("Adults")
setwd("Adults")
# loop through all expvars against resvar:
# Adults
for(i in 1:length(AdultExpvars)){
lmplot(x = Annual[,AdultExpvars[i]],
       y = Annual[,AdultResvar],
       xname = AdultExpvars[i],
       yname = AdultResvar)
}
setwd("../")
dir.create("Larvae")
setwd("Larvae")

# Larvae
for(i in 1:length(LarvalExpvars)){
  lmplot(x = Annual[,LarvalExpvars[i]],
         y = Annual[,LarvalResvar],
         xname = LarvalExpvars[i],
         yname = LarvalResvar)
}
setwd("../")
dir.create("Eggs")
setwd("Eggs")

# Eggs
for(i in 1:length(EggExpvars)){
  lmplot(x = Annual[,EggExpvars[i]],
         y = Annual[,EggResvar],
         xname = EggExpvars[i],
         yname = EggResvar)
}
setwd("../")

#3.3 Adult vars####
# Report: training data correlation 0.678, simp 0.661, simp dropped A_Tot_B_Y.1
# & Biom_Sard_Alec which were the most important variables! Sard 46% inf,
# totBy-1 25%. Weird. Labels are wrong it's other way round, changed in gbmauto

AdultResvar <- "A_Tot_B"
AdultExpvars <- c("A_Tot_B_Y.1", "MEI_Spring","NPGO_Spring","NPC_Str_Lat",
                  "SeaLevLA_Spring", "Ek_Spr_46025","FourDCP_Spr_46025",
                  "CrsWnd_Spr_46025","BUI33N_Spring",
                  "Stability_nearshore", "TempAtDep_nearshore", "SalAtDep_nearshore",
                  "O2AtDep_nearshore","ChlA_nearshore","Sml_P", "Euphausiids",
                  "Hake", "C_SeaLion","Albacore","Halibut","C_Murre",
                  "SoShWa","HBW","Hsquid", "FishLand","MktSqdCatch",
                  "Biom_Sard_Alec","Krill_Biom", "Msquid_CPUE", "Krill_CPUE")

#3.4 larvae vars####
LarvalResvar <- "Anch_Larvae"
LarvalExpvars <- c("Anch_Egg", "A_Tot_B", "MEI_Spring",
                   "NPGO_Spring","NPC_Str_Lat","SeaLevLA_Spring",
                   "Ek_Spr_46025","FourDCP_Spr_46025","CrsWnd_PreW_46025","BUI33N_Spring",
                   "Stability_nearshore", "TempAtDep_nearshore", "SalAtDep_nearshore",
                   "O2AtDep_nearshore","ChlA_nearshore","Sml_P", "Lrg_P",
                   "Hake", "Jmac", "Cmac", "Biom_Sard_Alec","Krill_Biom", "Krill_CPUE")

#3.5 egg vars####
EggResvar <- "Anch_Egg"
EggExpvars <- c("A_Tot_B", "MEI_Spring",
                "NPGO_Spring","NPC_Str_Lat","SeaLevLA_Spring",
                "Ek_Spr_46025", "FourDCP_Spr_46025","CrsWnd_Spr_46025",
                "BUI33N_Spring",
                "Stability_nearshore",
                "TempAtDep_nearshore", "SalAtDep_nearshore",
                "O2AtDep_nearshore",
                "Lrg_P", "Hake", "Jmac", "Cmac", "Biom_Sard_Alec","Krill_Biom", "Krill_CPUE")

AdultResvarCol <- match(AdultResvar, names(Annual))
AdultExpvarsCols <- match(AdultExpvars, names(Annual))
LarvalResvarCol <- match(LarvalResvar, names(Annual))
LarvalExpvarsCols <- match(LarvalExpvars, names(Annual))
EggResvarCol <- match(EggResvar, names(Annual))
EggExpvarsCols <- match(EggExpvars, names(Annual))

# remove NA rows
AdultSamples <- Annual[-which(is.na(Annual[AdultResvar])),]
LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]

#4 ReRun code w fewer vars####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/"))

#4.1 Adults####
# 57 obs
# dir.create("AdultsTrim")
setwd("AdultsTrim")

gbm.auto(expvar = AdultExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamples,
         lr = c(0.000001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F,
         n.trees = 10)
# 2018.08.29 crashing Rstudio

setwd("../")
# 57 pos samples
# variance?
var(AdultSamples$A_Tot_B) # 344,835,667,976 variance 1/3rd of a trillion. Cool cool cool
# why is it not running? what's so different about Adults to e&l? why are there 9 fewer values?
# e&l have zeroes which are nonsamples which need to be removed. Need to rerun e&l now, ugh

#4.2 Larvae####
# 44 obs
# dir.create("LarvaeTrim")
setwd("LarvaeTrim")

# gbm.auto(expvar = LarvalExpvarsCols,
#          resvar = LarvalResvar,
#          samples = LarvalSamples,
#          lr = c(0.00000001),
#          bf = 0.9,
#          ZI = F,
#          #fam1 = "gaussian",
#          savegbm = FALSE,
#          BnW = FALSE,
#          simp = F,
#          multiplot = F,
#          varint = F,
#          n.trees = 10)
# no zeroes error but fam is gaussian... nozeroes error expects delta model?
# doesn't stop the code run though,
#FIXTHISLATER####
# Error: $ operator is invalid for atomic vectors
# traceback cites simp & predictgrids but grids is absent so null? turning off simp first
# works but
# In cor(y_i, u_i) : the standard deviation is zero. Need to remove A_tot_B. See below

setwd("../")

# Best Gaussian BRT variables   Relative Influence (Gaus)
# A_Tot_B                       49.24120366
# Sml_P                         18.82757641
# SalAtDep_nearshore            9.452383789
# Jmac                          8.741637677
# Anch_Egg                      2.459264498
# Krill_Biom            	      2.398926646
# TempAtDep_nearshore	          1.963355915
# Lrg_P	                        1.518654535
# Stability_nearshore	          1.423158171
# (12 others w <1% inf)
# Should remove A_Tot_B since Y0 larvae creates Y0 A_tot_B
# 
# Sml_P	              28.0135335
# Anch_Egg	          26.1304018
# SalAtDep_nearshore	11.25056136
# Biom_Sard_Alec	    6.567140269
# Jmac	              6.044858377
# Krill_Biom	        5.379942142
# Lrg_P	              3.388376356
# TempAtDep_nearshore	2.540202583
# NPGO_Spring	        2.472411227
# Hake	              1.899457379
# BUI33N_Spring	      1.879355896
# Stability_nearshore	1.716456806
# SeaLevLA_Spring	    1.31849548
# MEI_Spring	        1.233327213
# TD corr 0.95. W/ only egg & small P: 0.93
# Can I use EGG though? Comes from same sampling cruise...

# W/o egg:
# Sml_P	              36.36086168
# Jmac	              16.53595799
# SalAtDep_nearshore	14.22483102
# Krill_Biom	        6.418533237
# Biom_Sard_Alec	    5.964824738
# TempAtDep_nearshore	5.190620222
# Lrg_P	              3.652048839
# Stability_nearshore	2.973981289
# NPGO_Spring	        2.577117017
# SeaLevLA_Spring	    1.970287548
# BUI33N_Spring	      1.912410975
# Hake	              1.473703115
# 
# CrsWnd, Ek, 4DCP all irrelevant, NPC ditto. Stability's in there, ditto temp & sal @ depth



LarvalExpvars <- c("MEI_Spring", "NPGO_Spring","NPC_Str_Lat",
                  "SeaLevLA_Spring","Ek_Spr_46025","FourDCP_Spr_46025",
                  "CrsWnd_PreW_46025","BUI33N_Spring","Stability_nearshore",
                  "TempAtDep_nearshore", "SalAtDep_nearshore",
                  "O2AtDep_nearshore","ChlA_nearshore","Sml_P", "Lrg_P","Hake", "Jmac", "Cmac",
                  "Biom_Sard_Alec","Krill_Biom", "Krill_CPUE")
LarvalExpvarsCols <- match(LarvalExpvars, names(Annual))

gbm.auto(expvar = LarvalExpvarsCols,
         resvar = LarvalResvar,
         samples = LarvalSamples,
         lr = c(0.00000001),
         bf = 0.9,
         ZI = F,
         #fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = F,
         n.trees = 10)
# works, still no deviance change though. Sard is the big deal. Do gbm.loop
setwd("../")

#4.3 Eggs####
#dir.create("EggsTrim")
setwd("EggsTrim")

EggExpvars <- c("MEI_Spring","NPGO_Spring","NPC_Str_Lat","SeaLevLA_Spring",
                "Ek_Spr_46025", "FourDCP_Spr_46025","CrsWnd_Spr_46025",
                "BUI33N_Spring","Stability_nearshore","TempAtDep_nearshore",
                "O2AtDep_nearshore","SalAtDep_nearshore","Lrg_P", "Hake", "Jmac", "Cmac",
                "Biom_Sard_Alec","Krill_Biom", "Krill_CPUE")
EggExpvarsCols <- match(EggExpvars, names(Annual))

gbm.auto(expvar = EggExpvarsCols,
         resvar = EggResvar,
         samples = EggSamples,
         lr = c(0.001),
         ZI = F,
         #fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = F)

# Run loop in case.

setwd("../")
