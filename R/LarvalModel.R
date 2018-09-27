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
Annual <- read.csv(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Data Structure Template 2018.09.24.csv'),
                   na.strings = "")
# Annual <- Annual[5:nrow(Annual),] # Trim first 4 rows. Now done beforehand so data columns aren't imported as factors
# clip off dud rows year 2018 & beyond if present
Annual <- Annual[1:(match(2017, Annual$Year)),]


colnames(Annual)
## dud columns: 
# 60: Jack mackerel, too few data, insufficient variation
# 65,67:69,71: chinook salmon, common murre, sooty shearwater, short beaked common dolphin, humboldt squid: currently empty, remove from list later
# 73,74,78,80,82,84 : Consumpton by jack, pacific mackerel, chinook salmon, common murre, short beaked common dolphin, humboldt squid: currently empty, remove from list later. Jack has data but too few.

#Select named goodcols####
AdultResvar <- "A_Tot_B"
AdultExpvars <- c("A_Tot_B_Y.1", "MEI_PreW", "MEI_Spring", "NPGO_PreW",
                  "NPGO_Spring","NPC_Str_Lat", "SeaLevLA_PreW","SeaLevLA_Spring",
                  "SeaLevSF_PreW", "SeaLevSF_Spring",
                  "Ek_PreW_46025","Ek_Spr_46025", "Ek_PreW_46011","Ek_Spr_46011",
                  "Ek_PreW_46012", "Ek_Spr_46012","FourDCP_PreW_46025","FourDCP_Spr_46025",
                  "FourDCP_PreW_46011","FourDCP_Spr_46011","FourDCP_PreW_46012",
                  "FourDCP_Spr_46012","CrsWnd_PreW_46025","CrsWnd_Spr_46025",
                  "CrsWnd_PreW_46011","CrsWnd_Spr_46011","CrsWnd_PreW_46012",
                  "CrsWnd_Spr_46012","BUI33N_PreW","BUI33N_Spring","Stability_all",
                  "Stab_CentCal", "Stab_Nearsh", "Stab_NCoast", "Stab_Offsh", "Stab_South", "Stab_Transition",
                  "PDO_PreW","PDO_Spring","LaJ_T_PreW","LaJ_T_Spring","TempAtDep_all",
                  "Temp_CentCal", "Temp_Nearsh", "Temp_NCoast", "Temp_Offsh", "Temp_South", "Temp_Transition",
                  "SalAtDep_all",
                  "Sal_CentCal", "Sal_Nearsh", "Sal_NCoast", "Sal_Offsh", "Sal_South", "Sal_Transition",
                  "O2AtDep_all", 
                  "O2_CentCal", "O2_Nearsh", "O2_NCoast", "O2_Offsh", "O2_South", "O2_Transition",
                  "ChlA_all",
                  "ChlA_CentCal", "ChlA_Nearsh", "ChlA_NCoast", "ChlA_Offsh", "ChlA_South", "ChlA_Transition",
                  "Sml_P", "Euphausiids",
                  "Hake", "C_SeaLion","Albacore","Halibut","C_Murre",
                  "SoShWa","HBW","Hsquid", "FishLand","MktSqdCatch",
                  "Catch_Sard","Biom_Sard_Alec", "Msquid_CPUE", "Krill_CPUE", "Krill_mgCm2")

LarvalResvar <- "Anch_Larvae_Peak"
LarvalExpvars <- c("Anch_Egg_Peak", "A_Tot_B", "MEI_PreW", "MEI_Spring", "NPGO_PreW",
                  "NPGO_Spring","NPC_Str_Lat", "SeaLevLA_PreW","SeaLevLA_Spring",
                  "SeaLevSF_PreW", "SeaLevSF_Spring",
                  "Ek_PreW_46025","Ek_Spr_46025", "Ek_PreW_46011","Ek_Spr_46011",
                  "Ek_PreW_46012", "Ek_Spr_46012","FourDCP_PreW_46025","FourDCP_Spr_46025",
                  "FourDCP_PreW_46011","FourDCP_Spr_46011","FourDCP_PreW_46012",
                  "FourDCP_Spr_46012","CrsWnd_PreW_46025","CrsWnd_Spr_46025",
                  "CrsWnd_PreW_46011","CrsWnd_Spr_46011","CrsWnd_PreW_46012",
                  "CrsWnd_Spr_46012","BUI33N_PreW","BUI33N_Spring","Stability_all",
                  "Stab_CentCal", "Stab_Nearsh", "Stab_NCoast", "Stab_Offsh", "Stab_South", "Stab_Transition",
                  "PDO_PreW","PDO_Spring","LaJ_T_PreW","LaJ_T_Spring","TempAtDep_all",
                  "Temp_CentCal", "Temp_Nearsh", "Temp_NCoast", "Temp_Offsh", "Temp_South", "Temp_Transition",
                  "SalAtDep_all",
                  "Sal_CentCal", "Sal_Nearsh", "Sal_NCoast", "Sal_Offsh", "Sal_South", "Sal_Transition",
                  "O2AtDep_all", 
                  "O2_CentCal", "O2_Nearsh", "O2_NCoast", "O2_Offsh", "O2_South", "O2_Transition",
                  "ChlA_all",
                  "ChlA_CentCal", "ChlA_Nearsh", "ChlA_NCoast", "ChlA_Offsh", "ChlA_South", "ChlA_Transition",
                  "Sml_P", "Lrg_P",
                  "Hake", "Jmac", "Cmac", "CmacAd", "Catch_Sard","Biom_Sard_Alec", "Krill_CPUE", "Krill_mgCm2")

EggResvar <- "Anch_Egg_Peak"
EggExpvars <- c("A_Tot_B", "MEI_PreW", "MEI_Spring", "NPGO_PreW",
                "NPGO_Spring","NPC_Str_Lat", "SeaLevLA_PreW","SeaLevLA_Spring",
                "SeaLevSF_PreW", "SeaLevSF_Spring",
                "Ek_PreW_46025","Ek_Spr_46025", "Ek_PreW_46011","Ek_Spr_46011",
                "Ek_PreW_46012", "Ek_Spr_46012","FourDCP_PreW_46025","FourDCP_Spr_46025",
                "FourDCP_PreW_46011","FourDCP_Spr_46011","FourDCP_PreW_46012",
                "FourDCP_Spr_46012","CrsWnd_PreW_46025","CrsWnd_Spr_46025",
                "CrsWnd_PreW_46011","CrsWnd_Spr_46011","CrsWnd_PreW_46012",
                "CrsWnd_Spr_46012","BUI33N_PreW","BUI33N_Spring","Stability_all",
                "Stab_CentCal", "Stab_Nearsh", "Stab_NCoast", "Stab_Offsh", "Stab_South", "Stab_Transition",
                "PDO_PreW","PDO_Spring","LaJ_T_PreW","LaJ_T_Spring","TempAtDep_all",
                "Temp_CentCal", "Temp_Nearsh", "Temp_NCoast", "Temp_Offsh", "Temp_South", "Temp_Transition",
                "SalAtDep_all",
                "Sal_CentCal", "Sal_Nearsh", "Sal_NCoast", "Sal_Offsh", "Sal_South", "Sal_Transition",
                "O2AtDep_all", 
                "O2_CentCal", "O2_Nearsh", "O2_NCoast", "O2_Offsh", "O2_South", "O2_Transition",
                "Lrg_P",
                "Hake", "Jmac", "Cmac", "CmacAd",
                "Catch_Sard","Biom_Sard_Alec",
                "Krill_CPUE", "Krill_mgCm2")

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
# use colnames as colnumbers change. All colnumbers below likely wrong except o2 @ 2018.08.29
colnames(Annual)

pairs(Annual,
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# Error in plot.new() : figure margins too large
# too many variables. Split into sections
# 
pairs(Annual[c(14:17,20,22:23)], #large enviro indices
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

# NA issue, now fixed by correct pairplot order? ignore unless happens again
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

#krill####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/PairPlots"))
colnames(Annual)
KrillExpvars <- c("Krill_Biom", "Krill_CPUE", "Krill_mgCm2")
KrillExpvarsCols <- match(KrillExpvars, names(Annual))
source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/pairPlots.R"))
pairs(Annual[KrillExpvarsCols], #krill
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# biom = mgCm2, r=1 remove biom
KrillExpvars <- c("Krill_CPUE", "Krill_mgCm2")
KrillExpvarsCols <- match(KrillExpvars, names(Annual))

setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/KrillPrune"))
#adults
gbm.auto(expvar = KrillExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# cpue 0 mgcm2 100

#larvae
gbm.auto(expvar = KrillExpvarsCols,
         resvar = LarvalResvarCol,
         samples = LarvalSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# cpue 0 mgcm2 100

#egg
gbm.auto(expvar = KrillExpvarsCols,
         resvar = EggResvarCol,
         samples = EggSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# cpue 0 mgcm2 100
#average: # cpue 0 mgcm2 100
#ditch cpue

#regional pairs####
# stability
colnames(Annual)
StabExpvars <- c("Stability_all",
                 "Stab_CentCal",
                 "Stab_Nearsh",
                 "Stab_NCoast",
                 "Stab_Offsh",
                 "Stab_South",
                 "Stab_Transition")
StabExpvarsExpvarsCols <- match(StabExpvars, names(Annual))
pairs(Annual[StabExpvarsExpvarsCols], #stab
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# temp
TempExpvars <- c("TempAtDep_all",
                 "Temp_CentCal",
                 "Temp_Nearsh",
                 "Temp_NCoast",
                 "Temp_Offsh",
                 "Temp_South",
                 "Temp_Transition")
TempExpvarsExpvarsCols <- match(TempExpvars, names(Annual))
pairs(Annual[TempExpvarsExpvarsCols], #temp
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# sal
SalExpvars <- c("SalAtDep_all",
                "Sal_CentCal",
                "Sal_Nearsh",
                "Sal_NCoast",
                "Sal_Offsh",
                "Sal_South",
                "Sal_Transition")
SalExpvarsExpvarsCols <- match(SalExpvars, names(Annual))
pairs(Annual[SalExpvarsExpvarsCols], #Sal
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# o2
O2Expvars <- c("O2AtDep_all",
               "O2_CentCal",
               "O2_Nearsh",
               "O2_NCoast",
               "O2_Offsh",
               "O2_South",
               "O2_Transition")
O2ExpvarsExpvarsCols <- match(O2Expvars, names(Annual))
pairs(Annual[O2ExpvarsExpvarsCols], #O2
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# chlA
ChlAExpvars <- c("ChlA_all",
                 "ChlA_CentCal",
                 "ChlA_Nearsh",
                 "ChlA_NCoast",
                 "ChlA_Offsh",
                 "ChlA_South",
                 "ChlA_Transition")
ChlAExpvarsExpvarsCols <- match(ChlAExpvars, names(Annual))
pairs(Annual[ChlAExpvarsExpvarsCols], #ChlA
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")

#regional results####
# stab temp sal o2 chlA
# stab: all/south all/off all/trans
#       centCal/NCoast
#       offsh/south offsh/trans
#       south/trans
# > Ditch trans? Do BRTs first, which are best, then ditch their collinears.
# 
# temp: all/all except ncoast
#       centcal/ncoast
#       nearsho/south & trans
#       offsh/south & trans
#       south/trans
#
# sal: all collinear
#
# o2: all ~30:60 colinear, all/trans, all/off & off/trans most colinear. Maybe trans is the key?
# 
# chlA: all/cent all/near all/trans near/south

#regional BRTs####
StabExpvarsCols <- match(StabExpvars, names(Annual))
TempExpvarsCols <- match(TempExpvars, names(Annual))
SalExpvarsCols <- match(SalExpvars, names(Annual))
O2ExpvarsCols <- match(O2Expvars, names(Annual))
ChlAExpvarsCols <- match(ChlAExpvars, names(Annual))
AdultResvar <- "A_Tot_B"
LarvalResvar <- "Anch_Larvae_Peak"
EggResvar <- "Anch_Egg_Peak"
AdultResvarCol <- match(AdultResvar, names(Annual))
LarvalResvarCol <- match(LarvalResvar, names(Annual))
EggResvarCol <- match(EggResvar, names(Annual))
AdultSamples <- Annual[-which(is.na(Annual[AdultResvar])),]
LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/RegionsPrune"))
#adults
setwd("Stability")
gbm.auto(expvar = StabExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# all ncoast offshore good
setwd("../Temperature")
gbm.auto(expvar = TempExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# ncoast massive
setwd("../Salinity")
gbm.auto(expvar = SalExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# ncoast south offshore good
setwd("../O2")
gbm.auto(expvar = O2ExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# offshore massive, then ncoast, south
setwd("../ChlA")
gbm.auto(expvar = ChlAExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# nearshore, south

#larvae
setwd("../Stability")
gbm.auto(expvar = StabExpvarsCols,
         resvar = LarvalResvarCol,
         samples = LarvalSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# south massive then transition
setwd("../Temperature")
gbm.auto(expvar = TempExpvarsCols,
         resvar = LarvalResvarCol,
         samples = LarvalSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# south massive then trans a bit
setwd("../Salinity")
gbm.auto(expvar = SalExpvarsCols,
         resvar = LarvalResvarCol,
         samples = LarvalSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# ditto
setwd("../O2")
gbm.auto(expvar = O2ExpvarsCols,
         resvar = LarvalResvarCol,
         samples = LarvalSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# all & offshore
setwd("../ChlA")
gbm.auto(expvar = ChlAExpvarsCols,
         resvar = LarvalResvarCol,
         samples = LarvalSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# all

#eggs
setwd("../Stability")
gbm.auto(expvar = StabExpvarsCols,
         resvar = EggResvarCol,
         samples = EggSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# south trans
setwd("../Temperature")
gbm.auto(expvar = TempExpvarsCols,
         resvar = EggResvarCol,
         samples = EggSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# south massive then near a bit
setwd("../Salinity")
gbm.auto(expvar = SalExpvarsCols,
         resvar = EggResvarCol,
         samples = EggSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# ditto
setwd("../O2")
gbm.auto(expvar = O2ExpvarsCols,
         resvar = EggResvarCol,
         samples = EggSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# all & trans
setwd("../ChlA")
gbm.auto(expvar = ChlAExpvarsCols,
         resvar = EggResvarCol,
         samples = EggSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# dead

#Bill/Sol Big6 pairs####
Big6Expvars <- c("BUI33N_Spring", "Temp_South", "PDO_Spring", "SeaLevLA_Spring", "MEI_Spring", "Biom_Sard_Alec")
Big6ExpvarsCols <- match(Big6Expvars, names(Annual))
source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/pairPlots.R"))
pairs(Annual[Big6ExpvarsCols], #big6
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# temp & PDO colinear, remove PDO
# SeaLevel & MEI ditto, remove MEI


#wind/upwel/stab pairs####
WindExpvars <- c("Ek_Spr_46025", "FourDCP_Spr_46025", "CrsWnd_Spr_46025", "BUI33N_Spring", "Stab_South")
WindExpvarsCols <- match(WindExpvars, names(Annual))
source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/pairPlots.R"))
pairs(Annual[WindExpvarsCols], #wind
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/WindUpwellingPrune"))
WindExpvarsCols <- match(WindExpvars, names(AdultSamples))
gbm.auto(expvar = WindExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
gbm.auto(expvar = WindExpvarsCols,
         resvar = LarvalResvarCol,
         samples = LarvalSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
gbm.auto(expvar = WindExpvarsCols,
         resvar = EggResvarCol,
         samples = EggSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# 

#stab/temp/MEI/PDO pairs####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/PairPlots"))
colnames(Annual)
Big4Expvars <- c("Stab_South", "Temp_South", "MEI_Spring", "PDO_Spring")
Big4ExpvarsCols <- match(Big4Expvars, names(Annual))
source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/pairPlots.R"))
pairs(Annual[Big4ExpvarsCols], #big4
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# (from big6 notes) temp & PDO colinear, remove PDO
# Stab & temp colinear

#stab/temp/MEI/PDO brts####
Big4ExpvarsCols <- match(Big4Expvars, names(Annual))
AdultResvar <- "A_Tot_B"
LarvalResvar <- "Anch_Larvae_Peak"
EggResvar <- "Anch_Egg_Peak"
AdultResvarCol <- match(AdultResvar, names(Annual))
LarvalResvarCol <- match(LarvalResvar, names(Annual))
EggResvarCol <- match(EggResvar, names(Annual))
AdultSamples <- Annual[-which(is.na(Annual[AdultResvar])),]
LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/Big4Prune"))
#adults
gbm.auto(expvar = Big4ExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# stab south 38% temp 8%

#larvae
gbm.auto(expvar = Big4ExpvarsCols,
         resvar = LarvalResvarCol,
         samples = LarvalSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# stab south 14% temp 11%

#egg
gbm.auto(expvar = Big4ExpvarsCols,
         resvar = EggResvarCol,
         samples = EggSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# stab south 36% temp 23%
#average: stab south 29% temp 14%

#hake vs hake_biom####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/PairPlots"))
colnames(Annual)
HakeExpvars <- c("Hake", "Hake_Biom")
HakeExpvarsCols <- match(HakeExpvars, names(Annual))
source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/pairPlots.R"))
pairs(Annual[HakeExpvars], #hake
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# colinear r=0.87
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/HakePrune"))
#adults
gbm.auto(expvar = HakeExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# biom 68 hake 32

#larvae
gbm.auto(expvar = HakeExpvarsCols,
         resvar = LarvalResvarCol,
         samples = LarvalSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# biom 4 hake 96

#egg
gbm.auto(expvar = HakeExpvarsCols,
         resvar = EggResvarCol,
         samples = EggSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# biom 13 hake 87
#average: # biom 28 hake 72
#ditch hake_biom

#msquid####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/PairPlots"))
colnames(Annual)
MSquidExpvars <- c("MktSqdCatch", "Msquid_Biom", "Msquid_CPUE")
MSquidExpvarsCols <- match(MSquidExpvars, names(Annual))
source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/pairPlots.R"))
pairs(Annual[MSquidExpvars], #msquid
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# MktSqdCatch r=0.48 vs Msquid_Biom, 0.32 vs Msquid_CPUE
# Msquid_Biom r=0.01 vs Msquid_CPUE
# Ditch MktSqdCatch as medium colinear w/ both others?

setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/MSquidPrune"))
#adults
gbm.auto(expvar = MSquidExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# biom 98 catch 2 cpue 0

#larvae
gbm.auto(expvar = MSquidExpvarsCols,
         resvar = LarvalResvarCol,
         samples = LarvalSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# biom 58 catch 42 cpue 0

#egg
gbm.auto(expvar = MSquidExpvarsCols,
         resvar = EggResvarCol,
         samples = EggSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# biom 34 catch 66 cpue 0
#average: biom 63 catch 37 cpue 0
#ditch CPUE. Ditch catch: half the influence and half colinear, logically less relevant

#sard####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/PairPlots"))
colnames(Annual)
SardExpvars <- c("Catch_Sard", "Biom_Sard_Alec", "Biom_Sard_Andre")
SardExpvarsCols <- match(SardExpvars, names(Annual))
source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/pairPlots.R"))
pairs(Annual[SardExpvars], #Sard
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# Catch_Sard r=0.62 vs Biom_Sard_Alec, 0.57 vs Biom_Sard_Andre
# Biom_Sard_Alec r=0.98 vs Biom_Sard_Andre

setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/SardPrune"))
#adults
gbm.auto(expvar = SardExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# catch 2 alec 72 andre 26

#larvae
gbm.auto(expvar = SardExpvarsCols,
         resvar = LarvalResvarCol,
         samples = LarvalSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# catch 65 alec 23 andre 13

#egg
gbm.auto(expvar = SardExpvarsCols,
         resvar = EggResvarCol,
         samples = EggSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# catch 73 alec 16 andre 11
#average: # catch 47 alec 37 andre 16
#ditch Andre. Ditch catch: half the influence and half colinear, logically less relevant


#sealevel####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/PairPlots"))
colnames(Annual)
SeaLevExpvars <- c("SeaLevLA_PreW", "SeaLevLA_Spring", "SeaLevSF_PreW", "SeaLevSF_Spring")
SeaLevExpvarsCols <- match(SeaLevExpvars, names(Annual))
source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/pairPlots.R"))
pairs(Annual[SeaLevExpvarsCols],
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# LAprew: spring 0.8, SFpreW 0.84 SFspr 0.61
# LAspr: SFpreW 0.63 SFspr 0.79
# SFpreW : spr 0.58
# Loads of colinearity, only want 1.
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/SeaLevPrune"))
#adults
gbm.auto(expvar = SeaLevExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# LAp 39 LAs 19 SFp 31 SFs 13

#larvae
gbm.auto(expvar = SeaLevExpvarsCols,
         resvar = LarvalResvarCol,
         samples = LarvalSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# LAp 23 LAs 21 SFp 15 SFs 41

#egg
gbm.auto(expvar = SeaLevExpvarsCols,
         resvar = EggResvarCol,
         samples = EggSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# LAp 2 LAs 42 SFp 35 SFs 21
#average: LAp 21 LAs 27 SFp 27 SFs 25 all fairly even
#individual bests: adults LAp, larvae SFs eggs SFp

#Cmac CmacAd####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/PairPlots"))
colnames(Annual)
CmacExpvars <- c("Cmac", "CmacAd")
CmacExpvarsCols <- match(CmacExpvars, names(Annual))
source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/pairPlots.R"))
pairs(Annual[CmacExpvars], #hake
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
# colinear r=0.87
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/CmacPrune"))
#adults
gbm.auto(expvar = CmacExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# cmac 100 cmacad 0

#larvae
gbm.auto(expvar = CmacExpvarsCols,
         resvar = LarvalResvarCol,
         samples = LarvalSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# cmac 95 cmacad 5

#egg
gbm.auto(expvar = CmacExpvarsCols,
         resvar = EggResvarCol,
         samples = EggSamples,
         lr = c(0.0001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         #simp = T,
         simp = F,
         multiplot = F,
         varint = F)
# cmac 81 cmacad 19
#average: # cmac 92 cmacad 8
#CmacAd




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

#4 Whittled variables BRTs####
# updated 2018.09.24
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/"))
dir.create("2018.09.24")
setwd("2018.09.24")

#4.1 Adult vars####
AdultResvar <- "A_Tot_B"
AdultResvarCol <- match(AdultResvar, names(Annual))
AdultSamples <- Annual[-which(is.na(Annual[AdultResvar])),] # remove NA rows
AdultExpvars <- c("A_Tot_B_Y.1",
                  "NPGO_Spring",
                  "NPC_Str_Lat",
                  "SeaLevLA_PreW",
                  "BUI33N_Spring",
                  "Stab_South",
                  "Temp_South",
                  "Sal_South",
                  "O2AtDep_all",
                  "ChlA_all",
                  "Sml_P",
                  "Euphausiids",
                  "Albacore",
                  "Sablefish",
                  "ChinSal",
                  "Halibut",
                  "SoShWa",
                  "HBW",
                  "Hsquid",
                  "C_SeaLion",
                  "C_Murre",
                  "FishLand",
                  "Biom_Sard_Alec",
                  "Hake_Biom",
                  "Msquid_Biom",
                  "Rockfish_Biom",
                  "Krill_mgCm2")
AdultExpvarsCols <- match(AdultExpvars, names(Annual))
gbm.auto(expvar = AdultExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamples,
         lr = c(0.000001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = F)
#n.trees = 10)

#4.2 larvae vars####
LarvalResvar <- "Anch_Larvae_Peak"
LarvalResvarCol <- match(LarvalResvar, names(Annual))
LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
LarvalExpvars <- c("A_Tot_B_Y.1",
                   "NPGO_Spring",
                   "NPC_Str_Lat",
                   "SeaLevSF_Spring",
                   "BUI33N_Spring",
                   "Stab_South",
                   "Temp_South",
                   "Sal_South",
                   "O2AtDep_all",
                   "ChlA_all",
                   "Sml_P", "Lrg_P",
                   "Hake", "Jmac", "Cmac",
                   "Catch_Sard",
                   "Msquid_Biom",
                   "Rockfish_Biom",
                   "Krill_mgCm2")
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
         simp = F, #simp fails & crashes
         multiplot = F,
         varint = F)
#n.trees = 10)

LarvalResvar <- "Anch_Larvae_PreW"
LarvalResvarCol <- match(LarvalResvar, names(Annual))
LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
LarvalExpvars <- c("A_Tot_B_Y.1",
                   "NPGO_PreW",
                   "NPC_Str_Lat",
                   "SeaLevSF_PreW",
                   "BUI33N_PreW",
                   "Stab_South",
                   "Temp_South",
                   "Sal_South",
                   "O2AtDep_all",
                   "ChlA_all",
                   "Sml_P", "Lrg_P",
                   "Hake", "Jmac", "Cmac",
                   "Catch_Sard",
                   "Msquid_Biom",
                   "Rockfish_Biom",
                   "Krill_mgCm2")
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
         simp = T,
         multiplot = F,
         varint = F)
#n.trees = 10)

LarvalResvar <- "Anch_Larvae_Spring"
LarvalResvarCol <- match(LarvalResvar, names(Annual))
LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
LarvalExpvars <- c("Anch_Egg_PreW",
                   "Anch_Larvae_PreW",
                   "A_Tot_B_Y.1",
                   "NPGO_Spring",
                   "NPC_Str_Lat",
                   "SeaLevSF_Spring",
                   "BUI33N_Spring",
                   "Stab_South",
                   "Temp_South",
                   "Sal_South",
                   "O2AtDep_all",
                   "ChlA_all",
                   "Sml_P", "Lrg_P",
                   "Hake", "Jmac", "Cmac",
                   "Catch_Sard",
                   "Msquid_Biom",
                   "Rockfish_Biom",
                   "Krill_mgCm2")
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
         simp = T,
         multiplot = F,
         varint = F)
#n.trees = 10)
#simp oddity####
# simplifying is better & there are loads of 0INF vars but they're not dropped?
#4.3 egg vars####
EggResvar <- "Anch_Egg_Peak"
EggResvarCol <- match(EggResvar, names(Annual))
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]
EggExpvars <- c("A_Tot_B_Y.1",
                "NPGO_Spring",
                "NPC_Str_Lat",
                "SeaLevSF_PreW",
                "BUI33N_Spring",
                "Stab_South",
                "Temp_South",
                "Sal_South",
                "O2AtDep_all",
                "Lrg_P",
                "Hake", "Jmac", "Cmac",
                "Catch_Sard",
                "Msquid_Biom",
                "Rockfish_Biom",
                "Krill_mgCm2")
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

EggResvar <- "Anch_Egg_PreW"
EggResvarCol <- match(EggResvar, names(Annual))
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]
EggExpvars <- c("A_Tot_B_Y.1",
                "NPGO_PreW",
                "NPC_Str_Lat",
                "SeaLevSF_PreW",
                "BUI33N_PreW",
                "Stab_South",
                "Temp_South",
                "Sal_South",
                "O2AtDep_all",
                "Lrg_P",
                "Hake", "Jmac", "Cmac",
                "Catch_Sard",
                "Msquid_Biom",
                "Rockfish_Biom",
                "Krill_mgCm2")
EggExpvarsCols <- match(EggExpvars, names(Annual))
gbm.auto(expvar = EggExpvarsCols,
         resvar = EggResvar,
         samples = EggSamples,
         lr = c(0.001),
         ZI = F,
         #fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = F)

EggResvar <- "Anch_Egg_Spring"
EggResvarCol <- match(EggResvar, names(Annual))
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]
EggExpvars <- c("Anch_Egg_PreW",
                "Anch_Larvae_PreW",
                "A_Tot_B_Y.1",
                "NPGO_Spring",
                "NPC_Str_Lat",
                "SeaLevSF_Spring",
                "BUI33N_Spring",
                "Stab_South",
                "Temp_South",
                "Sal_South",
                "O2AtDep_all",
                "Lrg_P",
                "Hake", "Jmac", "Cmac",
                "Catch_Sard",
                "Msquid_Biom",
                "Rockfish_Biom",
                "Krill_mgCm2")
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


#5 BRT-whittled vars + lags####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/"))
dir.create("2018.09.26")
setwd("2018.09.26")

# redo BRTs with only those variables and with y-1 resvar lags (already done for adults)
lagYears <- 1 # vector of years to lag
toLag <- c("Anch_Larvae_Peak",
           "Anch_Larvae_PreW",
           "Anch_Larvae_Spring",
           "Anch_Egg_Peak",
           "Anch_Egg_PreW",
           "Anch_Egg_Spring") # vector of names of columns to lag 
for(n in lagYears){ # start loop trough numbers of years to lag
  for (i in toLag){ # loop through variable columns for each lag year
    len <- length(Annual[,i])-n # length of variable i minus n rows, within the dataset
    assign(paste0(i, "_lag_", n), # name new vector systematically, name_lag_n
           c(rep(NA, n), Annual[(1:len), i]))#put n NULLs at front then variable except n entries 
  } #close i, all variables for that year of lag
} # close n, final year of lag series

Annual <- cbind(Annual,
                Anch_Larvae_Peak_lag_1,
                Anch_Larvae_PreW_lag_1,
                Anch_Larvae_Spring_lag_1,
                Anch_Egg_Peak_lag_1,
                Anch_Egg_PreW_lag_1,
                Anch_Egg_Spring_lag_1)

#5.1 Adult vars####
AdultResvar <- "A_Tot_B"
AdultResvarCol <- match(AdultResvar, names(Annual))
AdultSamples <- Annual[-which(is.na(Annual[AdultResvar])),] # remove NA rows
AdultExpvars <- c("A_Tot_B_Y.1",
                  "NPGO_Spring",
                  "Sml_P", #0.9
                  "Euphausiids", #1.9
                  "Sablefish",
                  "C_SeaLion", #1.8
                  "FishLand", #3.7
                  "Biom_Sard_Alec",
                  "Msquid_Biom") #3.2
AdultExpvarsCols <- match(AdultExpvars, names(Annual))
gbm.auto(expvar = AdultExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamples,
         lr = c(0.000001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = F)
         #n.trees = 10)
# redone for adults, shoudl be same as simp run from 24th?
# Oddly not. Pre-simped 25th has biom_sard 55%, a_tot_B-1 25%; 24th has A_tot_B-1 35%, sard 33%. 25th has 0% for sml_p, euph, sealion, msquid; 24th has contribs from all of those. Need to loop these to test further.

#5.2 larvae vars####
LarvalResvar <- "Anch_Larvae_Peak"
LarvalResvarCol <- match(LarvalResvar, names(Annual))
LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
LarvalExpvars <- c("A_Tot_B_Y.1",
                   "Anch_Larvae_Peak_lag_1",
                   "Lrg_P",
                   "Hake",
                   "Jmac",
                   "Krill_mgCm2")
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
         simp = F, #simp fails & crashes
         multiplot = F,
         varint = F)
         #n.trees = 10)
#w/o Anch_Larvae_Peak_lag_1 is same as 24th.
#w/ lag similar but lag 2nd place, steals influence from hake (#1)

LarvalResvar <- "Anch_Larvae_PreW"
LarvalResvarCol <- match(LarvalResvar, names(Annual))
LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
LarvalExpvars <- c("A_Tot_B_Y.1", #0.1
                   "Anch_Larvae_PreW_lag_1",
                   "O2AtDep_all", #0.06
                   "Lrg_P",
                   "Hake",
                   "Jmac",
                   "Krill_mgCm2") #0.4
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
         varint = F)
# 26th same as 24th. Lag near-irrelevant

LarvalResvar <- "Anch_Larvae_Spring"
LarvalResvarCol <- match(LarvalResvar, names(Annual))
LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
LarvalExpvars <- c("Anch_Egg_PreW",
                  "Anch_Larvae_Spring_lag_1",
                   "A_Tot_B_Y.1",
                   "Lrg_P", #0.8, nosimp failed
                   "Hake",
                   "Msquid_Biom",
                   "Krill_mgCm2")
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
         varint = F)
# simplifying is better & there are loads of 0INF vars but they're not dropped?
# 26th same as 24th. Lag=3%inf

#5.3 egg vars####
EggResvar <- "Anch_Egg_Peak"
EggResvarCol <- match(EggResvar, names(Annual))
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]
EggExpvars <- c("A_Tot_B_Y.1",
                "Anch_Egg_Peak_lag_1",
                "NPGO_Spring", #0.09
                "BUI33N_Spring", #nosimp 0
                "Stab_South", #nosimp 0
                "Sal_South",
                "O2AtDep_all",
                "Lrg_P", #nosimp 0
                "Hake",
                "Jmac", #0.2
                "Cmac", #0.06
                "Catch_Sard",
                "Krill_mgCm2") #0.2
EggExpvarsCols <- match(EggExpvars, names(Annual))
gbm.auto(expvar = EggExpvarsCols,
         resvar = EggResvar,
         samples = EggSamples,
         lr = c(0.001),
         ZI = F,
         #fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = F)
# 26th similar to 24th but a_tot_B-1 more important than hake, flipped.
# EggLag new 2nd place in front of A_tot_B

EggResvar <- "Anch_Egg_PreW"
EggResvarCol <- match(EggResvar, names(Annual))
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]
EggExpvars <- c("A_Tot_B_Y.1",
                "Anch_Egg_PreW_lag_1",
                "NPGO_PreW", #simp 0.1
                "SeaLevSF_PreW", #nosimp 0.08
                "BUI33N_PreW", #simp0.2
                "Temp_South",
                "Sal_South",
                "O2AtDep_all",
                "Lrg_P",
                "Hake",
                "Jmac", #simp 0.3
                "Catch_Sard",
                "Krill_mgCm2") #nosimp 0.1
EggExpvarsCols <- match(EggExpvars, names(Annual))
gbm.auto(expvar = EggExpvarsCols,
         resvar = EggResvar,
         samples = EggSamples,
         lr = c(0.001),
         ZI = F,
         #fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = F)
# 26th vs 24th similar, sal more important now, need to run as loops.
# Maybe don't delete 'useless' variables from 1 run since they could be ok after looping.
# Lag: new @ 3rd

EggResvar <- "Anch_Egg_Spring"
EggResvarCol <- match(EggResvar, names(Annual))
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]
EggExpvars <- c("Anch_Egg_PreW",
                "Anch_Larvae_PreW",
                "A_Tot_B_Y.1",
                "Anch_Egg_Spring_lag_1",
                "Temp_South",
                "Sal_South",
                "Stab_South",
                "O2AtDep_all",
                "Hake",
                "Jmac", #nosimp/simp 0.1
                "Catch_Sard",
                "Krill_mgCm2") #nosimp 0.6 simp 0.8
EggExpvarsCols <- match(EggExpvars, names(Annual))
gbm.auto(expvar = EggExpvarsCols,
         resvar = EggResvar,
         samples = EggSamples,
         lr = c(0.001),
         ZI = F,
         #fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = F)
# lag new @ 3rd. Sard & anch egg prew swap, egg going 1st.

#6 allvars 1:4yrLags####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/"))
dir.create("2018.09.27_1to4yrLags")
setwd("2018.09.27_1to4yrLags")

# redo BRTs with all main variables and  y-1:4 resvar lags

source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/AddLags.R"))

Annual <- AddLags(x = Annual,
                  lagYears = 1:4,
                  toLag = c("A_Tot_B",
                            "Anch_Larvae_Peak",
                            "Anch_Larvae_PreW",
                            "Anch_Larvae_Spring",
                            "Anch_Egg_Peak",
                            "Anch_Egg_PreW",
                            "Anch_Egg_Spring"))

#6.1 Adult vars####
AdultResvar <- "A_Tot_B"
AdultResvarCol <- match(AdultResvar, names(Annual))
AdultSamples <- Annual[-which(is.na(Annual[AdultResvar])),] # remove NA rows
AdultExpvars <- c("NPGO_Spring",
                  "NPC_Str_Lat",
                  "SeaLevLA_PreW",
                  "BUI33N_Spring",
                  "Stab_South",
                  "Temp_South",
                  "Sal_South",
                  "O2AtDep_all",
                  "ChlA_all",
                  "Sml_P",
                  "Euphausiids",
                  "Albacore",
                  "Sablefish",
                  "ChinSal",
                  "Halibut",
                  "SoShWa",
                  "HBW",
                  "Hsquid",
                  "C_SeaLion",
                  "C_Murre",
                  "FishLand",
                  "Biom_Sard_Alec",
                  "Hake_Biom",
                  "Msquid_Biom",
                  "Rockfish_Biom",
                  "Krill_mgCm2",
                  "A_Tot_B_lag_1",
                  "A_Tot_B_lag_2",
                  "A_Tot_B_lag_3",
                  "A_Tot_B_lag_4")
AdultExpvarsCols <- match(AdultExpvars, names(Annual))
gbm.auto(expvar = AdultExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamples,
         lr = c(0.000001),
         ZI = F,
         # fam1 = "gaussian",
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = F)

#6.2 larvae vars####
LarvalResvar <- "Anch_Larvae_Peak"
LarvalResvarCol <- match(LarvalResvar, names(Annual))
LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
LarvalExpvars <- c("A_Tot_B_lag_1",
                   "NPGO_Spring",
                   "NPC_Str_Lat",
                   "SeaLevSF_Spring",
                   "BUI33N_Spring",
                   "Stab_South",
                   "Temp_South",
                   "Sal_South",
                   "O2AtDep_all",
                   "ChlA_all",
                   "Sml_P", "Lrg_P",
                   "Hake", "Jmac", "Cmac",
                   "Catch_Sard",
                   "Msquid_Biom",
                   "Rockfish_Biom",
                   "Krill_mgCm2",
                   "Anch_Larvae_Peak_lag_1",
                   "Anch_Larvae_Peak_lag_2",
                   "Anch_Larvae_Peak_lag_3",
                   "Anch_Larvae_Peak_lag_4")
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
         simp = T, #simp fails & crashes?
         multiplot = F,
         varint = F)

LarvalResvar <- "Anch_Larvae_PreW"
LarvalResvarCol <- match(LarvalResvar, names(Annual))
LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
LarvalExpvars <- c("A_Tot_B_lag_1",
                   "NPGO_PreW",
                   "NPC_Str_Lat",
                   "SeaLevSF_PreW",
                   "BUI33N_PreW",
                   "Stab_South",
                   "Temp_South",
                   "Sal_South",
                   "O2AtDep_all",
                   "ChlA_all",
                   "Sml_P", "Lrg_P",
                   "Hake", "Jmac", "Cmac",
                   "Catch_Sard",
                   "Msquid_Biom",
                   "Rockfish_Biom",
                   "Krill_mgCm2",
                   "Anch_Larvae_PreW_lag_1",
                   "Anch_Larvae_PreW_lag_2",
                   "Anch_Larvae_PreW_lag_3",
                   "Anch_Larvae_PreW_lag_4")
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
         simp = T,
         multiplot = F,
         varint = F)

LarvalResvar <- "Anch_Larvae_Spring"
LarvalResvarCol <- match(LarvalResvar, names(Annual))
LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
LarvalExpvars <- c("Anch_Egg_PreW",
                   "Anch_Larvae_PreW",
                   "A_Tot_B_lag_1",
                   "NPGO_Spring",
                   "NPC_Str_Lat",
                   "SeaLevSF_Spring",
                   "BUI33N_Spring",
                   "Stab_South",
                   "Temp_South",
                   "Sal_South",
                   "O2AtDep_all",
                   "ChlA_all",
                   "Sml_P", "Lrg_P",
                   "Hake", "Jmac", "Cmac",
                   "Catch_Sard",
                   "Msquid_Biom",
                   "Rockfish_Biom",
                   "Krill_mgCm2",
                   "Anch_Larvae_Spring_lag_1",
                   "Anch_Larvae_Spring_lag_2",
                   "Anch_Larvae_Spring_lag_3",
                   "Anch_Larvae_Spring_lag_4")
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
         simp = T,
         multiplot = F,
         varint = F)

#6.3 egg vars####
EggResvar <- "Anch_Egg_Peak"
EggResvarCol <- match(EggResvar, names(Annual))
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]
EggExpvars <- c("A_Tot_B_lag_1",
                "NPGO_Spring",
                "NPC_Str_Lat",
                "SeaLevSF_PreW",
                "BUI33N_Spring",
                "Stab_South",
                "Temp_South",
                "Sal_South",
                "O2AtDep_all",
                "Lrg_P",
                "Hake", "Jmac", "Cmac",
                "Catch_Sard",
                "Msquid_Biom",
                "Rockfish_Biom",
                "Krill_mgCm2",
                "Anch_Egg_Peak_lag_1",
                "Anch_Egg_Peak_lag_2",
                "Anch_Egg_Peak_lag_3",
                "Anch_Egg_Peak_lag_4")
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

EggResvar <- "Anch_Egg_PreW"
EggResvarCol <- match(EggResvar, names(Annual))
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]
EggExpvars <- c("A_Tot_B_lag_1",
                "NPGO_PreW", #simp 0.1
                "SeaLevSF_PreW", #nosimp 0.08
                "BUI33N_PreW", #simp0.2
                "Temp_South",
                "Sal_South",
                "O2AtDep_all",
                "Lrg_P",
                "Hake",
                "Jmac", #simp 0.3
                "Catch_Sard",
                "Krill_mgCm2",
                "Anch_Egg_PreW_lag_1",
                "Anch_Egg_PreW_lag_2",
                "Anch_Egg_PreW_lag_3",
                "Anch_Egg_PreW_lag_4")
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

EggResvar <- "Anch_Egg_Spring"
EggResvarCol <- match(EggResvar, names(Annual))
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]
EggExpvars <- c("Anch_Egg_PreW",
                "Anch_Larvae_PreW",
                "A_Tot_B_lag_1",
                "NPGO_Spring",
                "NPC_Str_Lat",
                "SeaLevSF_Spring",
                "BUI33N_Spring",
                "Stab_South",
                "Temp_South",
                "Sal_South",
                "O2AtDep_all",
                "Lrg_P",
                "Hake", "Jmac", "Cmac",
                "Catch_Sard",
                "Msquid_Biom",
                "Rockfish_Biom",
                "Krill_mgCm2",
                "Anch_Egg_Spring_lag_1",
                "Anch_Egg_Spring_lag_2",
                "Anch_Egg_Spring_lag_3",
                "Anch_Egg_Spring_lag_4")
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

#7 allvars 1:4yrLg 10Loop####
# Choose between preW, spring & Peak then stop running the other 2 (4)
# Peak is best for both, yay. see:
# \Data & Analysis\ModelOutputs\2018.09.27_1to4yrLags\CV scores.xlsx
# Lags: 1 year lag is best for peaks & adults, next best is 4 year for A & E, 3 then 2 for L
# E4 L3 E3 A4 E2 L4 all 6.7 to 0.6% inf. Lags constitute 28.8% of total inf%s

# Run n=10 loops on full varset inc any lags brought in, again w/ simp on
# Impossible that adding variables will lower pred.dev.
# Use simp since it will choose best BRT simp or not.
# BUT often crashes BRT! Try with then fallback to without if it crashes.
# Or leave off since it's rarely being used and can lead to crashes?

library(gbm.auto)
#machine <- "/home" # linux desktop (& laptop?)
machine <- "C:/Users"# windows laptop
Annual <- read.csv(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Data Structure Template 2018.09.24.csv'), na.strings = "")
Annual <- Annual[1:(match(2017, Annual$Year)),]

setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/"))
# dir.create("2018.09.27_1to4yrLags_10Loop")
setwd("2018.09.27_1to4yrLags_10Loop")

source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/AddLags.R"))

Annual <- AddLags(x = Annual,
                  lagYears = 1:4,
                  toLag = c("A_Tot_B",
                            "Anch_Larvae_Peak",
                            "Anch_Larvae_PreW",
                            "Anch_Larvae_Spring",
                            "Anch_Egg_Peak",
                            "Anch_Egg_PreW",
                            "Anch_Egg_Spring"))

#7.1 Adult vars####
AdultResvar <- "A_Tot_B"
AdultResvarCol <- match(AdultResvar, names(Annual))
AdultSamples <- Annual[-which(is.na(Annual[AdultResvar])),] # remove NA rows
AdultExpvars <- c("NPGO_Spring",
                  "NPC_Str_Lat",
                  "SeaLevLA_PreW",
                  "BUI33N_Spring",
                  "Stab_South",
                  "Temp_South",
                  "Sal_South",
                  "O2AtDep_all",
                  "ChlA_all",
                  "Sml_P",
                  "Euphausiids",
                  "Albacore",
                  "Sablefish",
                  "ChinSal",
                  "Halibut",
                  "SoShWa",
                  "HBW",
                  "Hsquid",
                  "C_SeaLion",
                  "C_Murre",
                  "FishLand",
                  "Biom_Sard_Alec",
                  "Hake_Biom",
                  "Msquid_Biom",
                  "Rockfish_Biom",
                  "Krill_mgCm2",
                  "A_Tot_B_lag_1",
                  "A_Tot_B_lag_2",
                  "A_Tot_B_lag_3",
                  "A_Tot_B_lag_4")
AdultExpvarsCols <- match(AdultExpvars, names(Annual))
gbm.loop(expvar = AdultExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamples,
         lr = c(0.000001),
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = F,
         alerts = F)

#7.2 larvae vars####
LarvalResvar <- "Anch_Larvae_Peak"
LarvalResvarCol <- match(LarvalResvar, names(Annual))
LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
LarvalExpvars <- c("A_Tot_B_lag_1",
                   "NPGO_Spring",
                   "NPC_Str_Lat",
                   "SeaLevSF_Spring",
                   "BUI33N_Spring",
                   "Stab_South",
                   "Temp_South",
                   "Sal_South",
                   "O2AtDep_all",
                   "ChlA_all",
                   "Sml_P", "Lrg_P",
                   "Hake", "Jmac", "Cmac",
                   "Catch_Sard",
                   "Msquid_Biom",
                   "Rockfish_Biom",
                   "Krill_mgCm2",
                   "Anch_Larvae_Peak_lag_1",
                   "Anch_Larvae_Peak_lag_2",
                   "Anch_Larvae_Peak_lag_3",
                   "Anch_Larvae_Peak_lag_4")
LarvalExpvarsCols <- match(LarvalExpvars, names(Annual))
gbm.loop(expvar = LarvalExpvarsCols,
         resvar = LarvalResvar,
         samples = LarvalSamples,
         lr = c(0.00000001),
         bf = 0.9,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = F,
         alerts = F)

#7.3 egg vars####
EggResvar <- "Anch_Egg_Peak"
EggResvarCol <- match(EggResvar, names(Annual))
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]
EggExpvars <- c("A_Tot_B_lag_1",
                "NPGO_Spring",
                "NPC_Str_Lat",
                "SeaLevSF_PreW",
                "BUI33N_Spring",
                "Stab_South",
                "Temp_South",
                "Sal_South",
                "O2AtDep_all",
                "Lrg_P",
                "Hake", "Jmac", "Cmac",
                "Catch_Sard",
                "Msquid_Biom",
                "Rockfish_Biom",
                "Krill_mgCm2",
                "Anch_Egg_Peak_lag_1",
                "Anch_Egg_Peak_lag_2",
                "Anch_Egg_Peak_lag_3",
                "Anch_Egg_Peak_lag_4")
EggExpvarsCols <- match(EggExpvars, names(Annual))
gbm.loop(expvar = EggExpvarsCols,
         resvar = EggResvar,
         samples = EggSamples,
         lr = c(0.0001),
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = F,
         alerts = F)

#8 expvar lags####
# other expvar lags: how to choose? Could be a massive undertaking?
# Or include ALL y0 and y-1 and see if any y-1 outperform y0 and if so
# discard y0 and try y-2 ad infinitum

#9 logs####

#10 subsets & thresholds####
# some way to test the 2-stage rocket concept: is there a difference in getting
# from B1:B2 vs B2:B3? Or is a (sequential) X% increase (within the min-max
# range) a constant product of the same underlying forcing factors? Bill thinks
# it's reproductive success in prewinter and recruitment success in spring/summer.


