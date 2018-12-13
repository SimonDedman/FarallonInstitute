# script to re-do bar plots from BRT when n of vars is too high and they ook bad
# manually set n of vars to use

setwd("C:/Users/simon/Dropbox/Farallon Institute/Data & Analysis/ModelOutputs/2018.12.03_LrgPupdate/Adults_post57/A_Tot_B_log")
tmpcsv <- read.csv("GausBarsGoodLoop.csv", na.strings = "")

Bin_Bars <- subset(tmpcsv, Av.Inf >= 1) #subset by av.inf
Bin_Bars <- tmpcsv[1:10,] #subset by row numbers
pngtype = "cairo-png"
labelscol <- 1 #column with variable names
usecol <- 3 #column with data
xlabel <- "Av. Influence %"


pointlineseqbin <- seq(0, length(Bin_Bars[,usecol]) - 1, 1)
png(filename = "New_Bars.png",
    width = 4*480, height = 4*480, units = "px", pointsize = 4*12, bg = "white", res = NA, family = "",
    type = pngtype)
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
