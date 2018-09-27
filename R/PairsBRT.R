#function to automate the process of running & exporting pairplots on variables then running (multiple) BRTs then presenting the findings quickly
#Simon Dedman simondedman@gmail.com 2018.09.24

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
Annual <- read.csv(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Data Structure Template 2018.09.20.csv'),
                   na.strings = "")
# Annual <- Annual[5:nrow(Annual),] # Trim first 4 rows. Now done beforehand so data columns aren't imported as factors
# clip off dud rows year 2018 & beyond if present
Annual <- Annual[1:(match(2017, Annual$Year)),]



#Select named goodcols####
AdultResvar <- "A_Tot_B"
AdultExpvars <- c("A_Tot_B_Y.1", "MEI_PreW", "MEI_Spring", "NPGO_PreW",
                  "NPGO_Spring","NPC_Str_Lat", "SeaLevLA_PreW","SeaLevLA_Spring",
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
                "Stab_CentCal", "Stab_Nearsh", "Stab_NCoast", "Stab_Offsh", "Stab_South", "Stab_Transition",
                "PDO_PreW","PDO_Spring","LaJ_T_PreW","LaJ_T_Spring","TempAtDep_all",
                "Temp_CentCal", "Temp_Nearsh", "Temp_NCoast", "Temp_Offsh", "Temp_South", "Temp_Transition",
                "SalAtDep_all",
                "Sal_CentCal", "Sal_Nearsh", "Sal_NCoast", "Sal_Offsh", "Sal_South", "Sal_Transition",
                "O2AtDep_all", 
                "O2_CentCal", "O2_Nearsh", "O2_NCoast", "O2_Offsh", "O2_South", "O2_Transition",
                "Lrg_P",
                "Hake", "Jmac", "Cmac",
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