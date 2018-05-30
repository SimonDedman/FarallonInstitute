install.packages("R.matlab")
setwd("C:/Users/simon/Documents/FI Julie Jumpdrive/forage gold/ichthyoplankton/extracted data")

for (i in 1951:2011) {
  assign(paste0("plank",i), readMat(paste0(i, ".mat")))
}

setwd("C:/Users/simon/Documents/FI Julie Jumpdrive/anchovy ichthyoplankton/interpolation/clean run full")
for (i in c(1951:1969,1972,1974,1975,1977:2011)) {
  assign(paste0("AS_int",i), readMat(paste0(i, ".mat")))
}
# A & S larvae & egg data from jan to may: lat lon data resample
plank1951$an.l.resample.jan
plank1951$an.l.resample.feb
# what is resample?
# 
# for jan to may
# for e & l
# for a & s?
# are lat lon cells the same?
# could do (cols): year lat lon data_egg data_larvae, 2 objects, a & s
AS_int1951$an.l.lat.mar
AS_int2011$an.l.lat.mar
#test