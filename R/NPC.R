#NPC streamline analysis: EOF (PCA)
# 2018.06.06

# prcomp() for PCA
# prcomp(formula, data = NULL, subset, na.action, ...)

# read in data
# Already subset by months 7:3, July to March, July is 6mo before Jan, March is 2 months before May
# Using Anchovy data from Jan to May. Current travel time is 2 to 6 months from 130 to 160W respectively.
# Also removed rows with missing values as they cause svd (PCA) to fail and there's nothing you can do about it: na.omit(x) fails, na.action=na.omit fails.
NPC <- read.csv("C:/Users/simon/Dropbox/Farallon Institute/Data & Analysis/Environmental/Current/NPC2.csv")

NPC2 <- NPC[,3:9] # remove year & month to test
NPCPCA <- prcomp(NPC2) # Run PCA
summary(NPCPCA)

# Importance of components:
#                           PC1    PC2    PC3     PC4     PC5     PC6     PC7
# Standard deviation     2.8319 1.5436 1.3460 0.96549 0.55477 0.34326 0.26273
# Proportion of Variance 0.5879 0.1747 0.1328 0.06834 0.02256 0.00864 0.00506
# Cumulative Proportion  0.5879 0.7626 0.8954 0.96374 0.98630 0.99494 1.00000

NPCPCA3 <- prcomp(NPC2, rank. = 3) # only top 3 PCs

# Plot
biplot(NPCPCA3, scale = 0)

NPCPCA3$rotation #Loadings
#              PC1        PC2        PC3
# W160  0.67103709 -0.4320975  0.1089790
# W155  0.41996959 -0.2212086  0.0347314
# W150  0.21548188 -0.1093164  0.1029901
# W145 -0.01677075 -0.4282138  0.1343159
# W140 -0.10776020 -0.1632188  0.2741264
# W135 -0.41107854 -0.3054153  0.7347063
# W130 -0.38212987 -0.6701659 -0.5859445

PCs <- predict(NPCPCA3, newdata = NPC2)
NPCPCs <- cbind(NPC, PCs)
write.csv(NPCPCs, file = "C:/Users/simon/Dropbox/Farallon Institute/Data & Analysis/Environmental/Current/NPCPCs.csv")
