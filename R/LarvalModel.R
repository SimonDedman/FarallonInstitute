## Larval model
## SD started 19/06/2018
## Latest edit 15/10/2018

rm(list = ls()) # remove everything if you crashed before

#Install packages####
# install.packages("devtools")
library(devtools)
install_github("SimonDedman/gbm.auto") # update gbm.auto to latest
library(gbm.auto)

# which machine are you on?
#machine <- "/home" # linux desktop (& laptop?)
machine <- "C:/Users"# windows laptop

##1 Import, clean, set variables####
# read in csv created from Data Structure Template excel
Annual <- read.csv(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Data Structure Template 2018.10.30.csv'),
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
                  "Catch_Sard","Biom_Sard_Alec", "Msquid_CPUE", "Krill_CPUE", "Krill_mgCm2", "Consumption")

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

#sablefish####
#Being talked about cos it has 3% inf on adult A but relationship is positive,
# threshold >300k sablefish very beneficial for A. Are sablefish indexing
# something else? Best enviro r2 against o2 centcal but o2 centcal 0% inf for
# adult A in BRT (\ModelOutputs\PruneVars\RegionsPrune\O2\A_Tot_B)
# o2 centcal r=0.67 w/ dep_all (currently using) & 0.52 w/ offsh (should be using)
# So while sablefish correlates to one area's o2, that area's o2 is the worst
# influential o2 for adult anchovy despite sablefish being influential. Therefore
# keep sablefish as is.
# More sablefish = more o2 & less chlA
# More sablefish = more CmacAd, less sealion, less murre, less albacore, less c_hbw
# more fishland, less mktsqdcatch, less sard catch & B, more rockfish B.
# Ecologically distinct niche for sablefish, their abundance signifies absence
# of multiple high consumers (sealion hbw murre?) also sard?
source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/pairPlots.R"))
colnames(Annual) #sablefish 101, checking against too many in 1 go, split up
length(15:133) #119
120/20 #6
SableExpvars <- colnames(Annual)[c(101,74)]
#22 = NEI is dead
#39 = Surf_spd_dir dead
#110 = C_Jmac dead
#111 = C_Cmac dead
#SableExpvars <- colnames(Annual)[c(101,22)]
pairs(Annual[SableExpvars],
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
#SableExpvarsCols <- match(SableExpvars, names(Annual))
#Sablefish against
##Environment
#0.59 NPC stream lat
#0.53 ekPreW 46012
#0.61 o2AtDep_All
#0.84 O2_CentCal : biggest
#0.52 o2_transition
#0.63 ChlA_all
#0.52 ChlA_centcal
#0.68 ChlA_transition

##Predators
#0.88 CmacAd #not using in analysis
#0.80 sealion
#0.58 Albacore
#0.67 COmmonMurre
#0.62 SBCD
#0.79 HBW
#0.77 C_Albacore
#1.00 C_Sablefish, duh
#0.62 C_SBCD
#0.79 C_HBW
#0.77 FIshLand
#0.79 MktSqdCatch
#0.58 Catch_sard
#0.67 biom_sard_alec
#0.71 biom_sard_andre
#0.57 rockfish biom

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
#dir.create("2018.09.26")
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
#dir.create("2018.09.27_1to4yrLags")
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
Annual <- read.csv(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Data Structure Template 2018.10.30.csv'), na.strings = "")
Annual <- Annual[1:(match(2017, Annual$Year)),]

setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/"))
#dir.create("2018.10.01_1to4yrLags_10Loop")
setwd("2018.10.01_1to4yrLags_10Loop")

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
                  "Stability_all", #changed from South 2018.10.01
                  "Temp_NCoast", #changed from South 2018.10.01
                  "Sal_South",
                  "O2_Offsh", #changed from All 2018.10.01
                  "ChlA_Nearsh", #changed from All 2018.10.01
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
gbm.loop(loops = 10,
         expvar = AdultExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamples,
         lr = c(0.000001),
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = T, #F
         alerts = F)

#7.2 larvae vars####
LarvalResvar <- "Anch_Larvae_Peak"
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
gbm.loop(expvar = LarvalExpvars,
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

# sablefish: pairplot against... everything. Done.

#8 subsets & thresholds####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.18_Subsets_10Loop"))
dir.create("2018.10.15_Subsets_10Loop")
setwd("2018.10.15_Subsets_10Loop")

# some way to test the 2-stage rocket concept: is there a difference in getting
# from B1:B2 vs B2:B3? Or is a (sequential) X% increase (within the min-max
# range) a constant product of the same underlying forcing factors? Bill thinks
# it's reproductive success in prewinter and recruitment success in spring/summer.
#
# Sardine, choose best testable threshold, based on all 3 resvars (how to compare catch sard w/ biom sard alec?)
# Ditto hake? Why not?
# Ditto anchovy, lag y-1
# =18 more runs (2 subsets of 3 expvars * 3 resvars)
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.18_Subsets_10Loop"))
#8.1 sardine####
dir.create("HiSard")
dir.create("LoSard")
setwd("HiSard")
# Adults: biom alec 0line (swaps from positive to negative preference, big spike) between:
# min: 77521 & 85264. Av: 116232 & 123975. Max:  131717 & 139459
mean(c(116232, 123975)) # 120103.5, say 120,000
# Larvae: irrelevant, 0.5%INF
# Eggs: catch sard
# min: 6029. Av: 7536 & 9043. Max: 15071 & 16578
mean(c(7536, 9043)) # 8289 say 8300
# Both
# Do adult & egg separately given different variables
#adults####
AdultResvar <- "A_Tot_B"
AdultSamples <- Annual[-which(is.na(Annual[AdultResvar])),] # remove NA rows

AdultSamplesHiSard <- subset(AdultSamples, Biom_Sard_Alec > 120000)
AdultSamplesLoSard <- subset(AdultSamples, Biom_Sard_Alec <= 120000)

AdultExpvars <- c("NPGO_Spring",
                  #"NPC_Str_Lat", #useless & too few values, kills model runs
                  "SeaLevLA_PreW", #useless
                  "BUI33N_Spring",
                  "Stability_all", #changed from South 2018.10.01
                  "Temp_NCoast", #changed from South 2018.10.01
                  "Sal_South", #useless
                  "O2_Offsh", #changed from All 2018.10.01
                  "ChlA_Nearsh", #changed from All 2018.10.01
                  "Sml_P",
                  "Euphausiids",
                  #"Albacore", #useless & too few values, kills model runs
                  "Sablefish",
                  "ChinSal", #useless in loop w/ consumption
                  "Halibut", #useless
                  "SoShWa", #useless
                  #"HBW", #useless & too few values, kills model runs
                  #"Hsquid", #useless & too few values, kills model runs
                  "C_SeaLion",
                  "C_Murre", #useless in loop w/ consumption
                  "FishLand", #useless in loop w/ consumption
                  "Biom_Sard_Alec",
                  "Hake_Biom", #useless
                  "Msquid_Biom",
                  "Rockfish_Biom",
                  "Krill_mgCm2",
                  "A_Tot_B_lag_1",
                  "A_Tot_B_lag_2",
                  "Consumption")  # consumption added, remove components?
##minimised list:
AdultExpvars <- c("NPGO_Spring",
                  #"NPC_Str_Lat", #useless
                  #"SeaLevLA_PreW", #useless
                  #"BUI33N_Spring",
                  "Stability_all", #changed from South 2018.10.01
                  "Temp_NCoast", #changed from South 2018.10.01
                  #"Sal_South", #useless
                  "O2_Offsh", #changed from All 2018.10.01
                  "ChlA_Nearsh", #changed from All 2018.10.01
                  "Sml_P",
                  "Euphausiids",
                  #"Albacore", #useless
                  #"Sablefish",
                  #"ChinSal", #useless in loop w/ consumption
                  #"Halibut", #useless
                  #"SoShWa", #useless
                  #"HBW", #useless
                  #"Hsquid", #useless
                  #"C_SeaLion",
                  #"C_Murre", #useless in loop w/ consumption
                  # "FishLand", #useless in loop w/ consumption
                  "Biom_Sard_Alec",
                  #"Hake_Biom", #useless
                  "Msquid_Biom",
                  "Rockfish_Biom",
                  "Krill_mgCm2",
                  "A_Tot_B_lag_1",
                  #"A_Tot_B_lag_2",
                  "Consumption")  # consumption added, remove components?
AdultExpvarsCols <- match(AdultExpvars, names(Annual))
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.15_Subsets_10Loop/HiSard"))
gbm.bfcheck(samples = AdultSamplesHiSard, resvar = AdultResvar, ZI = F)
# [1] "  binary bag fraction must be at least 0.724"
# [1] "Gaussian bag fraction must be at least 0.724"
gbm.loop(expvar = AdultExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamplesHiSard,
         lr = c(0.0000001),
         bf = 0.9, #tried 0.724, 0.8
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = T, #F
         alerts = F)

#loglag rerun
AdultSamplesLagHiSard <- subset(AdultSamplesLag, Biom_Sard_Alec > 120000)
gbm.bfcheck(samples = AdultSamplesLagHiSard, resvar = AdultResvar, ZI = F)
#0.724
AdultSamplesLagLoSard <- subset(AdultSamplesLag, Biom_Sard_Alec <= 120000)
gbm.bfcheck(samples = AdultSamplesLagLoSard, resvar = AdultResvar, ZI = F)
#0.778
gbm.loop(expvar = AdultExpvarsLag12,
         resvar = AdultResvar,
         samples = AdultSamplesLagHiSard,
         lr = 0.001, #0.1 
         bf = 0.9,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F, #kept crashing mbinobismode database too small error
         multiplot = F,
         varint = F, #saving time
         alerts = F) 

setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.15_Subsets_10Loop/LoSard"))
gbm.bfcheck(samples = AdultSamplesLoSard, resvar = AdultResvar, ZI = F)
# [1] "  binary bag fraction must be at least 0.778"
# [1] "Gaussian bag fraction must be at least 0.778"
gbm.loop(expvar = AdultExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamplesLoSard,
         lr = c(0.0000001),
         bf = 0.9, # tried 0.778, 0.8, 0.85
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = T, #F
         alerts = F)

AdultExpvarsLag12 <- AdultExpvarsLag12[-c(2,15,16,30,43,44,58,71,72)] #remove npc str lat too few values, hbw, squid
AdultExpvarsLag12 <- AdultExpvarsLag12[-c(9,34,59)] #remove albacore
gbm.loop(expvar = AdultExpvarsLag12,
         resvar = AdultResvar,
         samples = AdultSamplesLagLoSard,
         lr = 0.001, #0.1 
         bf = 0.9,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F, #kept crashing mbinobismode database too small error
         multiplot = F,
         varint = F, #saving time
         alerts = F)

#eggs####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.15_Subsets_10Loop/HiSard"))
EggResvar <- "Anch_Egg_Peak"
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]
EggSamplesHiSard <- subset(EggSamples, Catch_Sard > 8300)
EggSamplesLoSard <- subset(EggSamples, Catch_Sard <= 8300)
EggExpvars <- c("A_Tot_B_lag_1",
                "NPGO_Spring",
                #"NPC_Str_Lat", #0inf%, frequently crashes runs as only has missing values.
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
gbm.bfcheck(samples = EggSamplesHiSard, resvar = EggResvar, ZI = F)
# [1] "  binary bag fraction must be at least 0.7"
# [1] "Gaussian bag fraction must be at least 0.7"
gbm.loop(expvar = EggExpvarsCols,
         resvar = EggResvar,
         samples = EggSamplesHiSard,
         lr = c(0.000001),
         bf = 0.8,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = T,
         alerts = F)
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.15_Subsets_10Loop/LoSard"))
gbm.bfcheck(samples = EggSamplesLoSard, resvar = EggResvar, ZI = F)
# [1] "  binary bag fraction must be at least 0.7"
# [1] "Gaussian bag fraction must be at least 0.7"
gbm.loop(expvar = EggExpvarsCols,
         resvar = EggResvar,
         samples = EggSamplesLoSard,
         lr = c(0.000001),
         bf = 0.8, #0.7 fails
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = T,
         alerts = F)

EggSamplesLagHiSard <- subset(EggSamplesLag, Catch_Sard > 8300)
gbm.bfcheck(samples = EggSamplesLagHiSard, resvar = EggResvar, ZI = F)
EggSamplesLagLoSard <- subset(EggSamplesLag, Catch_Sard <= 8300)
gbm.bfcheck(samples = EggSamplesLagLoSard, resvar = EggResvar, ZI = F)
#0.7
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.15_Subsets_10Loop/HiSard"))
gbm.loop(expvar = EggExpvarsLag12,
         resvar = EggResvar,
         samples = EggSamplesLagHiSard,
         lr = 0.007, #ran these with 0.000000001 and tried 0.1 also
         bf = 0.85,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = F,
         alerts = F)
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.15_Subsets_10Loop/LoSard"))
EggExpvarsLag12 <- EggExpvarsLag12[-c(3,21,39)] #remove npc stream lat lags
gbm.loop(expvar = EggExpvarsLag12,
         resvar = EggResvar,
         samples = EggSamplesLagLoSard,
         lr = 0.007, #ran these with 0.000000001 and tried 0.1 also
         bf = 0.85,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = F,
         alerts = F)


#8.2 hake####
# Adults irrelvant
# Larvae, average only
mean(c(1525397.306, 1542542.087)) # 1533970
# Egg
mean(c(1456818.182, 1473962.963)) # 1465391
# Both
mean(c(1533970, 1465391)) # 1499681
# round up to a big fat juicy 1500000
# Do both E & L
#larvae####
LarvalResvar <- "Anch_Larvae_Peak"
LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
LarvalSamplesHiHake <- subset(LarvalSamples, Hake > 1500000)
LarvalSamplesLoHake <- subset(LarvalSamples, Hake <= 1500000)
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
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.04_Subsets_10Loop/"))
dir.create("HiHake")
dir.create("LoHake")
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.04_Subsets_10Loop/HiHake"))
gbm.bfcheck(samples = LarvalSamplesHiHake, resvar = LarvalResvar, ZI = F)
# [1] "  binary bag fraction must be at least 1.235"
# [1] "Gaussian bag fraction must be at least 1.235" #that bodes badly...
gbm.loop(expvar = LarvalExpvarsCols,
         resvar = LarvalResvar,
         samples = LarvalSamplesHiHake,
         lr = c(0.00000001),
         bf = 0.95, #0.95 fails
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = F) # fails
#  Error in gbm.fit(x = x, y = y, offset = offset, distribution = distribution,  : 
# The data set is too small or the subsampling rate is too large: `nTrain * bag.fraction <= n.minobsinnode` 

gbm.step(data = LarvalSamplesHiSard, gbm.x = LarvalExpvarsCols, gbm.y = LarvalResvar, family = "gaussian", 
         tree.complexity = 1, learning.rate = 0.0000001, bag.fraction = 0.5) 

setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.04_Subsets_10Loop/LoHake"))
gbm.bfcheck(samples = LarvalSamplesLoHake, resvar = LarvalResvar, ZI = F)
# [1] "  binary bag fraction must be at least 0.677"
# [1] "Gaussian bag fraction must be at least 0.677"
gbm.loop(expvar = LarvalExpvarsCols,
         resvar = LarvalResvar,
         samples = LarvalSamplesLoHake,
         lr = c(0.000001),
         bf = 0.8, #tried 0.677 0.7
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = F,
         alerts = F)

LarvalSamplesLagHiHake <- subset(LarvalSamplesLag, Hake > 1500000)
gbm.bfcheck(samples = LarvalSamplesLagHiHake, resvar = LarvalResvar, ZI = F) #1.2334 DEAD
LarvalSamplesLagLoHake <- subset(LarvalSamplesLag, Hake <= 1500000)
gbm.bfcheck(samples = LarvalSamplesLagLoHake, resvar = LarvalResvar, ZI = F) #0.677
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.15_Subsets_10Loop/LoHake"))
gbm.loop(expvar = LarvalExpvarsLag12,
         resvar = LarvalResvar,
         samples = LarvalSamplesLagLoHake,
         lr = 0.0001,  #tried 0.1 0.05
         bf = 0.8, #
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = F)

#eggs####
EggResvar <- "Anch_Egg_Peak"
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]
EggSamplesHiHake <- subset(EggSamples, Hake > 1500000)
EggSamplesLoHake <- subset(EggSamples, Hake <= 1500000)
EggExpvars <- c("A_Tot_B_lag_1",
                "NPGO_Spring",
                #"NPC_Str_Lat", #0inf%, frequently crashes runs as only has missing values.
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
gbm.bfcheck(samples = EggSamplesHiHake, resvar = EggResvar, ZI = F)
# [1] "  binary bag fraction must be at least 1.235"
# [1] "Gaussian bag fraction must be at least 1.235" ...bodes badly
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.04_Subsets_10Loop/HiHake"))
gbm.loop(expvar = EggExpvarsCols,
         resvar = EggResvar,
         samples = EggSamplesHiHake,
         lr = c(0.000001),
         bf = 0.95,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = T,
         alerts = F) #fails
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.04_Subsets_10Loop/LoHake"))
gbm.bfcheck(samples = EggSamplesLoHake, resvar = EggResvar, ZI = F)
# [1] "  binary bag fraction must be at least 0.677"
# [1] "Gaussian bag fraction must be at least 0.677"
gbm.loop(expvar = EggExpvarsCols,
         resvar = EggResvar,
         samples = EggSamplesLoHake,
         lr = c(0.000001),
         bf = 0.8, #0.677, 0.7 fails
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = T,
         alerts = F)

EggSamplesLagHiHake <- subset(EggSamplesLag, Hake > 1500000)
gbm.bfcheck(samples = EggSamplesHiHake, resvar = EggResvar, ZI = F) #1.234 FAIL
EggSamplesLagLoHake <- subset(EggSamplesLag, Hake <= 1500000)
gbm.bfcheck(samples = EggSamplesLoHake, resvar = EggResvar, ZI = F) #0.677

setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.15_Subsets_10Loop/LoHake"))
gbm.loop(expvar = EggExpvarsLag12,
         resvar = EggResvar,
         samples = EggSamplesLagLoHake,
         lr = 0.001, #ran these with 0.000000001 and tried 0.1 also
         bf = 0.9,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = F,
         alerts = F)

#8.3 Anchovy B y-1####
# Adults, average only
mean(c(436052.4819, 456461.9649)) # 446257.2
# Larvae
mean(c(395233.5157, 415642.9988)) # 405438.3
# Egg
mean(c(374824.0326, 395233.5157)) # 385028.8
# Both
mean(c(446257.2, 405438.3, 385028.8)) # 412241.4 say 410000
# should take the mean of all 3? Notable that threshold is higher for larger size classes?
# Min threshold looks oddly similar though?
mean(c(476871.448, 497280.9311)) # 487076.2
mean(c(395233.5157, 415642.9988)) # 405438.3
mean(c(374824.0326, 395233.5157)) # 385028.8
mean(c(487076.2, 405438.3, 385028.8)) # 425847.8
# maybe not!
# adults only? Maybe eggs as well.
#adults####
AdultResvar <- "A_Tot_B"
AdultSamples <- Annual[-which(is.na(Annual[AdultResvar])),] # remove NA rows
AdultSamplesHiAnch <- subset(AdultSamples, A_Tot_B_lag_1 > 410000)
AdultSamplesLoAnch <- subset(AdultSamples, A_Tot_B_lag_1 <= 410000)
AdultExpvars <- c("NPGO_Spring",
                  #"NPC_Str_Lat", #useless & too few values, kills model runs
                  "SeaLevLA_PreW", #useless
                  "BUI33N_Spring",
                  "Stability_all", #changed from South 2018.10.01
                  "Temp_NCoast", #changed from South 2018.10.01
                  "Sal_South", #useless
                  "O2_Offsh", #changed from All 2018.10.01
                  "ChlA_Nearsh", #changed from All 2018.10.01
                  "Sml_P",
                  "Euphausiids",
                  #"Albacore", #useless & too few values, kills model runs
                  "Sablefish",
                  "ChinSal", #useless in loop w/ consumption
                  "Halibut", #useless
                  "SoShWa", #useless
                  #"HBW", #useless & too few values, kills model runs
                  #"Hsquid", #useless & too few values, kills model runs
                  "C_SeaLion",
                  "C_Murre", #useless in loop w/ consumption
                  "FishLand", #useless in loop w/ consumption
                  "Biom_Sard_Alec",
                  "Hake_Biom", #useless
                  "Msquid_Biom",
                  "Rockfish_Biom",
                  "Krill_mgCm2",
                  "A_Tot_B_lag_1",
                  "A_Tot_B_lag_2",
                  "Consumption")  # consumption added, remove components?
##minimised list:
AdultExpvars <- c("NPGO_Spring",
                  #"NPC_Str_Lat", #useless
                  #"SeaLevLA_PreW", #useless
                  #"BUI33N_Spring",
                  "Stability_all", #changed from South 2018.10.01
                  "Temp_NCoast", #changed from South 2018.10.01
                  #"Sal_South", #useless
                  "O2_Offsh", #changed from All 2018.10.01
                  "ChlA_Nearsh", #changed from All 2018.10.01
                  "Sml_P",
                  "Euphausiids",
                  #"Albacore", #useless
                  #"Sablefish",
                  #"ChinSal", #useless in loop w/ consumption
                  #"Halibut", #useless
                  #"SoShWa", #useless
                  #"HBW", #useless
                  #"Hsquid", #useless
                  #"C_SeaLion",
                  #"C_Murre", #useless in loop w/ consumption
                  # "FishLand", #useless in loop w/ consumption
                  "Biom_Sard_Alec",
                  #"Hake_Biom", #useless
                  "Msquid_Biom",
                  "Rockfish_Biom",
                  "Krill_mgCm2",
                  "A_Tot_B_lag_1",
                  #"A_Tot_B_lag_2",
                  "Consumption")  # consumption added, remove components?
AdultExpvarsCols <- match(AdultExpvars, names(Annual))
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.04_Subsets_10Loop/"))
dir.create("HiAnch")
dir.create("LoAnch")
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.04_Subsets_10Loop/HiAnch"))
gbm.bfcheck(samples = AdultSamplesHiAnch, resvar = AdultResvar, ZI = F)
# [1] "  binary bag fraction must be at least 1.167"
# [1] "Gaussian bag fraction must be at least 1.167" wont work
gbm.loop(expvar = AdultExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamplesHiAnch,
         lr = c(0.0000001),
         bf = 0.9,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = T, #F
         alerts = F) #FAILS

setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.15_Subsets_10Loop/LoAnch"))
gbm.bfcheck(samples = AdultSamplesLoAnch, resvar = AdultResvar, ZI = F)
# [1] "  binary bag fraction must be at least 0.677"
# [1] "Gaussian bag fraction must be at least 0.677"
gbm.loop(expvar = AdultExpvarsCols,
         resvar = AdultResvarCol,
         samples = AdultSamplesLoSard,
         lr = c(0.000001),
         bf = 0.9, # tried 0.677, 0.7, 0.8, 0.85
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = T, #F
         alerts = F)

# 15/10/2018 redo loglags
AdultExpvarsLag12 <- AdultExpvarsLag12[-25] #remove A_Tot_B_log as expvar
AdultSamplesLagHiAnch <- subset(AdultSamplesLag, A_Tot_B_log_lag_1 > log1p(410000))
AdultSamplesLagLoAnch <- subset(AdultSamplesLag, A_Tot_B_log_lag_1 <= log1p(410000))
log1p(410000) #12.92
summary(AdultSamplesLag["A_Tot_B_log_lag_1"])
gbm.bfcheck(samples = AdultSamplesLagHiAnch, resvar = AdultResvar, ZI = F) #0.955 BAAD
gbm.bfcheck(samples = AdultSamplesLagLoAnch, resvar = AdultResvar, ZI = F) #0.618 fine
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.15_Subsets_10Loop/HiAnch"))
AdultResvar <- "A_Tot_B_log" #tried log and not
gbm.loop(expvar = AdultExpvarsLag12,
         resvar = AdultResvar,
         samples = AdultSamplesLagHiAnch,
         lr = 0.00001, #0.1 
         bf = 0.97,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = F,
         alerts = F) #FAIL
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.15_Subsets_10Loop/LoAnch"))
gbm.loop(expvar = AdultExpvarsLag12,
         resvar = AdultResvar,
         samples = AdultSamplesLagLoAnch,
         lr = 0.001, #0.1 
         bf = 0.8,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = F,
         alerts = F)

#eggs####
EggResvar <- "Anch_Egg_Peak"
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]
EggSamplesHiAnch <- subset(EggSamples, A_Tot_B_lag_1 > 410000)
EggSamplesLoAnch <- subset(EggSamples, A_Tot_B_lag_1 <= 410000)
EggExpvars <- c("A_Tot_B_lag_1",
                "NPGO_Spring",
                #"NPC_Str_Lat", #0inf%, frequently crashes runs as only has missing values.
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
gbm.bfcheck(samples = EggSamplesHiAnch, resvar = EggResvar, ZI = F)
# [1] "  binary bag fraction must be at least 0.955"
# [1] "Gaussian bag fraction must be at least 0.955"
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.04_Subsets_10Loop/HiAnch"))
gbm.loop(expvar = EggExpvarsCols,
         resvar = EggResvar,
         samples = EggSamplesHiAnch,
         lr = c(0.000000001),
         bf = 0.999,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = T,
         alerts = F) #can't get it to run.
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.04_Subsets_10Loop/LoAnch"))
gbm.bfcheck(samples = EggSamplesLoAnch, resvar = EggResvar, ZI = F)
# [1] "  binary bag fraction must be at least 0.636"
# [1] "Gaussian bag fraction must be at least 0.636"
gbm.loop(expvar = EggExpvarsCols,
         resvar = EggResvar,
         samples = EggSamplesLoAnch,
         lr = c(0.000001),
         bf = 0.8, #0.636, 0.7 fails
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = T,
         alerts = F)

EggResvar <- "Anch_Egg_Peak_log"
EggExpvarsLag12 <- EggExpvarsLag12[-18] #remove Anch_Egg_Peak (log) as expvar
EggSamplesLagHiAnch <- subset(EggSamplesLag, A_Tot_B_log_lag_1 > log1p(410000))
EggSamplesLagLoAnch <- subset(EggSamplesLag, A_Tot_B_log_lag_1 <= log1p(410000))
gbm.bfcheck(samples = EggSamplesLagHiAnch, resvar = EggResvar, ZI = F) #0.955 wont run
gbm.bfcheck(samples = EggSamplesLagLoAnch, resvar = EggResvar, ZI = F) #0.618
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.15_Subsets_10Loop/LoAnch"))
gbm.loop(expvar = EggExpvarsLag12,
         resvar = EggResvar,
         samples = EggSamplesLagLoAnch,
         lr = 0.001, #ran these with 0.000000001 and tried 0.1 also
         bf = 0.8,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = F,
         alerts = F)

#8.4 Data availability years####
#BeforeMe: 51:80 AfterMe:1981:2018
1980-1951 #29
2018-1981 #37
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.15_Subsets_10Loop/"))
dir.create("BMe")
dir.create("AMe")
dir.create("Fulltimeseries")
AdultResvar <- "A_Tot_B"
AdultSamples <- Annual[-which(is.na(Annual[AdultResvar])),] # remove NA rows
AdultSamplesBMe <- subset(AdultSamples, Year < 1981) #n=22 w/o NAs
AdultSamplesAMe <- subset(AdultSamples, Year >= 1981) #35
# whole timeseries, only full series variables
fulltimeseries <- c("NPGO_Spring",
                  #"NPC_Str_Lat", #useless & too few values, kills model runs
                  "SeaLevLA_PreW", #useless
                  "BUI33N_Spring",
                  "Stability_all", #changed from South 2018.10.01
                  "Temp_NCoast", #changed from South 2018.10.01
                  "Sal_South", #useless
                  "O2_Offsh", #changed from All 2018.10.01
                  #"ChlA_Nearsh", #changed from All 2018.10.01
                  "Sml_P",
                  "Euphausiids",
                  #"Albacore", #useless & too few values, kills model runs
                  "C_Sablefish",
                  #"ChinSal", #useless in loop w/ consumption
                  #"Halibut", #useless
                  #"SoShWa", #useless
                  #"HBW", #useless & too few values, kills model runs
                  #"Hsquid", #useless & too few values, kills model runs
                  #"C_SeaLion",
                  #"C_Murre", #useless in loop w/ consumption
                  "FishLand", #useless in loop w/ consumption
                  "Biom_Sard_Alec",
                  "Hake_Biom", #useless
                  "Msquid_Biom",
                  "Rockfish_Biom",
                  "Krill_mgCm2",
                  "A_Tot_B_lag_1",
                  "A_Tot_B_lag_2",
                  "Consumption")  # consumption added, remove components?
# pre81, only available data
BMe <- c("NPGO_Spring",
                  #"NPC_Str_Lat", #useless
                  "SeaLevLA_PreW", #useless
                  "BUI33N_Spring",
                  "Stability_all", #changed from South 2018.10.01
                  "Temp_NCoast", #changed from South 2018.10.01
                  "Sal_South", #useless
                  "O2_Offsh", #changed from All 2018.10.01
                  #"ChlA_Nearsh", #changed from All 2018.10.01
                  "Sml_P",
                  "Euphausiids",
                  #"Albacore", #useless
                  "C_Sablefish",
                  #"ChinSal", #useless in loop w/ consumption
                  #"Halibut", #useless
                  #"SoShWa", #useless
                  #"HBW", #useless
                  #"Hsquid", #useless
                  #"C_SeaLion",
                  #"C_Murre", #useless in loop w/ consumption
                  "FishLand", #useless in loop w/ consumption
                  "Biom_Sard_Alec",
                  "Hake_Biom", #useless
                  "Msquid_Biom",
                  "Rockfish_Biom",
                  "Krill_mgCm2",
                  "A_Tot_B_lag_1",
                  "A_Tot_B_lag_2",
                  "Consumption")  # consumption added, remove components?
# 81&after, only available data
AMe <- c("NPGO_Spring",
                  "NPC_Str_Lat", #useless
                  "SeaLevLA_PreW", #useless
                  "BUI33N_Spring",
                  "Stability_all", #changed from South 2018.10.01
                  "Temp_NCoast", #changed from South 2018.10.01
                  "Sal_South", #useless
                  "O2_Offsh", #changed from All 2018.10.01
                  "ChlA_Nearsh", #changed from All 2018.10.01
                  "Sml_P",
                  "Euphausiids",
                  "C_Albacore", #useless
                  "C_Sablefish",
                  "C_ChinSal", #useless in loop w/ consumption
                  "C_Halibut", #useless
                  "C_SoShWa", #useless
                  "C_HBW", #useless
                  "C_Hsquid", #useless
                  "C_SeaLion",
                  "C_Murre", #useless in loop w/ consumption
                  "FishLand", #useless in loop w/ consumption
                  "Biom_Sard_Alec",
                  "Hake_Biom", #useless
                  "Msquid_Biom",
                  "Rockfish_Biom",
                  "Krill_mgCm2",
                  "A_Tot_B_lag_1",
                  "A_Tot_B_lag_2",
                  "Consumption")  # consumption added, remove components?
#adults fulltimeseries####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.04_Subsets_10Loop/Fulltimeseries"))
gbm.bfcheck(samples = AdultSamples, resvar = AdultResvar, ZI = F)
# [1] "  binary bag fraction must be at least 0.368"
# [1] "Gaussian bag fraction must be at least 0.368" good
gbm.loop(expvar = fulltimeseries,
         resvar = AdultResvar,
         samples = AdultSamples,
         lr = 0.0000001,
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = T,
         alerts = F)
#adults 1951:80####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.04_Subsets_10Loop/BMe"))
gbm.bfcheck(samples = AdultSamplesBMe, resvar = AdultResvar, ZI = F)
# [1] "  binary bag fraction must be at least 0.955"
# [1] "Gaussian bag fraction must be at least 0.955" probably won't work :(
gbm.loop(expvar = BMe,
         resvar = AdultResvar,
         samples = AdultSamplesBMe,
         lr = 0.0000001,
         bf = 0.99,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = T,
         alerts = F) #won't run
#adults 1981:17####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.04_Subsets_10Loop/AMe"))
gbm.bfcheck(samples = AdultSamplesAMe, resvar = AdultResvar, ZI = F) #0.6
gbm.loop(expvar = AMe,
         resvar = AdultResvar,
         samples = AdultSamplesAMe,
         lr = 0.0000001,
         bf = 0.7, #tried 0.6
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = T,
         alerts = F)

AdultSamplesLagBMe <- subset(AdultSamplesLag, Year < 1981) #n=22 w/o NAs
AdultSamplesLagAMe <- subset(AdultSamplesLag, Year >= 1981) #35
# whole timeseries, only full series variables
AdultExpvarsLag12
fulltimeseries <- c("NPGO_Spring",
                    "SeaLevLA_PreW", #useless
                    "BUI33N_Spring",
                    "Stability_all", #changed from South 2018.10.01
                    "Temp_NCoast", #changed from South 2018.10.01
                    "Sal_South", #useless
                    "O2_Offsh", #changed from All 2018.10.01
                    "Sml_P_log",
                    "C_Sablefish",
                    "FishLand", #useless in loop w/ consumption
                    "Biom_Sard_Alec_log",
                    "Hake_Biom", #useless
                    "Msquid_Biom",
                    "Rockfish_Biom",
                    "Krill_mgCm2",
                    "A_Tot_B_log",
                    "Consumption")  # consumption added, remove components?
fulltimeserieslags <- c(fulltimeseries,
                       paste0(fulltimeseries, "_lag_1"),
                       paste0(fulltimeseries, "_lag_2"))
fulltimeserieslags <- fulltimeserieslags[-16] #remove atotblog
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.15_Subsets_10Loop/Fulltimeseries"))
gbm.bfcheck(samples = AdultSamplesLag, resvar = AdultResvar, ZI = F)
# [1] "  binary bag fraction must be at least 0.368"
# [1] "Gaussian bag fraction must be at least 0.368" good
match(fulltimeserieslags,colnames(AdultSamplesLag)) #debug undefined columns, needed to put log on anch sard smlp
gbm.loop(expvar = fulltimeserieslags,
         resvar = AdultResvar,
         samples = AdultSamplesLag,
         lr = 0.01,
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = F,
         alerts = F)

# pre81, only available data
BMe <- c("NPGO_Spring",
         "SeaLevLA_PreW", #useless
         "BUI33N_Spring",
         "Stability_all", #changed from South 2018.10.01
         "Temp_NCoast", #changed from South 2018.10.01
         "Sal_South", #useless
         "O2_Offsh", #changed from All 2018.10.01
         "Sml_P_log",
         "Euphausiids_log",
         "C_Sablefish",
         "FishLand", #useless in loop w/ consumption
         "Biom_Sard_Alec_log",
         "Hake_Biom", #useless
         "Msquid_Biom",
         "Rockfish_Biom",
         "Krill_mgCm2",
         "A_Tot_B_log",
         "Consumption")  # consumption added, remove components?
BMelags <- c(BMe,
                        paste0(BMe, "_lag_1"),
                        paste0(BMe, "_lag_2"))
BMelags <- BMelags[-16] #remove atotblog
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.15_Subsets_10Loop/BMe"))
gbm.bfcheck(samples = AdultSamplesLagBMe, resvar = AdultResvar, ZI = F) #0.95 BAAAD
gbm.loop(expvar = BMelags,
         resvar = AdultResvar,
         samples = AdultSamplesLagBMe,
         lr = 0.000001,
         bf = 0.98,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = F,
         alerts = F) #FAIL
# 81&after, only available data
AMe <- c("NPGO_Spring",
         "NPC_Str_Lat", #useless
         "SeaLevLA_PreW", #useless
         "BUI33N_Spring",
         "Stability_all", #changed from South 2018.10.01
         "Temp_NCoast", #changed from South 2018.10.01
         "Sal_South", #useless
         "O2_Offsh", #changed from All 2018.10.01
         "ChlA_Nearsh", #changed from All 2018.10.01
         "Sml_P_log",
         "Euphausiids_log",
         "C_Albacore", #useless
         "C_Sablefish",
         "C_ChinSal", #useless in loop w/ consumption
         "C_Halibut", #useless
         "C_SoShWa", #useless
         "C_HBW", #useless
         "C_Hsquid", #useless
         "C_SeaLion",
         "C_Murre", #useless in loop w/ consumption
         "FishLand", #useless in loop w/ consumption
         "Biom_Sard_Alec_log",
         "Hake_Biom", #useless
         "Msquid_Biom",
         "Rockfish_Biom",
         "Krill_mgCm2",
         "A_Tot_B_log",
         "Consumption")  # consumption added, remove components?
AMelags <- c(AMe,
             paste0(AMe, "_lag_1"),
             paste0(AMe, "_lag_2"))
AMelags <- AMelags[-27] #remove atotblog
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.15_Subsets_10Loop/AMe"))
gbm.bfcheck(samples = AdultSamplesLagAMe, resvar = AdultResvar, ZI = F) #0.6
gbm.loop(expvar = AMelags,
         resvar = AdultResvar,
         samples = AdultSamplesLagAMe,
         lr = 0.01,
         bf = 0.7,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = F,
         alerts = F)


#9 Expvar Lags####
library(gbm.auto)
#machine <- "/home" # linux desktop (& laptop?)
machine <- "C:/Users"# windows laptop
Annual <- read.csv(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Data Structure Template 2018.10.30.csv'), na.strings = "")
Annual <- Annual[1:(match(2017, Annual$Year)),]
source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/AddLags.R"))

#Sol & Bill3####
# good vars tried (w/ Adults only):
# biomassY-1 (got), upwelling spring Y-2, sealevel spring y-1. 70% variance? 65-69ish
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/"))
dir.create("2018.10.05_BillSolLags_10Loop")
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.05_BillSolLags_10Loop"))
Annual <- AddLags(x = Annual,
                  lagYears = 1:2,
                  toLag = c("A_Tot_B",
                            "Anch_Larvae_Peak",
                            "Anch_Egg_Peak",
                            "BUI33N_Spring",
                            "SeaLevLA_PreW"))
AdultResvar <- "A_Tot_B"
AdultSamples <- Annual[-which(is.na(Annual[AdultResvar])),] # remove NA rows
AdultExpvars <- c("A_Tot_B_lag_1",
                  "BUI33N_Spring_lag_2",
                  "SeaLevLA_PreW_lag_1")
gbm.bfcheck(samples = AdultSamples, resvar = AdultResvar, ZI = F)
# [1] "Gaussian bag fraction must be at least 0.368" good
gbm.auto(expvar = AdultExpvars,
         resvar = AdultResvar,
         samples = AdultSamples,
         lr = 0.00001,
         bf = 0.8,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = T, #F
         alerts = F) #FAILS
# model cv score: 55.63%: not great.

#all expvar lags####
#setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs"))
#dir.create("2018.10.08_AllExpvarLags")
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.08_AllExpvarLags/Simp"))
# include ALL y0 and y-1 and see if any y-1 outperform y0 and if so
# discard y0 and try y-2 ad infinitum. Easy way:

#adults####
AdultResvar <- "A_Tot_B"
AdultSamples <- Annual[-which(is.na(Annual[AdultResvar])),] # remove NA rows
AdultExpvars <- c("A_Tot_B",
                  "NPGO_Spring",
                  "NPC_Str_Lat", #useless & too few values, kills model runs
                  "SeaLevLA_PreW", #useless
                  "BUI33N_Spring",
                  "Stability_all", #changed from South 2018.10.01
                  "Temp_NCoast", #changed from South 2018.10.01
                  "Sal_South", #useless
                  "O2_Offsh", #changed from All 2018.10.01
                  "ChlA_Nearsh", #changed from All 2018.10.01
                  "Sml_P",
                  "Euphausiids",
                  "C_Albacore", #useless & too few values, kills model runs
                  "C_Sablefish",
                  "C_ChinSal", #useless in loop w/ consumption
                  "C_Halibut", #useless
                  "C_SoShWa", #useless
                  "C_HBW", #useless & too few values, kills model runs
                  "C_Hsquid", #useless & too few values, kills model runs
                  "C_SeaLion",
                  "C_Murre", #useless in loop w/ consumption
                  "FishLand", #useless in loop w/ consumption
                  "Biom_Sard_Alec",
                  "Hake_Biom", #useless
                  "Msquid_Biom",
                  "Rockfish_Biom",
                  "Krill_mgCm2",
                  "Consumption")  # consumption added, remove components?
AdultSamplesLag <- AddLags(x = AdultSamples, lagYears = 1:2, toLag = AdultExpvars)
AdultExpvarsLag12 <- c(AdultExpvars,
                       paste0(AdultExpvars, "_lag_1"),
                       paste0(AdultExpvars, "_lag_2"))
AdultExpvarsLag12 <- AdultExpvarsLag12[-1] #remove A_Tot_B as expvar
gbm.bfcheck(samples = AdultSamplesLag, resvar = AdultResvar, ZI = F)
# [1] "  binary bag fraction must be at least 0.368"
# [1] "Gaussian bag fraction must be at least 0.368" good
gbm.loop(expvar = AdultExpvarsLag12,
         resvar = AdultResvar,
         samples = AdultSamplesLag,
         lr = 0.1, #training data correlation much higher with 0.1 than 0.0000000001
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = T,
         alerts = F)


#larvae####
LarvalResvar <- "Anch_Larvae_Peak"
LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
LarvalExpvars <- c("NPGO_Spring",
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
                   "Anch_Larvae_Peak")
LarvalSamplesLag <- AddLags(x = LarvalSamples, lagYears = 1:2, toLag = LarvalExpvars)
LarvalExpvarsLag12 <- c(LarvalExpvars,
                       paste0(LarvalExpvars, "_lag_1"),
                       paste0(LarvalExpvars, "_lag_2"))
LarvalExpvarsLag12 <- LarvalExpvarsLag12[-19] #remove larval peak as expvar
gbm.bfcheck(samples = LarvalSamplesLag, resvar = LarvalResvar, ZI = F)
# [1] "  binary bag fraction must be at least 0.333"
# [1] "Gaussian bag fraction must be at least 0.333" 
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.08_AllExpvarLags/Simp"))
gbm.loop(expvar = LarvalExpvarsLag12,
         resvar = LarvalResvar,
         samples = LarvalSamplesLag,
         lr = 0.1,
         bf = 0.5, #
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = F)

#eggs####
EggResvar <- "Anch_Egg_Peak"
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]
EggExpvars <- c("A_Tot_B",
                "NPGO_Spring",
                "NPC_Str_Lat", #0inf%, frequently crashes runs as only has missing values.
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
                "Anch_Egg_Peak")
EggSamplesLag <- AddLags(x = EggSamples, lagYears = 1:2, toLag = EggExpvars)
EggExpvarsLag12 <- c(EggExpvars,
                        paste0(EggExpvars, "_lag_1"),
                        paste0(EggExpvars, "_lag_2"))
EggExpvarsLag12 <- EggExpvarsLag12[-18] #remove Anch_Egg_Peak as expvar
gbm.bfcheck(samples = EggSamplesLag, resvar = EggResvar, ZI = F)
# [1] "  binary bag fraction must be at least 0.333"
# [1] "Gaussian bag fraction must be at least 0.333"
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.08_AllExpvarLags/Simp"))
gbm.loop(expvar = EggExpvarsLag12,
         resvar = EggResvar,
         samples = EggSamplesLag,
         lr = 0.5,
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = T,
         alerts = F)

#prune lags####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.08_AllExpvarLags/Pruned"))
AdultExpvars <- c("A_Tot_B_lag_1",
                  "NPGO_Spring",
                  #"NPC_Str_Lat",
                  "SeaLevLA_PreW_lag_1",
                  "BUI33N_Spring_lag_2",
                  "Stability_all", #changed from South 2018.10.01
                  "Temp_NCoast_lag_2", #changed from South 2018.10.01
                  "Sal_South_lag_2", #useless
                  "O2_Offsh_lag_1", #changed from All 2018.10.01
                  #"ChlA_Nearsh", #changed from All 2018.10.01
                  "Sml_P",
                  "Euphausiids_lag_2",
                  #"C_Albacore", #useless & too few values, kills model runs
                  "C_Sablefish",
                  #"C_ChinSal", #useless in loop w/ consumption
                  #"C_Halibut", #useless
                  #"C_SoShWa", #useless
                  #"C_HBW", #useless & too few values, kills model runs
                  #"C_Hsquid", #useless & too few values, kills model runs
                  "C_SeaLion",
                  #"C_Murre", #useless in loop w/ consumption
                  #"FishLand", #useless in loop w/ consumption
                  "Biom_Sard_Alec",
                  "Hake_Biom_lag_2",
                  "Msquid_Biom",
                  "Rockfish_Biom_lag_2",
                  "Krill_mgCm2",
                  "Consumption_lag_2")
gbm.loop(expvar = AdultExpvars,
         resvar = AdultResvar,
         samples = AdultSamplesLag,
         lr = 0.0000001,
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = T,
         alerts = F)


LarvalExpvars <- c("NPGO_Spring",
                   #"NPC_Str_Lat",
                   "SeaLevSF_Spring_lag_2",
                   "BUI33N_Spring_lag_2",
                   "Stab_South_lag_2",
                   "Temp_South_lag_2",
                   "Sal_South_lag_1",
                   "O2AtDep_all",
                   "ChlA_all_lag_2",
                   "Sml_P",
                   "Lrg_P",
                   "Hake",
                   "Jmac_lag_1",
                   "Cmac",
                   "Catch_Sard_lag_2",
                   "Msquid_Biom",
                   "Rockfish_Biom",
                   "Krill_mgCm2",
                   "Anch_Larvae_Peak_lag_1")
gbm.loop(expvar = LarvalExpvars,
         resvar = LarvalResvar,
         samples = LarvalSamplesLag,
         lr = 0.00000001,
         bf = 0.5, #
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = F)


EggExpvars <- c("A_Tot_B_lag_2",
                "NPGO_Spring",
                #"NPC_Str_Lat", #0inf%, frequently crashes runs as only has missing values.
                "SeaLevSF_PreW_lag_1",
                "BUI33N_Spring_lag_1",
                "Stab_South",
                "Temp_South",
                "Sal_South_lag_1",
                "O2AtDep_all_lag_1",
                "Lrg_P",
                "Hake",
                "Jmac",
                "Cmac",
                "Catch_Sard",
                "Msquid_Biom_lag_1",
                "Rockfish_Biom_lag_2",
                "Krill_mgCm2",
                "Anch_Egg_Peak_lag_1")
gbm.loop(expvar = EggExpvars,
         resvar = EggResvar,
         samples = EggSamplesLag,
         lr = 0.000000001,
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = T,
         alerts = F)
# egg: 81% sum av inf% fromo sard (3 lags), hake, AtotB (3 lags), Egg (lag1&2)
# Why am I discarding multiple lag years but keeping (e.g.) NPGO-2 simply cos
# it's influential at all (av inf 0.08%)

# Compare model performance pruned or not. Why not have simp on?
# Adults all: 0.6607 pruned: 0.66821 (all are max cv) allsimp: 0.675 allsimp0.1 0.851
# Larvae all: 0.813 pruned: 0.801 allsimp: 0.805 allsimp0.1 0.892
# Eggs all: 0.774 pruned: 0.7501 allsimp: 0.761 allsimp0.1 0.968

#10 logs####
rm(list = ls()) # remove everything if you crashed before
library(devtools)
install_github("SimonDedman/gbm.auto") # update gbm.auto to latest
library(gbm.auto)
#machine <- "/home" # linux desktop (& laptop?)
machine <- "C:/Users"# windows laptop
Annual <- read.csv(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Data Structure Template 2018.10.30.csv'), na.strings = "")
Annual <- Annual[1:(match(2017, Annual$Year)),]
source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/AddLags.R"))
source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/AddLogs.R"))
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.11_AllExpvarLagLogs0.1"))
# include ALL y0 and y-1 and see if any y-1 outperform y0 and if so
# discard y0 and try y-2 ad infinitum. Easy way:

#adults####
AdultResvar <- "A_Tot_B"
AdultSamples <- Annual[-which(is.na(Annual[AdultResvar])),] # remove NA rows
AdultExpvars <- c("A_Tot_B",
                  "NPGO_Spring",
                  "NPC_Str_Lat", #useless & too few values, kills model runs
                  "SeaLevLA_PreW", #useless
                  "BUI33N_Spring",
                  "Stability_all", #changed from South 2018.10.01
                  "Temp_NCoast", #changed from South 2018.10.01
                  "Sal_South", #useless
                  "O2_Offsh", #changed from All 2018.10.01
                  "ChlA_Nearsh", #changed from All 2018.10.01
                  "Sml_P",
                  "Euphausiids",
                  "C_Albacore", #useless & too few values, kills model runs
                  "C_Sablefish",
                  "C_ChinSal", #useless in loop w/ consumption
                  "C_Halibut", #useless
                  "C_SoShWa", #useless
                  "C_HBW", #useless & too few values, kills model runs
                  "C_Hsquid", #useless & too few values, kills model runs
                  "C_SeaLion",
                  "C_Murre", #useless in loop w/ consumption
                  "FishLand", #useless in loop w/ consumption
                  "Biom_Sard_Alec",
                  "Hake_Biom", #useless
                  "Msquid_Biom",
                  "Rockfish_Biom",
                  "Krill_mgCm2",
                  "Consumption")  # consumption added, remove components?
# for(i in c("A_Tot_B",
#            "ChlA_Nearsh", #changed from All 2018.10.01
#            "Sml_P",
#            "Euphausiids",
#            "C_Albacore", #useless & too few values, kills model runs
#            "C_Sablefish",
#            "C_ChinSal", #useless in loop w/ consumption
#            "C_Halibut", #useless
#            "C_SoShWa", #useless
#            "C_HBW", #useless & too few values, kills model runs
#            "C_Hsquid", #useless & too few values, kills model runs
#            "C_SeaLion",
#            "C_Murre", #useless in loop w/ consumption
#            "FishLand", #useless in loop w/ consumption
#            "Biom_Sard_Alec",
#            "Hake_Biom", #useless
#            "Msquid_Biom",
#            "Rockfish_Biom",
#            "Krill_mgCm2",
#            "Consumption")) {
#   plot(x = AdultSamples[,"Year"],
#        y = AdultSamples[,i],
#        main = i)
# }

AdultSamplesLog <- AddLogs(x = AdultSamples, toLog = c("A_Tot_B",
                                                       "Sml_P",
                                                       "Euphausiids",
                                                       "Biom_Sard_Alec"))
AdultExpvars <- c("NPGO_Spring",
                  "NPC_Str_Lat", #useless & too few values, kills model runs
                  "SeaLevLA_PreW", #useless
                  "BUI33N_Spring",
                  "Stability_all", #changed from South 2018.10.01
                  "Temp_NCoast", #changed from South 2018.10.01
                  "Sal_South", #useless
                  "O2_Offsh", #changed from All 2018.10.01
                  "ChlA_Nearsh", #changed from All 2018.10.01
                  "C_Albacore", #useless & too few values, kills model runs
                  "C_Sablefish",
                  "C_ChinSal", #useless in loop w/ consumption
                  "C_Halibut", #useless
                  "C_SoShWa", #useless
                  "C_HBW", #useless & too few values, kills model runs
                  "C_Hsquid", #useless & too few values, kills model runs
                  "C_SeaLion",
                  "C_Murre", #useless in loop w/ consumption
                  "FishLand", #useless in loop w/ consumption
                  "Hake_Biom", #useless
                  "Msquid_Biom",
                  "Rockfish_Biom",
                  "Krill_mgCm2",
                  "Consumption",
                  "A_Tot_B_log",
                  "Sml_P_log",
                  "Euphausiids_log",
                  "Biom_Sard_Alec_log")  # consumption added, remove components?

AdultSamplesLag <- AddLags(x = AdultSamplesLog, lagYears = 1:2, toLag = AdultExpvars)
AdultExpvarsLag12 <- c(AdultExpvars,
                       paste0(AdultExpvars, "_lag_1"),
                       paste0(AdultExpvars, "_lag_2"))
AdultExpvarsLag12 <- AdultExpvarsLag12[-25] #remove A_Tot_B_log as expvar
gbm.bfcheck(samples = AdultSamplesLag, resvar = AdultResvar, ZI = F)
# [1] "  binary bag fraction must be at least 0.368"
# [1] "Gaussian bag fraction must be at least 0.368" good
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.11_AllExpvarLagLogs0.1"))
AdultResvar <- "A_Tot_B_log" #tried log and not
gbm.loop(expvar = AdultExpvarsLag12,
         resvar = AdultResvar,
         samples = AdultSamplesLag,
         lr = 0.01, #0.1 
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = T,
         alerts = F)
# [1] "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX      Loop 10 complete        XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
# Error in `[.data.frame`(get(paste0("gausline_", m)), , (2:(1 + loops))) : 
#   undefined columns selected

#larvae####
LarvalResvar <- "Anch_Larvae_Peak"
LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
LarvalExpvars <- c("NPGO_Spring",
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
                   "Anch_Larvae_Peak")
# for(i in c("NPGO_Spring",
#            "NPC_Str_Lat",
#            "SeaLevSF_Spring",
#            "BUI33N_Spring",
#            "Stab_South",
#            "Temp_South",
#            "Sal_South",
#            "O2AtDep_all",
#            "ChlA_all",
#            "Sml_P", "Lrg_P",
#            "Hake", "Jmac", "Cmac",
#            "Catch_Sard",
#            "Msquid_Biom",
#            "Rockfish_Biom",
#            "Krill_mgCm2",
#            "Anch_Larvae_Peak")) {
#   plot(x = LarvalSamples[,"Year"],
#        y = LarvalSamples[,i],
#        main = i)
# }
LarvalSamplesLog <- AddLogs(x = LarvalSamples, toLog = c("Sml_P",
                                                         "Lrg_P",
                                                         "Jmac",
                                                         "Cmac",
                                                         "Anch_Larvae_Peak"))
LarvalExpvars <- c("NPGO_Spring",
                   "NPC_Str_Lat",
                   "SeaLevSF_Spring",
                   "BUI33N_Spring",
                   "Stab_South",
                   "Temp_South",
                   "Sal_South",
                   "O2AtDep_all",
                   "ChlA_all",
                   "Sml_P_log",
                   "Lrg_P_log",
                   "Hake",
                   "Jmac_log",
                   "Cmac_log",
                   "Catch_Sard",
                   "Msquid_Biom",
                   "Rockfish_Biom",
                   "Krill_mgCm2",
                   "Anch_Larvae_Peak_log")
LarvalSamplesLag <- AddLags(x = LarvalSamplesLog, lagYears = 1:2, toLag = LarvalExpvars)
LarvalExpvarsLag12 <- c(LarvalExpvars,
                        paste0(LarvalExpvars, "_lag_1"),
                        paste0(LarvalExpvars, "_lag_2"))
LarvalExpvarsLag12 <- LarvalExpvarsLag12[-19] #remove larval peak as expvar also remove logs.
# gbm.bfcheck(samples = LarvalSamplesLag, resvar = LarvalResvar, ZI = F)
# [1] "  binary bag fraction must be at least 0.333"
# [1] "Gaussian bag fraction must be at least 0.333" 
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.11_AllExpvarLagLogs0.1"))
LarvalResvar <- "Anch_Larvae_Peak_log"
gbm.loop(expvar = LarvalExpvarsLag12,
         resvar = LarvalResvar,
         samples = LarvalSamplesLag,
         lr = 0.01,  #tried 0.1 0.05
         bf = 0.5, #
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = F)

#eggs####
EggResvar <- "Anch_Egg_Peak"
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]
EggExpvars <- c("A_Tot_B",
                "NPGO_Spring",
                "NPC_Str_Lat", #0inf%, frequently crashes runs as only has missing values.
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
                "Anch_Egg_Peak")
# plot(x = LarvalSamples[,"Year"],y = LarvalSamples[,"Anch_Egg_Peak"],main = "Anch_Egg_Peak")
EggSamplesLog <- AddLogs(x = EggSamples, toLog = c("A_Tot_B",
                                                   "Lrg_P",
                                                   "Jmac",
                                                   "Cmac",
                                                   "Anch_Egg_Peak"))
EggExpvars <- c("A_Tot_B_log",
                "NPGO_Spring",
                "NPC_Str_Lat", #0inf%, frequently crashes runs as only has missing values.
                "SeaLevSF_PreW",
                "BUI33N_Spring",
                "Stab_South",
                "Temp_South",
                "Sal_South",
                "O2AtDep_all",
                "Lrg_P_log",
                "Hake", "Jmac_log", "Cmac_log",
                "Catch_Sard",
                "Msquid_Biom",
                "Rockfish_Biom",
                "Krill_mgCm2",
                "Anch_Egg_Peak_log")
EggSamplesLag <- AddLags(x = EggSamplesLog, lagYears = 1:2, toLag = EggExpvars)
EggExpvarsLag12 <- c(EggExpvars,
                     paste0(EggExpvars, "_lag_1"),
                     paste0(EggExpvars, "_lag_2"))
EggExpvarsLag12 <- EggExpvarsLag12[-18] #remove Anch_Egg_Peak (log) as expvar
gbm.bfcheck(samples = EggSamplesLag, resvar = EggResvar, ZI = F)
# [1] "  binary bag fraction must be at least 0.333"
# [1] "Gaussian bag fraction must be at least 0.333"
EggResvar <- "Anch_Egg_Peak_log"
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.11_AllExpvarLagLogs0.1"))
gbm.loop(expvar = EggExpvarsLag12,
         resvar = EggResvar,
         samples = EggSamplesLag,
         lr = 0.05, #ran these with 0.000000001 and tried 0.1 also
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = T,
         alerts = F)
# (all are max cv)
# Adults all: 0.6607 pruned: 0.66821 allsimp: 0.675 allsimp0.1 0.851 logs 0.705 explogresnot 0.676
# Larvae all: 0.813 pruned: 0.801 allsimp: 0.805 allsimp0.1 0.892 logs 0.807 explogresnot 0.805
# Eggs all: 0.774 pruned: 0.7501 allsimp: 0.761 allsimp0.1 0.968 logs 0.846 explogresnot 0.761


#11 Plot all data series####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/Detrend"))
options(scipen=5)
for(i in AdultExpvars){
  print(i)
  par(mar = rep(2, 4))
  png(filename = paste0(i,".png"),
      width = 4*480, height = 4*480, units = "px", pointsize = 4*12,
      bg = "white", res = NA, family = "", type = "cairo-png")
  plot(x = AdultSamples["Year"][[1]],
       y = AdultSamples[,i],
       main = i,
       pch = 20,
       type = "o",
       ylab = "",
       xlab = "")
  dev.off()
}

#12 logged resvar not expvar####
rm(list = ls()) # remove everything if you crashed before
# install.packages("devtools")
library(devtools)
install_github("SimonDedman/gbm.auto") # update gbm.auto to latest
library(gbm.auto)
#machine <- "/home" # linux desktop (& laptop?)
machine <- "C:/Users"# windows laptop
Annual <- read.csv(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Data Structure Template 2018.10.30.csv'), na.strings = "")
Annual <- Annual[1:(match(2017, Annual$Year)),]
source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/AddLags.R"))
source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/AddLogs.R"))

#adults####
AdultResvar <- "A_Tot_B"
AdultSamples <- Annual[-which(is.na(Annual[AdultResvar])),] # remove NA rows
AdultSamplesLog <- AddLogs(x = AdultSamples, toLog = "A_Tot_B")
AdultExpvars <- c("NPGO_Spring",
                  "NPC_Str_Lat", #useless & too few values, kills model runs
                  "SeaLevLA_PreW", #useless
                  "BUI33N_Spring",
                  "Stability_all", #changed from South 2018.10.01
                  "Temp_NCoast", #changed from South 2018.10.01
                  "Sal_South", #useless
                  "O2_Offsh", #changed from All 2018.10.01
                  "ChlA_Nearsh", #changed from All 2018.10.01
                  "C_Albacore", #useless & too few values, kills model runs
                  "C_Sablefish",
                  "C_ChinSal", #useless in loop w/ consumption
                  "C_Halibut", #useless
                  "C_SoShWa", #useless
                  "C_HBW", #useless & too few values, kills model runs
                  "C_Hsquid", #useless & too few values, kills model runs
                  "C_SeaLion",
                  "C_Murre", #useless in loop w/ consumption
                  "FishLand", #useless in loop w/ consumption
                  "Hake_Biom", #useless
                  "Msquid_Biom",
                  "Rockfish_Biom",
                  "Krill_mgCm2",
                  "Consumption",
                  "A_Tot_B_log",
                  "Sml_P",
                  "Euphausiids",
                  "Biom_Sard_Alec")  # consumption added, remove components?

AdultSamplesLag <- AddLags(x = AdultSamplesLog, lagYears = 1:2, toLag = AdultExpvars)
AdultExpvarsLag12 <- c(AdultExpvars,
                       paste0(AdultExpvars, "_lag_1"),
                       paste0(AdultExpvars, "_lag_2"))
AdultExpvarsLag12 <- AdultExpvarsLag12[-25] #remove A_Tot_B_log as expvar
AdultResvar <- "A_Tot_B_log"
gbm.bfcheck(samples = AdultSamplesLag, resvar = AdultResvar, ZI = F) #0.368 good
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.18_ResvarlogExpvarLag0.1"))
gbm.loop(expvar = AdultExpvarsLag12,
         resvar = AdultResvar,
         samples = AdultSamplesLag,
         lr = 0.01, 
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = T,
         alerts = F)

#larvae####
LarvalResvar <- "Anch_Larvae_Peak"
LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
LarvalExpvars <- c("NPGO_Spring",
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
                   "Anch_Larvae_Peak")
LarvalSamplesLog <- AddLogs(x = LarvalSamples, toLog = "Anch_Larvae_Peak")
LarvalExpvars <- c("NPGO_Spring",
                   "NPC_Str_Lat",
                   "SeaLevSF_Spring",
                   "BUI33N_Spring",
                   "Stab_South",
                   "Temp_South",
                   "Sal_South",
                   "O2AtDep_all",
                   "ChlA_all",
                   "Sml_P",
                   "Lrg_P",
                   "Hake",
                   "Jmac",
                   "Cmac",
                   "Catch_Sard",
                   "Msquid_Biom",
                   "Rockfish_Biom",
                   "Krill_mgCm2",
                   "Anch_Larvae_Peak_log")
LarvalSamplesLag <- AddLags(x = LarvalSamplesLog, lagYears = 1:2, toLag = LarvalExpvars)
LarvalExpvarsLag12 <- c(LarvalExpvars,
                        paste0(LarvalExpvars, "_lag_1"),
                        paste0(LarvalExpvars, "_lag_2"))
LarvalExpvarsLag12 <- LarvalExpvarsLag12[-19] #remove larval peak as expvar also remove logs.
LarvalResvar <- "Anch_Larvae_Peak_log"
gbm.bfcheck(samples = LarvalSamplesLag, resvar = LarvalResvar, ZI = F) #0.333
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.18_ResvarlogExpvarLag0.1"))
gbm.loop(expvar = LarvalExpvarsLag12,
         resvar = LarvalResvar,
         samples = LarvalSamplesLag,
         lr = 0.01,  #tried 0.1 0.05
         bf = 0.5, #
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = F)

#eggs####
EggResvar <- "Anch_Egg_Peak"
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]
EggExpvars <- c("A_Tot_B",
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
                "Anch_Egg_Peak")
EggSamplesLog <- AddLogs(x = EggSamples, toLog = "Anch_Egg_Peak")
EggExpvars <- c("A_Tot_B",
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
                "Anch_Egg_Peak_log")
EggSamplesLag <- AddLags(x = EggSamplesLog, lagYears = 1:2, toLag = EggExpvars)
EggExpvarsLag12 <- c(EggExpvars,
                     paste0(EggExpvars, "_lag_1"),
                     paste0(EggExpvars, "_lag_2"))
EggExpvarsLag12 <- EggExpvarsLag12[-18] #remove Anch_Egg_Peak (log) as expvar
EggResvar <- "Anch_Egg_Peak_log"
gbm.bfcheck(samples = EggSamplesLag, resvar = EggResvar, ZI = F) #0.333
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.18_ResvarlogExpvarLag0.1"))
gbm.loop(expvar = EggExpvarsLag12,
         resvar = EggResvar,
         samples = EggSamplesLag,
         lr = 0.05,
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = T,
         alerts = F)


#13 calculate optimal subset splits####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.18_ResvarlogExpvarLag0.1"))
setwd("10/A_Tot_B_log")
subs <- gbm.subset(x = AdultExpvarsLag12, #from #12
                   fams = "Gaus",
                   loop = FALSE)
rm(subs)
rm(subsetsplits)

source(paste0(machine, '/simon/Dropbox/Galway/Analysis/R/gbm.auto/R/gbm.subset.R'))
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.18_ResvarlogExpvarLag0.1"))
setwd("A_Tot_B_log")
subsloop <- gbm.subset(x = AdultExpvarsLag12, #from #12
                   fams = "Gaus",
                   loop = TRUE)
write.csv(subsloop, file = "gbmSubsetLoopAdultsLog.csv")
# manual choices based on rounded 0 points from before:
# sardine: 120000
# hake: 1500000
# anchovyY-1: 410000 log: log1p(410000) #12.92391

# gbm.subset choices:
# sardine: 104620
# hake: 1215618
# anchovyY-1: 410000 log: log1p(410000) #12.0593122308157
expm1(12.05931223081570) #172699.2
expm1(12.92391) #409998

# differences:
(120000 - 104620) / 120000 # 0.1281667 sard 12% smaller
(1500000 - 1215618) / 1500000 # 0.189588 hake 19% smaller
(410000 - 172699.2) / 410000 # 0.5787824 anchovy 58% smaller
(12.92391 - 12.0593122308157) / 12.92391 # 0.06689909 logged anchovy 7% smaller


#14 Pairs: consumption vs lagged anchovy####
source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/pairPlots.R"))
colnames(AdultSamplesLag) #sablefish 101, checking against too many in 1 go, split up
ConsumptionExpvars <- c("A_Tot_B_log",
                        "A_Tot_B_log_lag_1",
                        "A_Tot_B_log_lag_2",
                        "C_Hake",
                        "C_Cmac",
                        "C_SeaLion",
                        "C_Albacore",
                        "C_Sablefish",
                        "C_ChinSal",
                        "C_Halibut",
                        "C_Murre",
                        "C_SoShWa",
                        "C_HBW",
                        "C_Hsquid")

pairs(AdultSamplesLag[ConsumptionExpvars],
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")

BiomassExpvars <- c("A_Tot_B_log",
                    "A_Tot_B_log_lag_1",
                    "A_Tot_B_log_lag_2",
                    "Consumption",
                    "Hake_Biom",
                    "Hake",
                    "Krill_mgCm2",
                    "Lrg_P",
                    "Jmac",
                    "Msquid_Biom",
                    "Rockfish_Biom",
                    "CommonMurre")

pairs(AdultSamplesLag[BiomassExpvars],
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")

#non logged anchovy
ConsumptionExpvars2 <- c("A_Tot_B",
                        "A_Tot_B_lag_1",
                        "A_Tot_B_lag_2",
                        "C_Hake",
                        "C_Cmac",
                        "C_SeaLion",
                        "C_Albacore",
                        "C_Sablefish",
                        "C_ChinSal",
                        "C_Halibut",
                        "C_Murre",
                        "C_SoShWa",
                        "C_HBW",
                        "C_Hsquid")
pairs(AdultSamplesLag[ConsumptionExpvars2],
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")

# non lagged, logged & unlogged anchovy abundance (A/L/E) vs lagged (123) predator consumption & abundance.
# AdultSamples <- Annual[-which(is.na(Annual[AdultResvar])),]
# LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
# EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]
AllAdultLag <- AddLags(x = AdultSamples, lagYears = 1:3, toLag = colnames(AdultSamples))
AllLarvalLag <- AddLags(x = LarvalSamples, lagYears = 1:3, toLag = colnames(LarvalSamples))
AllEggLag <- AddLags(x = EggSamples, lagYears = 1:3, toLag = colnames(EggSamples))

colnames(AllAdultLag)

ConsumptionExpvars3 <- c("A_Tot_B",
                        "C_Hake",
                        "C_Cmac",
                        "C_SeaLion",
                        "C_Albacore",
                        "C_Sablefish",
                        "C_ChinSal",
                        "C_Halibut",
                        "C_Murre",
                        "C_SoShWa",
                        "C_HBW",
                        "C_Hsquid")
ConsumptionExpvars3_123 <- c(ConsumptionExpvars3,
                    paste0(ConsumptionExpvars3, "_lag_1"),
                    paste0(ConsumptionExpvars3, "_lag_2"),
                    paste0(ConsumptionExpvars3, "_lag_3"))

pairs(AllAdultLag[ConsumptionExpvars3_123[c(1,2,26,38,3,27,39,4,28,40,5,29,41)]],
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
pairs(AllAdultLag[ConsumptionExpvars3_123[c(1,6,30,42,7,31,43,8,32,44,9,33,45)]],
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
pairs(AllAdultLag[ConsumptionExpvars3_123[c(1,10,34,46,11,35,47,12,36,48)]],
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")

AllAdultLag123 <- c(AdultExpvars,
                       paste0(AdultExpvars, "_lag_1"),
                       paste0(AdultExpvars, "_lag_2"))


BiomassExpvars <- c("A_Tot_B",
                    "Consumption",
                    "Hake_Biom",
                    "Krill_mgCm2",
                    "Sml_P",
                    "Euphausiids",
                    "Lrg_P",
                    "Jmac",
                    "Cmac",
                    "SeaLion",
                    "Albacore",
                    "Sablefish",
                    "ChinSal",
                    "Halibut",
                    "CommonMurre",
                    "SoShWa",
                    "HBW",
                    "Hsquid",
                    "Msquid_Biom",
                    "Rockfish_Biom",
                    "Biom_Sard_Alec",
                    "Rockfish_Biom")
BiomassExpvars3_123 <- c(BiomassExpvars,
                         paste0(BiomassExpvars, "_lag_1"),
                         paste0(BiomassExpvars, "_lag_2"),
                         paste0(BiomassExpvars, "_lag_3"))
for(n in c(1,4,7,10,13,16,19)){
pairs(AllAdultLag[BiomassExpvars3_123[c(1,
                                        1+n,24+n,47+n,70+n,
                                        2+n,25+n,48+n,71+n,
                                        3+n,26+n,49+n,72+n)]],
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")
}


pairs(AllAdultLag[BiomassExpvars3_123[c(1,
                                        1+22,24+22,47+22,70+22)]],
      lower.panel = panel.lm,
      upper.panel = panel.cor,
      diag.panel = panel.hist,
      main = "pair plots of variables")

#15 Adult BRT consumption w/o components####
# Logged Adults only, lagged consumption+others 123
# Choose best 0/1/2/3 for each var as normal

AdultResvar <- "A_Tot_B"
AdultSamples <- Annual[-which(is.na(Annual[AdultResvar])),] # remove NA rows
AdultExpvars <- c("A_Tot_B",
                  "NPGO_Spring",
                  "NPC_Str_Lat",
                  "SeaLevLA_PreW",
                  "BUI33N_Spring",
                  "Stability_all",
                  "Temp_NCoast",
                  "Sal_South",
                  "O2_Offsh",
                  "ChlA_Nearsh",
                  "Sml_P",
                  "Euphausiids",
                  "FishLand",
                  "Biom_Sard_Alec",
                  "Hake_Biom",
                  "Msquid_Biom",
                  "Rockfish_Biom",
                  "Krill_mgCm2",
                  "Consumption")

AdultSamplesLog <- AddLogs(x = AdultSamples, toLog = c("A_Tot_B",
                                                       "Sml_P",
                                                       "Euphausiids",
                                                       "Biom_Sard_Alec"))
AdultExpvars <- c("NPGO_Spring",
                  "NPC_Str_Lat",
                  "SeaLevLA_PreW",
                  "BUI33N_Spring",
                  "Stability_all",
                  "Temp_NCoast",
                  "Sal_South",
                  "O2_Offsh",
                  "ChlA_Nearsh",
                  "FishLand",
                  "Hake_Biom",
                  "Msquid_Biom",
                  "Rockfish_Biom",
                  "Krill_mgCm2",
                  "Consumption",
                  "A_Tot_B_log",
                  "Sml_P_log",
                  "Euphausiids_log",
                  "Biom_Sard_Alec_log")

AdultSamplesLag <- AddLags(x = AdultSamplesLog, lagYears = 1:3, toLag = AdultExpvars)
AdultExpvarsLag123 <- c(AdultExpvars,
                       paste0(AdultExpvars, "_lag_1"),
                       paste0(AdultExpvars, "_lag_2"),
                       paste0(AdultExpvars, "_lag_3"))
AdultExpvarsLag123 <- AdultExpvarsLag123[-16] #remove A_Tot_B_log (log) as expvar
gbm.bfcheck(samples = AdultSamplesLag, resvar = "A_Tot_B_log", ZI = F)
# [1] "  binary bag fraction must be at least 0.3684211"
# [1] "Gaussian bag fraction must be at least 0.3684211" good
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.24_AlogExpLag1230.1cons"))
AdultResvar <- "A_Tot_B_log"
gbm.loop(expvar = AdultExpvarsLag123,
         resvar = AdultResvar,
         samples = AdultSamplesLag,
         lr = 0.03, #0.1 
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = T,
         alerts = F)

#16 Adult BRT abundance lags####
# Logged Adults only, lagged abundance + others 123
# Choose best 0/1/2/3 for each var as normal?

AdultResvar <- "A_Tot_B"
AdultSamples <- Annual[-which(is.na(Annual[AdultResvar])),] # remove NA rows
colnames(AdultSamples)
AdultExpvars <- c("NPGO_Spring",
                  "SeaLevLA_PreW",
                  "BUI33N_Spring",
                  "Stability_all",
                  "Temp_NCoast",
                  "Sal_South",
                  "O2_Offsh",
                  "ChlA_Nearsh",
                  "FishLand",
                  "Hake_Biom",
                  "Msquid_Biom",
                  "Rockfish_Biom",
                  "Krill_mgCm2",
                  "SeaLion",
                  "Albacore",
                  "Sablefish",
                  "ChinSal",
                  "Halibut",
                  "SoShWa",
                  "HBW",
                  "Hsquid",
                  "A_Tot_B_log",
                  "Sml_P_log",
                  "Euphausiids_log",
                  "Biom_Sard_Alec_log")

AdultSamplesLog <- AddLogs(x = AdultSamples, toLog = c("A_Tot_B",
                                                       "Sml_P",
                                                       "Euphausiids",
                                                       "Biom_Sard_Alec"))

AdultSamplesLag <- AddLags(x = AdultSamplesLog, lagYears = 1:3, toLag = AdultExpvars)
AdultExpvarsLag123 <- c(AdultExpvars,
                        paste0(AdultExpvars, "_lag_1"),
                        paste0(AdultExpvars, "_lag_2"),
                        paste0(AdultExpvars, "_lag_3"))
AdultExpvarsLag123 <- AdultExpvarsLag123[-24] #remove A_Tot_B_log (log) as expvar
gbm.bfcheck(samples = AdultSamplesLag, resvar = "A_Tot_B_log", ZI = F)
# [1] "  binary bag fraction must be at least 0.3684211"
# [1] "Gaussian bag fraction must be at least 0.3684211" good
AdultResvar <- "A_Tot_B_log"
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.24_AlogExpLag1230.1abund"))
gbm.loop(expvar = AdultExpvarsLag123,
         resvar = AdultResvar,
         samples = AdultSamplesLag,
         lr = 0.08, #0.1 
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = T,
         alerts = F)
colnames(AdultSamplesLag)

#17 updated var model reruns & subsets####
rm(list = ls()) # remove everything if you crashed before
library(devtools)
install_github("SimonDedman/gbm.auto") # update gbm.auto to latest
library(gbm.auto)
#machine <- "/home" # linux desktop (& laptop?)
machine <- "C:/Users"# windows laptop
source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/AddLags.R"))
source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/AddLogs.R"))
Annual <- read.csv(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Data Structure Template 2018.10.30.csv'),
                   na.strings = "")
Annual <- Annual[1:(match(2017, Annual$Year)),]

#ADULTS all data 51:end (all)####
AdultResvar <- "A_Tot_B"
AdultSamples <- Annual[-which(is.na(Annual[AdultResvar])),] # remove NA rows
colnames(AdultSamples)
AdultSamplesLog <- AddLogs(x = AdultSamples, toLog = c("A_Tot_B",
                                                       "Sml_P",
                                                       #"Euphausiids",
                                                       "Biom_Sard_Alec"))
AdultExpvars <- c("NPGO_Spring", #ABUNDANCE NO CONSUMPTION
                  "SeaLevLA_PreW",
                  "BUI33N_Spring",
                  "Stability_all",
                  "Temp_NCoast",
                  "Sal_South",
                  "O2_Offsh",
                  "ChlA_Nearsh",
                  "FishLand",
                  "Hake_Biom",
                  "Msquid_Biom",
                  "Rockfish_Biom",
                  "Krill_mgCm2",
                  "SeaLion",
                  "Albacore",
                  "Sablefish",
                  "ChinSal",
                  "Halibut",
                  "SoShWa",
                  "HBW",
                  "Hsquid",
                  "A_Tot_B",
                  "Sml_P_log",
                  #"Euphausiids", #removed
                  #"Consumption", #either this or pred abunds no both
                  "Biom_Sard_Alec_log")
AdultSamplesLag <- AddLags(x = AdultSamplesLog, lagYears = 1:3, toLag = AdultExpvars)
# lagyr1&0 contributed 7% av.inf before. Remove for simplicity, speed and data assess defensibility
# no reason to exclude anchovy biomass lags however; remove L0&1 for others next

AdultExpvarsLag123 <- c(AdultExpvars,
                        paste0(AdultExpvars, "_lag_1"),
                        paste0(AdultExpvars, "_lag_2"),
                        paste0(AdultExpvars, "_lag_3"))
AdultExpvarsLag123 <- AdultExpvarsLag123[c(46, 49:57, 59:96)] #remove hakeY2 & lag0&1 expvars except A
#hakeY2 relationship unexpectedly positive, Y0 1 & 3 all negative. Indexing something?

gbm.bfcheck(samples = AdultSamplesLag, resvar = "A_Tot_B_log", ZI = F)
# [1] "  binary bag fraction must be at least 0.3684211"
# [1] "Gaussian bag fraction must be at least 0.3684211" good
AdultResvar <- "A_Tot_B_log"
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.30_AlogExpLag23abund"))
gbm.loop(expvar = AdultExpvarsLag123,
         resvar = AdultResvar,
         samples = AdultSamplesLag,
         lr = 0.01, #0.1 
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = T,
         alerts = F)
#library(beepr)
beep(8)


#all data 57:end####
AdultSamplesLag57 <- subset(AdultSamplesLag, Year >= 1957) #n=51
gbm.bfcheck(samples = AdultSamplesLag57, resvar = "A_Tot_B_log", ZI = F) #0.412 good
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.30_AlogExpLag23abund"))
gbm.loop(expvar = AdultExpvarsLag123,
         resvar = AdultResvar,
         samples = AdultSamplesLag57,
         lr = 0.01, #0.1 
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = T,
         alerts = F)
beep(8)



#all data 64:end####
AdultSamplesLag64 <- subset(AdultSamplesLag, Year >= 1964) #n=44
gbm.bfcheck(samples = AdultSamplesLag64, resvar = "A_Tot_B_log", ZI = F) #0.477 good
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.30_AlogExpLag23abund"))
gbm.loop(expvar = AdultExpvarsLag123,
         resvar = AdultResvar,
         samples = AdultSamplesLag64,
         lr = 0.01, #0.1 
         bf = 0.6,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,  #simp failed @ 0.001 & bf0.7
         multiplot = F,
         varint = T,
         alerts = F)
beep(8)

#all data 81:end####
AdultSamplesLag81 <- subset(AdultSamplesLag, Year >= 1981) #n=35
gbm.bfcheck(samples = AdultSamplesLag81, resvar = "A_Tot_B_log", ZI = F) #0.6
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.30_AlogExpLag23abund"))
gbm.loop(expvar = AdultExpvarsLag123,
         resvar = AdultResvar,
         samples = AdultSamplesLag81,
         lr = 0.01, #0.1 
         bf = 0.7,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F,
         multiplot = F,
         varint = T,
         alerts = F)
beep(8)

#only full ts data all ts####
#manually edit expvars
AdultExpvarsLagFullTS <- AdultExpvarsLag123[-c(9,15,17:21,32,39,41:45)] #remove:
# chlA (online 81) albacore 93, chinsal 70 halibut 71 SOSH 87 HBW 91 Hsq 97
# done a better way below since this uses colnumbers which can change
gbm.bfcheck(samples = AdultSamplesLag, resvar = "A_Tot_B_log", ZI = F) # 0.3684211 good
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.30_AlogExpLag23abund"))
gbm.loop(expvar = AdultExpvarsLagFullTS,
         resvar = AdultResvar,
         samples = AdultSamplesLag,
         lr = 0.01, #0.1 
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = T,
         alerts = F)
beep(8)

#TODO only present sealion & tuna years####
# need tuna


#LARVAE all data 51:end (all)####
LarvalResvar <- "Anch_Larvae_Peak"
LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
LarvalSamplesLog <- AddLogs(x = LarvalSamples, toLog = c("Anch_Larvae_Peak","Sml_P","Lrg_P",
                                                         "Jmac", "Cmac","Biom_Sard_Alec","A_Tot_B"))
LarvalExpvars <- c("NPGO_Spring",
                   "NPC_Str_Lat", #useless in all TS, has inf later given short ts data?
                   "SeaLevSF_Spring",
                   "BUI33N_Spring",
                   "Stab_South",
                   "Temp_South",
                   "Sal_South",
                   "O2AtDep_all",
                   "ChlA_all",
                   "Sml_P_log",
                   "Lrg_P_log", #UP relationship
                   "Hake", #change to biom? No. Both equally acquirable & biom
                   #uses Andre's 51:65 calcs, high variance vs rest of data. Has
                   #UP relationship though.
                   "Jmac_log", #UP relationship
                   "Cmac_log",
                   "Biom_Sard_Alec_log", #changed from catch. catch: much higher inf% but
                   #biased & slow to acquire, needs monthly reprofiling also.
                   "Msquid_Biom", #UP w/ y-2
                   "Rockfish_Biom", #could eat E&L but have U.P./dome relationship
                   "Krill_mgCm2", #UN relationship
                   "A_Tot_B_log") #remove y0 from expvar
LarvalSamplesLag <- AddLags(x = LarvalSamplesLog, lagYears = 1:3, toLag = LarvalExpvars) #extended to 3 to test
LarvalExpvarsLag123 <- c(LarvalExpvars,
                         paste0(LarvalExpvars, "_lag_1"),
                         paste0(LarvalExpvars, "_lag_2"),
                         paste0(LarvalExpvars, "_lag_3"))
#remove A_Tot_B_log (circular) & useless bio lagyrs
LarvalExpvarsExclude <- c("A_Tot_B_log","ChlA_all","Sml_P_log","Lrg_P_log","Hake",
                          "Jmac_log","Cmac_log","Biom_Sard_Alec_log","Msquid_Biom",
                          "Rockfish_Biom","Krill_mgCm2","ChlA_all_lag_1",
                          "Sml_P_log_lag_1","Lrg_P_log_lag_1","Hake_lag_1",
                          "Jmac_log_lag_1","Cmac_log_lag_1","Biom_Sard_Alec_log_lag_1",
                          "Msquid_Biom_lag_1","Rockfish_Biom_lag_1","Krill_mgCm2_lag_1")
LarvalExpvarsExcludeNos <- match(LarvalExpvarsExclude, LarvalExpvarsLag123)
LarvalExpvarsLag123 <- LarvalExpvarsLag123[-LarvalExpvarsExcludeNos]

LarvalResvar <- "Anch_Larvae_Peak_log"
gbm.bfcheck(samples = LarvalSamplesLag, resvar = LarvalResvar, ZI = F) #0.333
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.30_AlogExpLag23abund"))
#library(beepr)
gbm.loop(expvar = LarvalExpvarsLag123,
         resvar = LarvalResvar,
         samples = LarvalSamplesLag,
         lr = 0.01, 
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = F,
         cleanup = T)
beep(8)


#check influence by lag year, remove any years?
#17/19 non0 expvrs were best @ Y-3, 2 @ Y-2, none at Y1 or Y0. Total inf by yr:
#LagYr3: 59%. 2 22, 1 6, 0 13%. 80% y3&2. Throw out biological variables Y0 & 1?
#Contribute 14% but harder to acquire recent data. LrgPlog=4.7% but latest datum 2007!

#check relationships with largeP hake jmac msq rockfish krill
#lrgP: y2 neg, y3 dome neg = ok
#hake: y3210 UP not ideal. Total inf 3% y32 1.7%
#Jmac3210: dope/UP, dome neg, neg, pos. Tot inf 10% y32 7% is all y3
#Msquid3210: neg, inv.dome pos, neg, neg = ok. 2.7% inf 1.6 y32
#Rockfish3210: pos/dome, pos/dome, neg, neg. 2.2%, y32 2.1%
#Krill3210: neg pos neg neg 1.8% y32 1.4%

#remove A_Tot_B_log from expvars


#all data 57:end####
LarvalSamplesLag57 <- subset(LarvalSamplesLag, Year >= 1957) #n=57
gbm.bfcheck(samples = LarvalSamplesLag57, resvar = "Anch_Larvae_Peak_log", ZI = F) #0.368 v good
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.30_AlogExpLag23abund"))
gbm.loop(expvar = LarvalExpvarsLag123,
         resvar = LarvalResvar,
         samples = LarvalSamplesLag57,
         lr = 0.01,
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = T,
         alerts = F,
         cleanup = T)
beep(8)

#all data 64:end####
LarvalSamplesLag64 <- subset(LarvalSamplesLag, Year >= 1964) #n=50
gbm.bfcheck(samples = LarvalSamplesLag64, resvar = "Anch_Larvae_Peak_log", ZI = F) #0.42
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.30_AlogExpLag23abund"))
gbm.loop(expvar = LarvalExpvarsLag123,
         resvar = LarvalResvar,
         samples = LarvalSamplesLag64,
         lr = 0.01,
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,  #
         multiplot = F,
         varint = T,
         alerts = F,
         cleanup = T)
beep(8)

#all data 81:end####
LarvalSamplesLag81 <- subset(LarvalSamplesLag, Year >= 1981) #n=37
gbm.bfcheck(samples = LarvalSamplesLag81, resvar = "Anch_Larvae_Peak_log", ZI = F) #0.568
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.30_AlogExpLag23abund"))
gbm.loop(expvar = LarvalExpvarsLag123,
         resvar = LarvalResvar,
         samples = LarvalSamplesLag81,
         lr = 0.01,
         bf = 0.75,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F, #tried bf 0.75
         multiplot = F,
         varint = T,
         alerts = F,
         cleanup = T)
beep(8)

#only full ts data all ts####
#manually edit expvars
#remove chlA (online 81) hake 66 
LarvalExpvarsExclude2 <- c("ChlA_all_lag_2","ChlA_all_lag_3","Hake_lag_2","Hake_lag_2")
LarvalExpvarsExcludeNos2 <- match(LarvalExpvarsExclude2, LarvalExpvarsLag123)
LarvalExpvarsLagFullTS <- LarvalExpvarsLag123[-LarvalExpvarsExcludeNos2]

gbm.bfcheck(samples = LarvalSamplesLag, resvar = "Anch_Larvae_Peak_log", ZI = F) # 0.3333333 v good
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.30_AlogExpLag23abund"))
gbm.loop(expvar = LarvalExpvarsLagFullTS,
         resvar = LarvalResvar,
         samples = LarvalSamplesLag,
         lr = 0.01,
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = T,
         alerts = F,
         cleanup = T)
beep(8)


#EGG all data 51:end (all)####
EggResvar <- "Anch_Egg_Peak"
EggSamples <- Annual[-which(is.na(Annual[EggResvar])),]
EggSamplesLog <- AddLogs(x = EggSamples, toLog = c("Anch_Egg_Peak","Lrg_P","Jmac",
                                                   "Cmac","Biom_Sard_Alec","A_Tot_B"))
EggExpvars <- c("A_Tot_B_log",
                "NPGO_Spring",
                "NPC_Str_Lat",
                "SeaLevSF_PreW",
                "BUI33N_Spring",
                "Stab_South",
                "Temp_South",
                "Sal_South",
                "O2AtDep_all",
                "Lrg_P_log",
                "Hake",
                "Jmac_log",
                "Cmac_log",
                "Biom_Sard_Alec_log", #changed from catch. catch: much higher inf% but
                #biased & slow to acquire, needs monthly reprofiling also.
                "Msquid_Biom",
                "Rockfish_Biom",
                "Krill_mgCm2")
EggSamplesLag <- AddLags(x = EggSamplesLog, lagYears = 1:3, toLag = EggExpvars) #extended to 3 to test
EggExpvarsLag123 <- c(EggExpvars,
                         paste0(EggExpvars, "_lag_1"),
                         paste0(EggExpvars, "_lag_2"),
                         paste0(EggExpvars, "_lag_3"))
#remove A_Tot_B_log (circular)
EggExpvarsLag123 <- EggExpvarsLag123[-match("A_Tot_B_log", EggExpvarsLag123)]
EggResvar <- "Anch_Egg_Peak_log"
gbm.bfcheck(samples = EggSamplesLag, resvar = EggResvar, ZI = F) #0.333
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.30_AlogExpLag23abund"))
#library(beepr)
gbm.loop(expvar = EggExpvarsLag123,
         resvar = EggResvar,
         samples = EggSamplesLag,
         lr = 0.01, 
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = F,
         cleanup = T)
beep(8)
#check influence by lag year, remove any years?
#No. 57% is lrgP-log, 78% is lrgP.
#Inf by yr0123: 60 21 19 15

#check relationships with largeP hake jmac msq rockfish krill
#lrgP0123: dome/pos, neg, dome neg, neg. Total inf %: 78
#hake0123: pos * 4; 1.4%
#Jmac0123: pos * 4; 0.9%
#Msquid0123: inv dome pos, neg pos pos; 0.6%
#Rockfish0123: dome neg, dome neg, pos dome, pos dome. 1.3%
#Krill0123: neg neg dome neg. 1.3%

#all data 57:end####
EggSamplesLag57 <- subset(EggSamplesLag, Year >= 1957) #n=57
gbm.bfcheck(samples = EggSamplesLag57, resvar = "Anch_Egg_Peak_log", ZI = F) #0.3684211 v good
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.30_AlogExpLag23abund"))
gbm.loop(expvar = EggExpvarsLag123,
         resvar = EggResvar,
         samples = EggSamplesLag57,
         lr = 0.01,
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = T,
         alerts = F,
         cleanup = T)
beep(8)

#all data 64:end####
EggSamplesLag64 <- subset(EggSamplesLag, Year >= 1964) #n=50
gbm.bfcheck(samples = EggSamplesLag64, resvar = "Anch_Egg_Peak_log", ZI = F) #0.42
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.30_AlogExpLag23abund"))
gbm.loop(expvar = EggExpvarsLag123,
         resvar = EggResvar,
         samples = EggSamplesLag64,
         lr = 0.01,
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = T,
         alerts = F,
         cleanup = T)
beep(8)

#all data 81:end####
EggSamplesLag81 <- subset(EggSamplesLag, Year >= 1981) #n=37
gbm.bfcheck(samples = EggSamplesLag81, resvar = "Anch_Egg_Peak_log", ZI = F) #0.568
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.30_AlogExpLag23abund"))
gbm.loop(expvar = EggExpvarsLag123,
         resvar = EggResvar,
         samples = EggSamplesLag81,
         lr = 0.01,
         bf = 0.75,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = F, #tried bf 0.75
         multiplot = F,
         varint = T,
         alerts = F,
         cleanup = T)
beep(8)

#only full ts data all ts####
#manually edit expvars. hake from 1966 npc 2002
EggExpvarsExclude2 <- c("Hake","Hake_lag_1","Hake_lag_2","Hake_lag_3",
                        "NPC_Str_Lat","NPC_Str_Lat_lag_1","NPC_Str_Lat_lag_2","NPC_Str_Lat_lag_3")
EggExpvarsExcludeNos2 <- match(EggExpvarsExclude2, EggExpvarsLag123)
EggExpvarsLagFullTS <- EggExpvarsLag123[-EggExpvarsExcludeNos2]

gbm.bfcheck(samples = EggSamplesLag, resvar = "Anch_Egg_Peak_log", ZI = F) # 0.3333333 v good
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.10.30_AlogExpLag23abund"))
gbm.loop(expvar = EggExpvarsLagFullTS,
         resvar = EggResvar,
         samples = EggSamplesLag,
         lr = 0.01,
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = T,
         alerts = F,
         cleanup = T)
beep(8)

#TODO####
#Could re-run adults with Y01 environmentals added back?
#Use TSS on final models, re run?
#var.infs as radar plots, see https://www.r-graph-gallery.com/142-basic-radar-chart/ ,
#need same order of vars & to uniformalise the scales per variable across ALE