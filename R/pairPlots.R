#Isaac Zhao's panel.cor with tweaks by SD####
# 2018.09.21
# https://stackoverflow.com/questions/31851537/set-backgroud-color-of-a-panel-in-pairs-function-call

#BUGS####
# variable names in the diag are too small when run first then right size when run again oddly
# histogram seems cutoff on the left?

#install.packages("corrgram")
library(corrgram)
##corrgram also gives you some nice panel options to use in pairs, but you dont necesarily need them
##e.g. panel.ellipse, panel.pie, panel.conf
#install.packages("asbio")
library(asbio)
##asbio offers more panel options, such as a linear regression (panel.lm) etc
options(scipen=5) # prevents plot using 1e+05 godawful notation for 100000

# install.packages("RColorBrewer")  # Needed to get color gradient
library(RColorBrewer)
cols = brewer.pal(11, "RdBu")   # goes from red to white to blue
pal = colorRampPalette(cols)
cor_colors = data.frame(correlation = seq(-1,1,0.01), 
                        correlation_color = pal(201)[1:201]) # assigns color 4 each r corr value
cor_colors$correlation_color = as.character(cor_colors$correlation_color)

panel.cor <- function(x, y, digits = 2, cex.cor, ...) # SD edits
{
  par(usr = c(0, 1, 0, 1))
  u <- par('usr'); on.exit(par(u))
  names(u) <- c("xleft", "xright", "ybottom", "ytop")
  r <- abs(cor(x, y, use = "complete.obs")) #SD added complete to ignore NAs
 
  bgcolor = cor_colors[2+(-r+1)*100,2]    # converts correlation into a specific color
  do.call(rect, c(col = bgcolor, as.list(u))) # colors the correlation box

  txt <- format(c(r, 0.123456789), digits = digits)[1]
  txt <- paste0("r:", txt)
  text(0.5, 0.65, txt, cex = 2)
    
  p <- cor.test(x, y)$p.value
  txt2 <- format(c(p, 0.123456789), digits = digits)[1]
  txt2 <- paste0("p:", txt2)
  if (p < 0.01) txt2 <- "p < 0.01"
  text(0.5, 0.35, txt2, cex = 2)
}

##### this function places a histogram of your data on the diagonal
panel.hist <- function(x, ...)
{
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(usr[1:2], 0, 1.5) )
  h <- hist(x, plot = FALSE)
  breaks <- h$breaks; nB <- length(breaks)
  y <- h$counts; y <- y/max(y)
  rect(breaks[-nB], 0, breaks[-1], y, col = "cyan", ...)
}