#Returns logistic (s shaped) curve transformed values of a vector, scaled to
#user's preferred max with customisable steepness
#Simon Dedman 2018.10.08
#

logisticRescale <- function(x, #vector of values, dfs coerced by 1st item
                            L=1, #max value
                            K=1){ #steepness
  #install.packages("scales")
  require(scales)
  if(is.data.frame(x)) x <- x[[1]] #speculatively extract first vector if df used
  y <- rescale(x, to = c(-6, 6)) #rescale users values to within range of e
  fy <- 1/(1 + exp(-K*(y - 0))) #logistic function X0 centred on 0, L=1
  fx <- fy * L #scale up to L
  #plot(x, fx, pch = 20)
  #plot(x = rownames(x), y = fx, pch = 20)
  return(fx)
}