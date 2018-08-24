getwd()
setwd("C:/Users/simon/Dropbox/Farallon Institute/Data & Analysis/Biological/PredPrey Trophic/Fish/Sardine")
YrLag <- read.csv("58YrLag.csv")
YrLag
lm(YrLag$Sard_B_Alec ~ YrLag$Sard_B_Alec_58lag) # linear model

# Coefficients:
#   (Intercept)  YrLag$Sard_B_Alec_58lag (slope)
# 6.529e+04                2.419e-01  

options(scipen=5) # prevents plot using 1e+05 godawful notation for 100000
plot(YrLag$Sard_B_Alec, YrLag$Sard_B_Alec_58lag) # plot lm
abline(lm(YrLag$Sard_B_Alec_58lag ~ YrLag$Sard_B_Alec)) # trendline
fit <- lm(YrLag$Sard_B_Alec ~ YrLag$Sard_B_Alec_58lag) # save as object for summary
summary(fit)

# Residuals:
#   Min     1Q Median     3Q    Max 
# -74539 -15049    -62  25957  53542 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)   
# (Intercept)             6.529e+04  2.669e+04   2.446  0.05007 . 
# YrLag$Sard_B_Alec_58lag 2.419e-01  6.491e-02   3.726  0.00978 **
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 42020 on 6 degrees of freedom
# Multiple R-squared:  0.6983,	Adjusted R-squared:  0.648 
# F-statistic: 13.89 on 1 and 6 DF,  p-value: 0.009777
# 
summary(fit)$r.squared # rsquared value
summary(fit)$coefficients[,4][[2]] #p value

text(x = 200000, y = 100000, paste0("Rsquared: ", round(summary(fit)$r.squared, digits = 3), ", P: ", round(summary(fit)$coefficients[,4][[2]], digits = 3))) # add text to plot
mtext("Sardine biomass (mt) 1951:8 (x) vs 2009:16 (y). 58 year lag", side = 3) # add title
