# Linear Model plots, exp vs resvar, with extending lags
# SD 2018.08.30
machine <- "/home" # linux desktop (& laptop?)
machine <- "C:/Users"# windows laptop
source(paste0(machine, '/simon/Dropbox/Galway/Analysis/R/My Misc Scripts/lmplotlag.R')) # load my lm lag plotting function
source(paste0(machine, '/simon/Dropbox/Galway/Analysis/R/My Misc Scripts/lmplot.R')) # load my lm plotting function
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/lm plots/Lags"))

#update to latest file####
Annual <- read.csv(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Data Structure Template 2018.09.05.csv'),
                   na.strings = "")
# clip off dud rows year 2018 & beyond if present
Annual <- Annual[1:(match(2017, Annual$Year)),]

# the following exp&resvars are copied from LarvalModel.R
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

LarvalResvar <- "Anch_Larvae_peak"
LarvalExpvars <- c("Anch_Egg", "A_Tot_B", "MEI_PreW", "MEI_Spring", "NPGO_PreW",
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

# Set params for all 3 resvars
r2line = FALSE
adj = c(0,0.5)
pointtext = TRUE
pointlabs = Annual$Year
pointcol = rainbow(n = dim(Annual)[1], # cex col
                   end = 0.80)
# Adults####
setwd("Adults")
for(i in 1:length(AdultExpvars)){
  dir.create(AdultExpvars[i])
  setwd(AdultExpvars[i])
lmplotlag(n = 0:5,      # lag year(s), single or vector
          x = Annual[,AdultExpvars[i]], # sardine
          y = Annual[,AdultResvar],
          xexpvarname = AdultExpvars[i],
          yresvarname = AdultResvar,
          r2line = r2line,
          adj = adj,
          pointtext = pointtext,
          pointlabs = pointlabs,
          pointcol = pointcol)
setwd("../")}
setwd("../")

# Larvae####
setwd("Larvae")
for(i in 1:length(LarvalExpvars)){
  dir.create(LarvalExpvars[i])
  setwd(LarvalExpvars[i])
  lmplotlag(n = 0:5,      # lag year(s), single or vector
            x = Annual[,LarvalExpvars[i]], # sardine
            y = Annual[,LarvalResvar],
            xexpvarname = LarvalExpvars[i],
            yresvarname = LarvalResvar,
            r2line = r2line,
            adj = adj,
            pointtext = pointtext,
            pointlabs = pointlabs,
            pointcol = pointcol)
  setwd("../")}
setwd("../")

# Eggs####
setwd("Eggs")
for(i in 1:length(EggExpvars)){
  dir.create(EggExpvars[i])
  setwd(EggExpvars[i])
  lmplotlag(n = 0:5,      # lag year(s), single or vector
            x = Annual[,EggExpvars[i]], # sardine
            y = Annual[,EggResvar],
            xexpvarname = EggExpvars[i],
            yresvarname = EggResvar,
            r2line = r2line,
            adj = adj,
            pointtext = pointtext,
            pointlabs = pointlabs,
            pointcol = pointcol)
  setwd("../")}
setwd("../")