## Runs Test
## Simon Dedman 28/8/2018
## https://en.wikipedia.org/wiki/Wald%E2%80%93Wolfowitz_runs_test
## https://www.itl.nist.gov/div898/handbook/eda/section3/eda35d.htm
## 
install.packages("tseries")
library(tseries)
setwd("C:/Users/simon/Dropbox/Farallon Institute/Data & Analysis/Biological/Anchovy & Sardine Biomass/RunsTest")
anchrun <- read.csv("RT1all.csv")
anchrun <- read.csv("RT2noNA.csv")
anchrun <- read.csv("RT3onlyRuns.csv")
anchrun$AnchRunsTest <- as.factor(anchrun$AnchRunsTest)

runs.test(anchrun$AnchRunsTest)

# 2 noNA
# Standard Normal = 0.80405, p-value = 0.4214
# alternative hypothesis: two.sided
 
# 3 onlyruns
# Standard Normal = 1.2544, p-value = 0.2097
# alternative hypothesis: two.sided
 
# Null hypothesis: order of the data is random
# Alternative hypothesis: order of the data is not random
# High p-value means you cannot trash your null hypothesis (e.g. >0.05)
# p-value is probability you reject a null hypothesis when it is actually true.