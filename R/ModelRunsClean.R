# BRT modelling clean code
# harvested from LarvalModel.R which was the working code
# Simon Dedman 2019.04.01
# started 19/06/2018

library(devtools)
install_github("SimonDedman/gbm.auto") # update gbm.auto to latest
library(gbm.auto)
library(beepr)

machine <- "/home" # linux desktop (& laptop?)
machine <- "C:/Users"# windows laptop
source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/AddLags.R"))
source(paste0(machine, "/simon/Dropbox/Farallon Institute/FarallonInstitute/R/AddLogs.R"))
Annual <- read.csv(paste0(machine, '/simon/Dropbox/Farallon Institute/Data & Analysis/Data Structure Template 2019.03.11.csv'),na.strings = "") #update
Annual <- Annual[1:(match(2017, Annual$Year)),]

setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2019.02.11_NoSquid"))
# rename columns #get rid of all, south, la, prewinter
{colnames(Annual)[which(colnames(Annual) == "Anch_Larvae_Peak")] <- "CSNA_Larvae"
  colnames(Annual)[which(colnames(Annual) == "A_Tot_B")] <- "CSNA_SSB"
  colnames(Annual)[which(colnames(Annual) == "Biom_Sard_Alec")] <- "Sardine"
  colnames(Annual)[which(colnames(Annual) == "ChinSal")] <- "Chinook_Salmon"
  colnames(Annual)[which(colnames(Annual) == "Cmac")] <- "Chub_Mackerel"
  colnames(Annual)[which(colnames(Annual) == "FishLand")] <- "Landings_CSNA"
  colnames(Annual)[which(colnames(Annual) == "Hake")] <- "Hake_Berger_Unused"
  colnames(Annual)[which(colnames(Annual) == "Hake_Biom")] <- "Hake"
  colnames(Annual)[which(colnames(Annual) == "Hsquid")] <- "Humboldt_Squid"
  colnames(Annual)[which(colnames(Annual) == "Jmac")] <- "Jack_Mackerel"
  colnames(Annual)[which(colnames(Annual) == "Krill_mgCm2")] <- "Krill"
  colnames(Annual)[which(colnames(Annual) == "Lrg_P")] <- "Large_Plankton"
  colnames(Annual)[which(colnames(Annual) == "Msquid_Biom")] <- "Market_Squid"
  colnames(Annual)[which(colnames(Annual) == "O2AtDep_all")] <- "Oxygen"
  colnames(Annual)[which(colnames(Annual) == "Sal_South")] <- "Salinity"
  colnames(Annual)[which(colnames(Annual) == "Sml_P")] <- "Small_Plankton"
  colnames(Annual)[which(colnames(Annual) == "SoShWa")] <- "Sooty_Shearwater"
  colnames(Annual)[which(colnames(Annual) == "Temp_South")] <- "Temperature"
  colnames(Annual)[which(colnames(Annual) == "BUI33N_Spring")] <- "Upwelling"
  colnames(Annual)[which(colnames(Annual) == "ChlA_all")] <- "Chlorophyll_a"
  colnames(Annual)[which(colnames(Annual) == "HBW")] <- "Humpback_Whale"
  colnames(Annual)[which(colnames(Annual) == "NPGO_Spring")] <- "NPGO"
  colnames(Annual)[which(colnames(Annual) == "SeaLevLA_PreW")] <- "Sea_Level"
  colnames(Annual)[which(colnames(Annual) == "Stability_all")] <- "Stability"}


#adults57####
AdultResvar <- "CSNA_SSB"
AdultSamples <- Annual[-which(is.na(Annual[AdultResvar])),] # remove NA rows

library(dplyr)
library(magrittr)
library(stringr)
colnames(LarvalSamples) %<>% 
  stringr::str_replace_all("Sea_Level", "Sea_Level_Height") %>% #sealevel, sealion, chinook, chl
  stringr::str_replace_all("SeaLion", "Sea_lion") %>% 
  stringr::str_replace_all("Chinook_Salmon", "Salmon") %>% 
  stringr::str_replace_all("Chlorophyll_a", "Chlorophyll_A")

AllSamplesLog <- AddLogs(x = AdultSamples, toLog = c("CSNA_SSB",
                                                     "Small_Plankton",
                                                     "Large_Plankton",
                                                     "Jack_Mackerel",
                                                     "Chub_Mackerel",
                                                     "Sardine"))
AllExpvars <- c("NPGO", #ABUNDANCE NO CONSUMPTION
                "Sea_Level_Height", #overruling SF spring (L) & SF preW (E)
                "Upwelling",
                "Stability", #overruling south (L)
                "Temperature", #overruling NCoast (A)
                "Salinity",
                "Oxygen", #overruling offshore(A)
                "Chlorophyll_A", #overruling nearshore(A)
                "Landings_CSNA",
                "Hake", #overruling hake
                #"Market_Squid",
                "Krill",
                "Sea_lion",
                "Albacore",
                "Chinook",
                "Halibut",
                "Sooty_Shearwater",
                "Humpback_Whale",
                "Humboldt_Squid",
                "Small_Plankton_log",
                "Large_Plankton_log", #UP relationship
                "Sardine_log",
                "Jack_Mackerel_log", #UP relationship
                "Chub_Mackerel_log",
                "CSNA_SSB_log")

AllSamplesLag <- AddLags(x = AllSamplesLog, lagYears = 1:2, toLag = AllExpvars)
# lagyr1&0 contributed 7% av.inf before. Remove for simplicity, speed and data assess defensibility
# no reason to exclude anchovy biomass lags however; remove L0&1 for others next

AllExpvarsLag12 <- c(AllExpvars,
                     paste0(AllExpvars, "_lag_1"),
                     paste0(AllExpvars, "_lag_2"))
rmlist <- c("CSNA_SSB_log")
rmlistnos <- match(rmlist, AllExpvarsLag12)
AllExpvarsLag12 <- AllExpvarsLag12[-rmlistnos]
#anchovy lag0
AdultResvar <- "CSNA_SSB_log"


#Log name fixes
AllSamplesLag <- AllSamplesLag[,c(AdultResvar, AllExpvarsLag12)]
colnames(AllSamplesLag) %<>% str_remove_all("_log")
AllExpvarsLag12 %<>% str_remove_all("_log")
AdultResvar %<>% str_remove_all("_log")


setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2019.02.11_NoSquid/Adults_post57"))
AllSamplesLag57 <- subset(AllSamplesLag, Year >= 1957) #n=51
gbm.bfcheck(samples = AllSamplesLag57, resvar = "CSNA_SSB_log", ZI = F) #0.412 good
gbm.loop(expvar = AllExpvarsLag12,
         resvar = AdultResvar,
         samples = AllSamplesLag57,
         lr = 0.005, #0.1 
         bf = 0.5,
         ZI = F,
         savegbm = FALSE,
         BnW = FALSE,
         simp = T,
         multiplot = F,
         varint = T,
         alerts = F,
         loops = 5)
beep(8)

#adults81####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2019.02.11_NoSquid/Adults_post81"))
AllSamplesLag81 <- subset(AllSamplesLag, Year >= 1981) #n=51
gbm.bfcheck(samples = AllSamplesLag57, resvar = "CSNA_SSB_log", ZI = F) #0.412 good
gbm.loop(expvar = AllExpvarsLag12,
         resvar = AdultResvar,
         samples = AllSamplesLag81,
         lr = 0.0001, #0.1 
         bf = 0.7,
         ZI = F,
         simp = F, #manually simplified. Didn't converge.
         multiplot = F,
         varint = T,
         loops = 5)
beep(8)



#larvae57####
# change sea level & stability in larval samples later
LarvalResvar <- "CSNA_Larvae"
LarvalSamples <- Annual[-which(is.na(Annual[LarvalResvar])),]
colnames(LarvalSamples)[which(colnames(LarvalSamples) == "SeaLevSF_Spring")] <- "Sea_Level"
colnames(LarvalSamples)[which(colnames(LarvalSamples) == "Stab_South")] <- "Stability" ##dupe name

library(dplyr)
library(magrittr)
library(stringr)
colnames(LarvalSamples) %<>% 
  stringr::str_replace_all("Sea_Level", "Sea_Level_Height") %>% #sealevel, sealion, chinook, chl
  stringr::str_replace_all("Chlorophyll_a", "Chlorophyll_A")

LarvalSamplesLog <- AddLogs(x = LarvalSamples, toLog = c("CSNA_Larvae","CSNA_SSB",
                                                         "Small_Plankton",
                                                         "Large_Plankton",
                                                         "Jack_Mackerel",
                                                         "Chub_Mackerel",
                                                         "Sardine"))

LarvalExpvars <- c("NPGO",
                   "Sea_Level_Height",
                   "Upwelling",
                   "Stability", #overruling south (L)
                   "Temperature", #overruling NCoast (A)
                   "Salinity",
                   "Oxygen", #overruling offshore(A)
                   "Chlorophyll_A",
                   "Small_Plankton_log",
                   "Large_Plankton_log",
                   "Hake",
                   "Jack_Mackerel_log", #UP relationship
                   "Chub_Mackerel_log",
                   "Sardine_log",
                   #"Market_Squid", #UP w/ y-2
                   "Krill", #UN relationship
                   "CSNA_SSB_log") #remove y0 from expvar

LarvalSamplesLogLag <- AddLags(x = LarvalSamplesLog, lagYears = 1:2, toLag = "CSNA_SSB_log")
# lagyr1&0 contributed 7% av.inf before. Remove for simplicity, speed and data assess defensibility
# no reason to exclude anchovy biomass lags however; remove L0&1 for others next

LarvalExpvarsLogLag12 <- c(LarvalExpvars,
                           paste0("CSNA_SSB_log", "_lag_1"),
                           paste0("CSNA_SSB_log", "_lag_2"))
LarvalExpvarsLogLag12
rmlist <- c("CSNA_SSB_log")
rmlistnos <- match(rmlist, LarvalExpvarsLogLag12)
LarvalExpvarsLogLag12 <- LarvalExpvarsLogLag12[-rmlistnos]
LarvalResvar <- "CSNA_Larvae_log"

#Log name fixes
LarvalSamplesLogLag <- LarvalSamplesLogLag[,c("Year", LarvalResvar, LarvalExpvarsLogLag12)]
colnames(LarvalSamplesLogLag) %<>% str_remove_all("_log")
LarvalExpvarsLogLag12 %<>% str_remove_all("_log")
LarvalResvar %<>% str_remove_all("_log")

LarvalSamplesLogLag57 <- subset(LarvalSamplesLogLag, Year >= 1957) #n=51
gbm.bfcheck(samples = LarvalSamplesLogLag57, resvar = LarvalResvar, ZI = F) #0.389 good
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2019.03.27 Larvae ReDo2"))

gbm.auto(expvar = LarvalExpvarsLogLag12,
         resvar = LarvalResvar,
         samples = LarvalSamplesLogLag57,
         lr = 0.01, 
         bf = 0.95,
         ZI = F,
         tc = 14,
         simp = T,
         alerts = F,
         savegbm = F) #2019.03.11 0.974, 2019.03.27 0.979 IMPROVED


#larvae81####
LarvalSamplesLogLag81 <- subset(LarvalSamplesLogLag, Year >= 1981) #n=37
gbm.bfcheck(samples = LarvalSamplesLogLag81, resvar = LarvalResvar, ZI = F) #0.5675676
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2019.03.27 Larvae ReDo2/post81"))
# gbm.loop(expvar = LarvalExpvarsLogLag12,
#          resvar = LarvalResvar,
#          samples = LarvalSamplesLogLag81,
#          lr = 0.01, 
#          bf = 0.7,
#          ZI = F,
#          simp = F, #won't run otherwise, does converge
#          multiplot = F,
#          loops = 5)

gbm.auto(expvar = LarvalExpvarsLogLag12,
         resvar = LarvalResvar,
         samples = LarvalSamplesLogLag81,
         lr = 0.01, 
         bf = 0.95,
         ZI = F,
         tc = 14,
         simp = F,
         alerts = F,
         savegbm = F) #2019.03.11 0.944, 2019.03.27 0.95 IMPROVED
beep(8)

#LoAnch####
AdultResvar <- "CSNA_SSB_log"
AdultSamplesLagHiAnch <- subset(AllSamplesLag, CSNA_SSB_log > log1p(220000)) #31
AdultSamplesLagLoAnch <- subset(AllSamplesLag, CSNA_SSB_log <= log1p(220000)) #26
gbm.bfcheck(samples = AdultSamplesLagHiAnch, resvar = "CSNA_SSB_log", ZI = F) #0.677
gbm.bfcheck(samples = AdultSamplesLagLoAnch, resvar = "CSNA_SSB_log", ZI = F) #0.807

setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2019.02.11_NoSquid/LoAnch"))
#colnames(AdultSamplesLagLoAnch)
gbm.loop(expvar = AllExpvarsLag12,
         resvar = AdultResvar,
         samples = AdultSamplesLagLoAnch, #n=26
         lr = 0.005,
         bf = 0.95,
         ZI = F,
         simp = F,
         multiplot = F,
         loops = 3,
         n.trees = 10)
beep(8)

#HiAnch####
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2019.02.11_NoSquid/HiAnch"))
gbm.loop(expvar = AllExpvarsLag12,
         resvar = AdultResvar,
         samples = AdultSamplesLagHiAnch, #n=31
         lr = 0.00001,
         bf = 0.88,
         ZI = F,
         simp = F,
         multiplot = F,
         loops = 2,
         n.trees = 10,
         max.trees = 400) #won't run

plot(1:10,1:10)
dev.off()



#Category Coloured Barplots####
#ReDo bars as as rectanglies not lines, coloured by category
#machine <- "/home" # linux desktop (& laptop?)
machine <- "C:/Users"# windows laptop

# add categories by lookup
#merge. need comparison table, one for adults & one for larvae
lookup <- read.csv(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/VariableCategoriesLookup.csv"))
for(i in 1:4){ #clean lookup table so it's same format
  lookup[,i] %<>% 
    str_remove_all("_log") %>% 
    str_replace_all("Sea_Level", "Sea_Level_Height") %>% #sealevel, sealion, chinook, chl
    str_replace_all("SeaLion", "Sea_lion") %>% 
    str_replace_all("Chinook_Salmon", "Salmon") %>% 
    str_replace_all("Chlorophyll_a", "Chlorophyll_A")
}
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2019.02.11_NoSquid/Adults_post57/CSNA_SSB_log"))
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2019.02.11_NoSquid/Adults_post81/CSNA_SSB_log"))
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2019.02.11_NoSquid/HiAnch/CSNA_SSB_log"))
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2019.02.11_NoSquid/LoAnch/CSNA_SSB_log"))
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2019.03.27 Larvae ReDo2/post57"))
setwd(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2019.03.27 Larvae ReDo2/post81"))

Bin_Bars <- read.csv("GausBarsGoodLoop.csv", na.strings = "") #import csv file gbm.loop
Bin_Bars <- read.csv("Gaussian BRT Variable contributions.csv", na.strings = "") #import csv file gbm.auto

Bin_Bars[,1] %<>%  #check input file first, shouldn't be in function. should ideally already be clean if filenames etc sorted in code above. Already clean for larvae
  str_remove_all("_log") %>%
  str_replace_all("Sea_Level", "Sea_Level_Height") %>% #sealevel, sealion, chinook, chl
  str_replace_all("SeaLion", "Sea_lion") %>%
  str_replace_all("Chinook_Salmon", "Salmon") %>%
  str_replace_all("Chlorophyll_a", "Chlorophyll_A")

Bin_Bars_Cats = merge(Bin_Bars,
                      lookup,
                      by.x = "var", #loop: "X" auto: "var"
                      by.y = "Variable",
                      all.x = T)

Bin_Bars_Cats <- Bin_Bars_Cats[order(-Bin_Bars_Cats[,2]),] #sort by influence% descending #loop 3 auto 2

if(dim(Bin_Bars_Cats)[1] > 15) Bin_Bars_Cats <- Bin_Bars_Cats[1:15,] #subset by n of requested rows unless it's already shorter

library(ggplot2)
{
  p <- ggplot(data = Bin_Bars_Cats,
              aes(x = reorder(Bin_Bars_Cats$var, #X or var,
                              Bin_Bars_Cats$rel.inf), #labels ordered by av inf # Av.Inf or rel.inf
                  y = rel.inf, #data default to av inf as it's in that order already #Av.Inf or rel.inf
                  fill = VarCatLarvae)) + #colour bars by category #changes based on larvae or SSB VarCatAdults VarCatLarvae
    
    scale_fill_manual(values=c("#BEAED4", #anchovy purple
                               "#6092d2", #enviro blue
                               "#FFFF99", #GI yellow
                               "#FDC086", #Pred red
                               "#7FC97F")) + #Prey green
    
    geom_bar(stat="identity") + 
    
    geom_text(aes(label = Bin_Bars_Cats$var, #X or var
                  y = 0.04), #y=0 aligns to LH edge, absolute positioning not 0:1
              hjust = 0, #horizontal position of text 0:1, 0.5 default
              color = "black",
              size = 5) +
    
    theme(axis.title.y = element_blank(),
          axis.text.y = element_blank(), #element_text(hjust = 1), #angle = 90, , vjust = 0.5
          axis.ticks.y = element_blank(),
          legend.position = c(0.8, 0.15), #% from L to R & % from B to T
          legend.title = element_blank(),
          panel.background = element_rect(fill = 'white'), #white background
          axis.line.x = element_line(color = "black"), #xaxis line
          panel.grid.major.x = element_line(colour = "grey"))
  p +
    scale_x_discrete(limits = rev(Bin_Bars_Cats$var), #X or var
                     position = "bottom") +
    coord_flip() +
    labs(y = "Average Influence %") #also title & x
  
  ggsave(filename = "ggBars.png",
         plot = last_plot(),
         device = "png",
         path = ".",
         scale = 1,
         width = 152,
         height = 185,
         units = "mm",
         dpi = 300,
         limitsize = TRUE)
}

# if a category (e.g. guild interactor) is not represented in the bars then
# the next categories will move up into its place and thus the colours will change across plots
# edit manually, comment out line for specific absent category colours, L354 etc.