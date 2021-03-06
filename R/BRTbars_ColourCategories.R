# script to re-do bar plots from BRT when n of vars is too high and they look bad
# Saves image, returns nothing
# Simon Dedman, simondedman@gmail.com, 2019.02.04

BRTbarsCC <- function(inputfilename = "GausBarsGoodLoop.csv", #name of csv file with variable influence data, default GausBarsGoodLoop.csv
                    n = 15, #number of rows of bars to create, default 15
                    pngtype = "cairo-png", #png type, OS specific, default is cairo, for linux
                    labelscol = 1, # column containing labels i.e. variable names, default 1
                    usecol = 3, #column with data, default 3
                    xlabel = "Av. Influence %", #x axis label
                    outputfilename = "New_Bars.png"){ # name of output png file to be saved
                    
tmpcsv <- read.csv(inputfilename, na.strings = "") #import csv file
Bin_Bars <- tmpcsv[order(-tmpcsv[,usecol]),] #sort by influence% descending

library(stringr) #clean names with string remove & replace
Bin_Bars[,1] %<>% 
  str_remove_all("_log") %>% 
  str_replace_all("Sea_Level", "Sea_Level_Height") %>% #sealevel, sealion, chinook, chl
  str_replace_all("SeaLion", "Sea_lion") %>% 
  str_replace_all("Chinook_Salmon", "Salmon") %>% 
  str_replace_all("Chlorophyll_a", "Chlorophyll_A")

lookup <- read.csv(paste0(machine, "/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/VariableCategoriesLookup.csv"))

for(i in 1:4){ #clean lookup table so it's same format
  lookup[,i] %<>% 
    str_remove_all("_log") %>% 
    str_replace_all("Sea_Level", "Sea_Level_Height") %>% #sealevel, sealion, chinook, chl
    str_replace_all("SeaLion", "Sea_lion") %>% 
    str_replace_all("Chinook_Salmon", "Salmon") %>% 
    str_replace_all("Chlorophyll_a", "Chlorophyll_A")
}

Bin_Bars_Cats = merge(Bin_Bars,
                      lookup,
                      by.x = "X",
                      by.y = "Variable",
                      all.x = T)

Bin_Bars_Cats <- Bin_Bars_Cats[order(-Bin_Bars_Cats[,usecol]),] #sort by influence% descending
if(length(Bin_Bars_Cats[,1]) < n) n <- length(Bin_Bars_Cats[,1]) #if n requested bars > n variables, reduce bars to match variables
Bin_Bars_Cats <- Bin_Bars_Cats[1:n,] #subset by n of requested rows

pointlineseqbin <- seq(0, length(Bin_Bars[,usecol]) - 1, 1)
png(filename = outputfilename, width = 4*480, height = 4*480, units = "px",
    pointsize = 4*12, bg = "white", res = NA, family = "", type = pngtype)
par(mar = c(2.5,0.3,0,0.5), fig = c(0,1,0,1), cex.lab = 0.5, mgp = c(1.5,0.5,0), cex = 1.3, lwd = 6)
barplot(rev(Bin_Bars[,usecol]), cex.lab = 1.2, las = 1, # axis labs horizontal
        horiz = TRUE, # make horizontal
        xlab = xlabel, col = NA, border = NA, # no border, lwd redundant
        xlim = c(0, 2.5 + ceiling(max(Bin_Bars[,usecol]))),
        ylim = c(0, length(Bin_Bars[,usecol])), # figure height as a proportion of nBars
        beside = T) # juxtaposed not stacked
revseq <- rev(pointlineseqbin)
for (q in 1:length(Bin_Bars[,usecol])) {
  lines(c(0, Bin_Bars[q,usecol]), c(revseq[q], revseq[q]), col = "black", lwd = 8)}
text(0.1, pointlineseqbin + (length(Bin_Bars[,usecol])/55), labels = rev(Bin_Bars[,labelscol]), adj = 0, cex = 0.8)
axis(side = 1, lwd = 6, outer = TRUE, xpd = NA)
dev.off()
} # close function
