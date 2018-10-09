#Returns logistic (s shaped) curve transformed values of a vector, scaled to
#user's preferred max with customisable steepness
#Simon Dedman 2018.10.08
#
install.packages("scales")
require(scales)
CmacAbund <- c(106122.41628,
               107825.64546,
               190067.10818,
               176826.52857,
               204995.42286,
               177107.39456,
               152284.29627,
               175194.3233,
               165258.01094,
               168815.79354,
               178768.86783,
               173534.25608,
               121374.79138,
               78300.84738,
               49233.06645,
               45200.55319,
               52393.392505,
               89824.193624,
               118221.144654,
               119982.10434,
               128223.95145,
               117582.52636,
               113241.1301,
               173385.9554,
               243212.13626,
               792512.32041,
               1003546.6474,
               1387630.725,
               1523097.1188,
               1371604.00448,
               1614324.2772,
               1357731.649,
               1232158,
               1015198,
               769193,
               623942,
               540583,
               415901,
               528642,
               487471,
               401944,
               336077,
               275830,
               300923,
               295906,
               341396,
               321280,
               228936,
               131951,
               91954,
               55767,
               46346,
               32105,
               31716,
               38653,
               58058,
               67256,
               68394,
               66764,
               57927,
               57125,
               69166,
               71728,
               97400,
               120439,
               118971)

#Logistic function:
logisticcurve <-function(x, #vector of values
                         L=1, #max value
                         K=1){ #steepness
  y <- rescale(x, to = c(-6, 6)) #rescale users values to within range of e
  fy <- 1/(1 + exp(-K*(y - 0))) #logistic function X0 centred on 0, L=1
  fx <- fy * L #scale up to L
  return(fx)
}

cmaccurve <- logisticcurve(x=CmacAbund,
                           L = 0.1,
                           K = 1)
plot(CmacAbund, cmaccurve)
plot(CmacAbund)