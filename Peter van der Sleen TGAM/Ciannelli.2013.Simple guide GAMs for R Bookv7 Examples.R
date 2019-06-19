# A simple guide to Generalized Additive Models (GAM): theory and applications for R statistical package
# Version 7, developed for GAM Workshop in Flodevigen, Norway, May 22-24, 2013
# Lorenzo Ciannelli
# College of Earth, Ocean and Atmospheric Sciences, Oregon State University, Corvallis, OR, USA
# lciannel@coas.oregonstate.edu


library(mgcv)

#Running mean
set.seed(999)
n<-20
x<-seq(1:n)/10
yt<-2+3*x^2
y<-yt+2*rnorm(n)
u1<-y*0;u2<-u1
k<-10#number of data points included in the average
y1<-c(rep(y[1],k/2),y,rep(y[n],k/2))
for(i in (1+k/2):(n+k/2)){u1[i-(k/2)]<-mean(y1[(i-k/2):(i+k/2)])}
k<-2#number of data points included in the average
y1<-c(rep(y[1],k/2),y,rep(y[n],k/2))
for(i in (1+k/2):(n+k/2)){u2[i-(k/2)]<-mean(y1[(i-k/2):(i+k/2)])}
plot(x,y, main='Running mean smoother')
lines(x,yt,lty=2)
lines(x,u2,col='blue')
lines(x,u1,col='red')
legend(c(0.1,0.5),c(10,15),legend=c('real function','10 obs','3 obs'),lty=c(2,1,1),col=c(1,'red','blue'),bty='n')

#POLYNOMIAL BASIS: a function to draw 4th order polynomial bases
pl.base<-function(coeff){
x<-seq(0,1,length=20)
f1<-rep(coeff[1],20)*1
f2<-coeff[2]*x
f3<-coeff[3]*x^2
f4<-coeff[4]*x^3
f5<-coeff[5]*x^4
f6<-f1+f2+f3+f4+f5
quartz()
par(mfrow=c(2,3))
plot(x,f1,main=paste(coeff[1]),type='b')
plot(x,f2,main=paste(coeff[2],'X'),type='b')
plot(x,f3,main=paste(coeff[3],'X^2'),type='b')
plot(x,f4,main=paste(coeff[4],'X^3'),type='b')
plot(x,f5,main=paste(coeff[5],'X^4'),type='b')
plot(x,f6,main='Sum of all basis function',type='b',col='red')
}

pl.base(c(1,1,1,1,1))
pl.base(c(4.31,-10.72,16.8,2.22,-10.88))

#SPLINE BASIS: draw function, need 3 knots [0-1] and 5 coeff
cs.base<-function(coeff,knots){
x<-seq(0,1,length=20)
f1<-rep(coeff[1],20)*1
f2<-coeff[2]*x
f3<-coeff[3]*(abs(x-knots[1]))^3
f4<-coeff[4]*(abs(x-knots[2]))^3
f5<-coeff[5]*(abs(x-knots[3]))^3
f6<-f1+f2+f3+f4+f5
quartz()
par(mfrow=c(2,3))
plot(x,f1,main=paste(coeff[1]),type='b')
plot(x,f2,main=paste(coeff[2],'b2=X'),type='b')
plot(x,f3,main=paste(coeff[3],'ABS(X-K1)^3'),type='b')
plot(x,f4,main=paste(coeff[3],'ABS(X-K2)^3'),type='b')
plot(x,f5,main=paste(coeff[3],'ABS(X-K3)^3'),type='b')
plot(x,f6,main='Sum of all basis function',type='b',col='red')
}

cs.base(coeff=c(1,1,1,1,1),knots=c(0.25,0.5,0.75))
cs.base(coeff=c(4.31,-10.72,16.8,2.22,-10.88),knots=c(0.25,0.5,0.75))

#Polynomial vs CS basis functions
set.seed(1)
x<-sort(runif(40)*10)^0.5
y<-sort(runif(40))^0.1
plot(x,y)

poly.lm5<-lm(y~poly(x,5))
poly.lm10<-lm(y~poly(x,10))
new.x<-seq(min(x),max(x),length=200)
lines(new.x,predict(poly.lm5,newdata=data.frame(x=new.x)),lwd=2)
lines(new.x,predict(poly.lm10,newdata=data.frame(x=new.x)),col='red',lwd=2)

sb<-function(x,xk){abs(x-xk)^3}
q<-11
xk<-((1:(q-2)/(q-1))*10)^0.5
form<-paste('sb(x,xk[',1:(q-2),'])',sep='',collapse='+')
form<-paste('y~x+',form)
cs.lm<-lm(formula(form))
lines(new.x,predict(cs.lm,newdata=data.frame(x=new.x)),col='green',lwd=2)
rug(new.x)
legend(2.0,0.8,legend=c('poly.5','poly.10','c.spline11'),col=c('black','red','green'),lty=1,bty='n',lwd=2)

#CV: why it is good measure of compromise (Fig. 5, pag 13)
par(mfrow=c(2,2))
set.seed(999)
x<-seq(0,1,length=10)
f<-3*x^3
y<-3*x^3+0.6*rnorm(length(x))
dat<-data.frame(x=x,y=y)
plot(x,y,main='All data cases',pch=16)
#lines(x,f,lty=2)
rough.fit<-gam(y~s(x,k=6,fx=T),data=dat)
summary(rough.fit)
smooth.fit<-gam(y~s(x,k=4,fx=T),data=dat)
summary(smooth.fit)
dat<-data.frame(x=seq(0,1,length=50))
lines(x,smooth.fit$fitted,col='red')
lines(dat$x,predict(rough.fit,newdata=dat),col='blue')
legend(c(0,0.4),c(1.3,2.3),legend=c('obs','smooth','rough'),lty=c(0,1,1),pch=c(16,-1,-1),col=c('black','red','blue'),bty='n')
 
x.1<-x[c(1:2,4:10)]
y.1<-y[c(1:2,4:10)]
dat<-data.frame(x=x.1,y=y.1)
plot(x,y,main='One missing obs')
points(x.1,y.1,pch=16)
#lines(x,f,lty=2)
rough.fit<-gam(y~s(x,k=6,fx=T),data=dat)
summary(rough.fit)
smooth.fit<-gam(y~s(x,k=3,fx=T),data=dat)
summary(smooth.fit)
lines(x.1,smooth.fit$fitted,col='red')
dat<-data.frame(x=seq(0,1,length=50))
lines(dat$x,predict.gam(rough.fit,newdata=dat),col='blue')

#Additive example: 2 significant variables (Pag. 21)
library(mgcv)

set.seed(999)
x1<-runif(100)
x2<-runif(100)
e<-0.5*rnorm(100)
y<-5*x1^3+sin(3*pi*x2)+e
dat<-data.frame(x1=x1,x2=x2,y=y)
pairs(dat)
model1<-gam(y~s(x1)+s(x2),data=dat)
summary(model1)
#R-sq.(adj) =  0.912   Deviance explained =   92%
#GCV score = 0.22137   Scale est. = 0.19842   n = 100
#Note scale est. ~ 0.5^2
plot(model1,pages=1,residuals=T,pch=1)
mean(y)

predict.gam(model1,type='terms')[1:10,]

#Making our own plot: Pag 25
predX1<-predict.gam(model1,type='terms')[,1]
predX2<-predict.gam(model1,type='terms')[,2]
sum(predX1)
sum(predX2)
seX1<-predict.gam(model1,type='terms',se.fit=T)[[2]][,1]
seX2<-predict.gam(model1,type='terms',se.fit=T)[[2]][,2]
quartz()
par(mfrow=c(2,1))
plot(sort(x1),predX1[order(x1)],xlab='x1',ylab='additive effect',type='l',ylim=c(-2,4))
lines(sort(x1),predX1[order(x1)]+1.96*seX1[order(x1)],lty=2)
lines(sort(x1),predX1[order(x1)]-1.96*seX1[order(x1)],lty=2)
plot(sort(x2),predX2[order(x2)],xlab='x2',ylab='additive effect',type='l',ylim=c(-2,4))
lines(sort(x2),predX2[order(x2)]+1.96*seX2[order(x2)],lty=2)
lines(sort(x2),predX2[order(x2)]-1.96*seX2[order(x2)],lty=2)

#the 3D plot (Pag. 26)
newdata<-expand.grid(sort(x1),sort(x2)) 
names(newdata)<-c('x1','x2')
realy<-(5*newdata$x1^3+sin(3*pi*newdata$x2))
realy<-matrix(realy,100,100)
par(mfrow=c(1,2))#Partition the graph device in two areas
persp(sort(x1),sort(x2),realy,xlab='x1',ylab="x2",zlab='real y',
main='Real function',theta=30,phi=30,ticktype = "detailed",cex=1.4)
vis.gam(model1,main='Rebuilt function',theta=30,phi=30,ticktype="detailed",color='bw',zlab='predicted y',cex=1.4)

#Additive example: 2 significant variables plus one nonsignificant (Pag 26)
set.seed(999)
x1<-runif(100)
x2<-runif(100)
x3<-runif(100)
e<-0.5*rnorm(100)
y<-5*x1^3+sin(3*pi*x2)+e
dat<-data.frame(x1=x1,x2=x2,x3=x3,y=y)
pairs(dat)
model2<-gam(y~s(x1)+s(x2)+s(x3),data=dat)
summary(model2)
#R-sq.(adj) =  0.886   Deviance explained = 90.2%
#GCV score = 0.28287   Scale est. = 0.24102   n = 100
plot(model2,pages=1,se=T,residuals=T,pch=1)
vis.gam(model2,view=c('x1','x3'),main='Rebuilt function',theta=30,phi=30,ticktype="detailed",color='bw',zlab='predicted y',cex=1.4)

#Additive example (example3): 2 significant variables plus 2 nonsignificant (Pag. 30)
rm(x1,x2,x3,x4)
set.seed(999)
x1<-runif(100)
x2<-runif(100)
x3<-runif(100)
x4<-runif(100)
e<-0.5*rnorm(100)
y<-5*x1^3+sin(3*pi*x2)+e
dat<-data.frame(x1=x1,x2=x2,x3=x3,x4=x4,y=y)
pairs(dat)
model3<-gam(y~s(x1)+s(x2)+s(x3)+s(x4),data=dat)
summary(model3)
#R-sq.(adj) =  0.866   Deviance explained = 88.2%
#GCV score = 0.30799   Scale est. = 0.26983   n = 100
plot(model3,pages=1,se=T, residuals=T,pch=1)

model3.1<-gam(y~s(x1)+s(x2)+s(x4),data=dat)
summary(model3.1)
#R-sq.(adj) =  0.867   Deviance explained = 88.1%
#GCV score = 0.30236   Scale est. = 0.2683    n = 100
plot(model3.1,se=T,residuals=T,pages=1,pch=1)

model3.2<-gam(y~s(x1)+s(x2),data=dat)
summary(model3.2)
#R-sq.(adj) =  0.864   Deviance explained = 87.5%
#GCV score = 0.30419   Scale est. = 0.27513   n = 100

#Anove table: F ratio test (Ho: simpler of two GAM model, 3.2, is correct)
anova(model3.2,model3.1,test='F')
#0.1096: simpler model (less parameters) is correct

#Manually deriving the F-ratio
#First get the total estimated DF
model3.2
#Estimated degrees of freedom:
#2.783311 5.770936   total =  9.554247

model3.1
#Estimated degrees of freedom:
#2.799695 5.71402 1.750989   total =  11.26470

#Then compute the ratio:
((24.8842-23.8076)/(11.26470-9.554247))/((23.8076)/(100-11.26470))

#Note that the Deviance of a model under Normally distributed error is the sum of residuals squares:
sum(model3.2$residuals^2)
#24.88419
sum(model3.1$residuals^2)
#23.80762

#BARENTS SEA COD (Pag 33)
BScod<-read.table('/Users/lciannel/Documents/MyDocuments/GAM class/Flodevigen2/data/Barents Sea cod/cod01.csv',header=T,sep=';')
BScod[1:3,]

age1.0<-gam(age1~s(age0,k=5)+s(age4.6,k=5)+s(temp,k=5)+s(capelin,k=5)+factor(trawl.type),data=BScod)
summary(age1.0)
#R-sq.(adj) =  0.865   Deviance explained = 91.5%
#GCV score = 1.4459   Scale est. = 0.86742   n = 23
plot(age1.0,se=T,residuals=T,pch=1,pages=1)

age1.1<-gam(age1~s(age0,k=5)+s(age4.6,k=5)+s(temp,k=5)+factor(trawl.type),data=BScod)
summary(age1.1)
#R-sq.(adj) =  0.821   Deviance explained = 85.9%
#GCV score = 1.5386   Scale est. = 1.1528    n = 23
plot(age1.1,se=T,residuals=T,pch=1,pages=1)
anova(age1.1,age1.0,test='F')
#0.08445 (null hypothesis is true, age1.1 applies)

age1.2<-gam(age1~s(age0,k=5)+s(age4.6,k=5)+factor(trawl.type),data=BScod)
summary(age1.2)
#R-sq.(adj) =  0.805   Deviance explained = 83.7%
#GCV score =  1.567   Scale est. = 1.2548    n = 23
par(mfrow=c(2,2))
plot(age1.2,se=T,residuals=T,pch=1)
anova(age1.2,age1.1,test='F')
#0.1385 (null hypothesis is true, age1.2 applies)

#Transformation
library(acepack)

par(mfrow=c(2,3))
ace.cod<-ace(exp(BScod[,c(3,6)]),exp(BScod$age1))
plot(ace.cod$x[1,],ace.cod$tx[,1])
plot(ace.cod$x[2,],ace.cod$tx[,2])
plot(ace.cod$y,ace.cod$ty)

avas.cod<-avas(exp(BScod[,c(3,6)]),exp(BScod$age1))
plot(avas.cod$x[,1],avas.cod$tx[,1])
plot(avas.cod$x[,2],avas.cod$tx[,2])
plot(avas.cod$y,avas.cod$ty)

#PARTIAL RESIDUALS (Pag. 40)
#Outlier effect
set.seed(999)
x1<-runif(100)
x2<-runif(100)
e<-0.5*rnorm(100)
y<-5*x1^3+sin(3*pi*x2)+e+c(rep(0,49),3,rep(0,50))
dat<-data.frame(x1=x1,x2=x2,y=y)
model1<-gam(y~s(x1)+s(x2),data=dat)
summary(model1)
#R-sq.(adj) =  0.857   Deviance explained = 86.9%
#GCV score = 0.37227   Scale est. = 0.33616   n = 100
plot(model1,residuals=T,pch=1,pages=1)

#model outlier (Pag. 41)
outlier<-c(rep(0,49),1,rep(0,50))
model1.1<-gam(y~s(x1)+s(x2)+factor(outlier),data=dat)
summary(model1.1)
#R-sq.(adj) =  0.917   Deviance explained = 92.6%
#GCV score = 0.21884   Scale est. = 0.19381   n = 100
plot(model1.1,residuals=T,pch=1,pages=1)

#Another way to get the partial residuals (Pag. 43)
predX1<-predict.gam(model1,type='terms')[,1]
predX2<-predict.gam(model1,type='terms')[,2]
seX1<-predict.gam(model1,type='terms',se.fit=T)[[2]][,1]
seX2<-predict.gam(model1,type='terms',se.fit=T)[[2]][,2]
res<-residuals(model1)

resX1<-predX1+res
resX2<-predX2+res
quartz()
par(mfrow=c(1,2))
plot(sort(x1),predX1[order(x1)],xlab='x1',ylab='additive effect',type='l',ylim=c(-2,4.2))
lines(sort(x1),predX1[order(x1)]+1.96*seX1[order(x1)],lty=2)
lines(sort(x1),predX1[order(x1)]-1.96*seX1[order(x1)],lty=2)
points(x1,resX1,pch=1)
rug(x1)
plot(sort(x2),predX2[order(x2)],xlab='x2',ylab='additive effect',type='l',ylim=c(-2,4.2))
lines(sort(x2),predX2[order(x2)]+1.96*seX2[order(x2)],lty=2)
lines(sort(x2),predX2[order(x2)]-1.96*seX2[order(x2)],lty=2)
points(x2,resX2,pch=1)
rug(x2)

#MODEL DIAGNOSTIC: full residuals (Pag. 44)
set.seed(999)
x1<-runif(100)
x2<-runif(100)
e<-0.5*rnorm(100)
y<-5*x1^3+sin(3*pi*x2)+e+c(rep(0,49),3,rep(0,50))
dat<-data.frame(x1=x1,x2=x2,y=y)
model1<-gam(y~s(x1)+s(x2),data=dat)
#summary(model1)
outlier<-c(rep(0,49),1,rep(0,50))
model1.1<-gam(y~s(x1)+s(x2)+factor(outlier),data=dat)
#summary(model1.1)

par(mfcol=c(3,2))
plot(model1$fitted,residuals(model1),xlab='Fitted values',ylab='residuals',main='Model 1')
qqnorm(residuals(model1))
qqline(residuals(model1))
hist(residuals(model1),main='Model 1')
plot(model1.1$fitted,residuals(model1.1),xlab='Fitted values',ylab='residuals',main='Model 1.1')
qqnorm(residuals(model1.1))
qqline(residuals(model1.1))
hist(residuals(model1.1),main='Model 1.1')

#Barents Sea cod (Pag. 45)
BScod<-read.table('/Users/lciannel/Documents/MyDocuments/GAM class/Flodevigen2/data/Barents Sea cod/cod01.csv',header=T,sep=';')
BScod[1:3,]
age1.2<-gam(age1~s(age0,k=5)+s(age4.6,k=5)+factor(trawl.type),data=BScod)
summary(age1.2)
#R-sq.(adj) =  0.805   Deviance explained = 83.7%
#GCV score =  1.567  Scale est. = 1.2548    n = 23

par(mfrow=c(1,3))
plot(age1.2$fitted,residuals(age1.2),xlab='Fitted values',ylab='residuals',main='Barents sea cod')
qqnorm(residuals(age1.2))
qqline(residuals(age1.2))
hist(residuals(age1.2),main='Barents Sea cod')

par(mfcol=c(1,2))
pacf(BScod$age1,main='Age-1 cod')
pacf(residuals(age1.2),main='Residuals')

quartz()
gam.check(age1.2)

#Bad model structure: multiplicative error (Pag. 47)
set.seed(999)
x1<-runif(100)
x2<-runif(100)
e<-0.1*rnorm(100)
y<-exp(0.25*x1^3+sin(3*pi*x2)+e)
model2<-gam(y~s(x1)+s(x2))
gam.check(model2)
#summary(model2)

#Transformation
library(acepack)

par(mfrow=c(2,3))
ace.model12<-ace(data.frame(x1=x1,x2=x2),y)
plot(ace.model12$x[1,],ace.model12$tx[,1])
plot(ace.model12$x[2,],ace.model12$tx[,2])
plot(ace.model12$y,ace.model12$ty)

avas.model12<-avas(data.frame(x1=x1,x2=x2),y)
plot(avas.model12$x[,1],avas.model12$tx[,1])
plot(avas.model12$x[,2],avas.model12$tx[,2])
plot(avas.model12$y,avas.model12$ty)

#Refit bad model structure with transformed y
model12.t<-gam(avas.model12$ty~s(x1)+s(x2))
summary(model12.t)
plot(model12.t,pch=1,pages=1,res=T)
#R-sq.(adj) =  0.987   Deviance explained = 98.8%
#GCV score = 0.015304   Scale est. = 0.013584  n = 100
gam.check(model12.t)

#GENERALIZED ADDITIVE MODELS
#GAM: binomial example (Pag. 50)
set.seed(999)
x1<-runif(100)
x2<-runif(100)
e<-0.1*rnorm(100)
y<-0.25*x1^3-sqrt(0.1*x2)+e
dat<-data.frame(x1=x1,x2=x2,y=y)
model1<-gam(y~s(x1)+s(x2),data=dat)
summary(model1)
#R-sq.(adj) =  0.592   Deviance explained = 60.8%
#GCV score = 0.0085292   Scale est. = 0.0081116  n = 100
plot(model1,pages=1,residuals=T,pch=1)

ypres<-1*(y>=median(y))
dat<-data.frame(x1=x1,x2=x2,ypres=ypres)
model1.1<-gam(ypres~s(x1)+s(x2),family=binomial,data=dat)
summary(model1.1)
#R-sq.(adj) =  0.459   Deviance explained = 41.6%
#UBRE score = -0.090567  Scale est. = 1    n = 100
quartz()
plot(model1.1,pages=1,residuals=T,pch=1)

round(range(predict.gam(model1.1)),3)
round(range(predict.gam(model1.1,type='response')),3)

round(range(exp(predict.gam(model1.1))/(1+exp(predict.gam(model1.1)))),3)

#larval growth (Steve Porter data) Pag. 53
larvae<-read.table('/Users/lciannel/Documents/MyDocuments/GAM class/Flodevigen2/data/LarvalGrowth.csv',header=T,sep=';')
head(larvae)
larvae.gam<-gam(fastslow~s(sl,k=4)+s(celldiv,k=4),family=binomial,data=larvae)
summary(larvae.gam)
#R-sq.(adj) =  0.673   Deviance explained = 62.9%
#UBRE score = -0.31778  Scale est. = 1         n = 57
plot(larvae.gam,residuals=T,pch=1,pages=1)

#PARALLEL REGRESSIONS (Pag. 55)
set.seed(999)
x1<-runif(200)
x2<-factor(c(rep(0,100),rep(1,100)))
y1<-3+sin(2*pi*x1[1:100])+0.3*rnorm(100)
y2<-5+sin(2*pi*x1[101:200])+0.3*rnorm(100)
y<-c(y1,y2)
dat<-data.frame(x1=x1,x2=x2,y=y)
model1<-gam(y~s(x1)+x2,data=dat)
summary(model1)
#R-sq.(adj) =  0.946   Deviance explained = 94.8%
#GCV score = 0.090477   Scale est. = 0.086965  n = 200

plot(x1,y,type='n',main='Parallel functions')
points(x1[1:100],y1,col='red',pch=16)
points(x1[101:200],y2,col='blue',pch=16)
lines(sort(x1[1:100]),model1$fitted[1:100][order(x1[1:100])],col='red')
lines(sort(x1[101:200]),model1$fitted[101:200][order(x1[101:200])],col='blue')

#Alternative model formulation without intercept
model2<-gam(y~s(x1)+x2-1,data=dat)
summary(model2)
#R-sq.(adj) =  0.946   Deviance explained = 99.5%
#GCV score = 0.090477   Scale est. = 0.086965  n = 200

u1<-1*(x2==0)
u2<-1*(x2==1)
model1.1<-gam(y~s(x1)+u1+u2-1,data=dat)
summary(model1.1)
#R-sq.(adj) =  0.946   Deviance explained = 99.5%
#GCV score = 0.090477   Scale est. = 0.086965  n = 200

model1.2<-gam(y~s(x1)+u1,data=dat)
summary(model1.2)
#A bad way to code the model:
model1.2<-gam(y~s(x1)+u1-1,data=dat)
summary(model1.2)

#CHAPTER 9, Example 1: Variable functions (Pag. 60) 
set.seed(999)
x1<-runif(200)
x2<-c(rep(0,100),rep(1,100))
y1<-3+sin(2*pi*x1[1:100])+0.3*rnorm(100)
y2<-5+cos(2*pi*x1[101:200])+0.3*rnorm(100)
y<-c(y1,y2)
dat<-data.frame(x1=x1,x2=x2,y=y)

d1<-subset(dat, x2==1)
d2<-subset(dat, x2==0)
plot(y~x1, data=d1)
plot(y~x1, data=d2)

#model6<-gam(y~s(x1,by=factor(x2))-1,data=dat)
model6<-gam(y~factor(x2)+s(x1,by=factor(x2))-1,data=dat)
summary(model6)
#R-sq.(adj) =  0.948   Deviance explained = 99.5%
#GCV score = 0.091148   Scale est. = 0.085732  n = 200
plot(model6,pages=1,res=T,pch=1)#note wrong partial residuals!!

#Alternative formulation with regimes not centered around zero
model6.1<-gam(y~s(x1,by=I(1*(x2==1)))+s(x1,by=I(1*(x2==0)))-1,data=dat)
summary(model6.1)
#R-sq.(adj) =  0.948   Deviance explained = 99.5%
#GCV score = 0.091148   Scale est. = 0.085732  n = 200
#Note intercept terms, not corresponding to the actual level of the regime
plot(model6.1,pages=1,res=T,pch=1)#note that the two regimes are now scaled to the actual level of Y

#Plot of smooth effect and partial residuals
predX1<-predict.gam(model6,type='terms')[,2][x2==0]
predX2<-predict.gam(model6,type='terms')[,3][x2==1]
seX1<-predict.gam(model6,type='terms',se.fit=T)[[2]][,2][x2==0]
seX2<-predict.gam(model6,type='terms',se.fit=T)[[2]][,3][x2==1]
res<-residuals(model6)
resX1<-predX1+res[x2==0]
resX2<-predX2+res[x2==1]

quartz()
par(mfrow=c(3,1))
plot(sort(x1[x2==0]),predX1[order(x1[x2==0])],xlab='x1',ylab='additive effect',type='l',ylim=c(-1.5,1.5),main='First regime')
lines(sort(x1[x2==0]),predX1[order(x1[x2==0])]+1.96*seX1[order(x1[x2==0])],lty=2)
lines(sort(x1[x2==0]),predX1[order(x1[x2==0])]-1.96*seX1[order(x1[x2==0])],lty=2)
points(x1[x2==0],resX1,pch=1)
rug(x1[x2==0])
plot(sort(x1[x2==1]),predX2[order(x1[x2==1])],xlab='x1',ylab='additive effect',type='l',ylim=c(-1.5,1.5),main='Second regime')
lines(sort(x1[x2==1]),predX2[order(x1[x2==1])]+1.96*seX2[order(x1[x2==1])],lty=2)
lines(sort(x1[x2==1]),predX2[order(x1[x2==1])]-1.96*seX2[order(x1[x2==1])],lty=2)
points(x1[x2==1],resX2,pch=1)
rug(x1[x2==1])

#Plot model effect on the scale of the predictions
plot(x1,y,type='n',main='Variable functions')
points(x1[1:100],y1,col='red',pch=16)
points(x1[101:200],y2,col='blue',pch=16)
lines(sort(x1[1:100]),model6$fitted[1:100][order(x1[1:100])],col='red')
lines(sort(x1[101:200]),model6$fitted[101:200][order(x1[101:200])],col='blue')

#UNIVARIATE THRESHOLD (P64)####
source('/Users/lciannel/Documents/MyDocuments/GAM class/Flodevigen2/ThresholdGam.R')
#same intercept

set.seed(999)
x1<-runif(200)#x values, explanatory
th.var<-1:length(x1)#threshold variable
y1<-3+sin(2*pi*x1[1:50])+0.3*rnorm(50)
y2<-3+cos(2*pi*x1[51:200])+0.3*rnorm(150)
y<-c(y1,y2) #response variable composed of 50sine values then 150cos values
dat<-data.frame(x1=x1,th.var=th.var,y=y)
dat<-dat[sample(order(th.var)),]
rm(th.var,x1,y)

model1<-threshold.gam(formula(y~s(x1, #s=smooth
                                  by=factor(I(1*(th.var>r))))),
                      #I means brackets calculated not used as additive & interaction effect in gam
                      a=0.1,
                      b=0.9,
                      nthd=100,
                      data=dat,
                      threshold.name='th.var')

summary(model1$res)
#R-sq.(adj) =   0.85   Deviance explained = 85.8%
#GCV score = 0.091983   Scale est. = 0.087046  n = 200
th<-model1$mr #location along the threshold variable of the GCV minimum

model1$mr # 49.556 threshold position of lowest GCV
model1$mgcv # 0.09198273 lowest GCV value

#Make a regular GAM model because you can't plot from the threshold model outputs
model1.1<-gam(y~s(x1,by=factor(I(1*(th.var>th)))),
              data=dat)
summary(model1.1)
#R-sq.(adj) =   0.85   Deviance explained = 85.8%
#GCV score = 0.091983   Scale est. = 0.087046  n = 200

#Partial residuals
predX1<-predict.gam(model1.1,type='terms')[,1][dat$th.var<=th]
predX2<-predict.gam(model1.1,type='terms')[,2][dat$th.var>th]
res<-residuals(model1.1)
resX1<-predX1+res[dat$th.var<=th]
resX2<-predX2+res[dat$th.var>th]

#Plotting
attach(dat)
par(mfrow=c(3,2))
plot(model1.1,pch=1,select=1,main='Sin',rug=F)
points(x1[dat$th.var<=th],resX1,pch=1)
rug(x1[dat$th.var<=th])
plot(model1.1,pch=1,select=2,main='Cosin',rug=F)
points(x1[dat$th.var>th],resX2,pch=1)
rug(x1[dat$th.var>th])
plot(y=residuals(model1$res),x=predict(model1$res),main='Fitted vs residuals',xlab='Fitted', ylab='Residuals')
hist(residuals(model1$res),main='Residuals histogram')
plot(model1$rv,model1$gcvv,type='l',xlab='Threshold variable',ylab='GCV')
abline(v=model1$mr)
detach(dat)

#Different functions and intercept (Pag. 67)
rm(model2,x1,x2,y1,y2,y,u1,u2,dat,th.var,r,th)
set.seed(999)
x1<-runif(200) #x values, explanatory
th.var<-1:length(x1)#threshold variable
y1<-3+sin(2*pi*x1[1:49])+0.3*rnorm(49)
y2<-5+cos(2*pi*x1[50:200])+0.3*rnorm(151)
y<-c(y1,y2) #response variable composed of 49sine values then 151cos values
dat<-data.frame(x1=x1,th.var=th.var,y=y)
dat<-dat[sample(order(th.var)),]
rm(model2,x1,x2,y1,y2,y,u1,u2,th.var,r,th)

model2<-threshold.gam(formula(y~factor(I(1*(th.var>r)))+s(x1,by=factor(I(1*(th.var>r))))-1),
                      a=0.1,
                      b=0.9,
                      nthd=100,
                      data=dat,
                      threshold.name='th.var')
summary(model2$res)
#R-sq.(adj) =  0.938   Deviance explained = 99.6%
#GCV score = 0.092781   Scale est. = 0.087393  n = 200
th<-model2$mr

#Make a regular GAM model
model2.1<-gam(y~factor(I(1*(th.var>th)))+s(x1,by=factor(I(1*(th.var>th))))-1,data=dat)
summary(model2.1)
#R-sq.(adj) =  0.938   Deviance explained = 94.2%
#GCV score = 0.092781   Scale est. = 0.087393  n = 200

#Partial residuals
predX1<-predict.gam(model2.1,type='terms')[,2][dat$th.var<=th]
predX2<-predict.gam(model2.1,type='terms')[,3][dat$th.var>th]
res<-residuals(model2.1)
resX1<-predX1+res[dat$th.var<=th]
resX2<-predX2+res[dat$th.var>th]

attach(dat)
par(mfrow=c(3,2))
plot(model2.1,pch=1,select=1,main='Sin',rug=F)
points(x1[dat$th.var<=th],resX1,pch=1)
rug(x1[dat$th.var<=th])
plot(model2.1,pch=1,select=2,main='Sin',rug=F)
points(x1[dat$th.var>th],resX2,pch=1)
rug(x1[dat$th.var>th])
plot(y=residuals(model2$res),x=predict(model2$res),main='Fitted vs residuals',xlab='Fitted', ylab='Residuals')
hist(residuals(model2$res),main='Residuals histogram')
plot(model1$rv,model2$gcvv,type='l',xlab='Threshold variable',ylab='GCV')
abline(v=model2$mr)
detach(dat)

#BARENTS SEA COD (Pag. 68)
BScod<-read.table('/Users/lciannel/Documents/MyDocuments/GAM class/Flodevigen2/data/Barents Sea cod/cod01.csv',header=T,sep=';')
BScod[1:3,]

#subadult cod and temperature
age1.th1<-threshold.gam(formula(age1~s(age4.6,k=5,by=factor(I(1*(temp<=r))))+s(age0,k=5)+factor(trawl.type)),data=BScod,a=0.15,b=0.85,threshold.name='temp',nthd=20)
summary(age1.th1$res)
#R-sq.(adj) =  0.833   Deviance explained = 86.4%
#GCV score = 1.3678  Scale est. = 1.0704    n = 23

#Make a GAM model
th<-age1.th1$mr
age1.th1.1<-gam(age1~s(age4.6,k=5,by=factor(I(1*(temp<=th))))+s(age0,k=5)+factor(trawl.type),data=BScod)
#summary(age1.th1.1)
#R-sq.(adj) =  0.833   Deviance explained = 86.4%
#GCV score = 1.3678   Scale est. = 1.0704    n = 23

#Partial residuals
predX1<-predict.gam(age1.th1.1,type='terms')[,2][BScod$temp>th]
predX2<-predict.gam(age1.th1.1,type='terms')[,3][BScod$temp<=th]
res<-residuals(age1.th1.1)
resX1<-predX1+res[BScod$temp>th]
resX2<-predX2+res[BScod$temp<=th]

par(mfrow=c(3,2))
plot(age1.th1.1,select=1,main='Age4.6 effect when temp>Th',rug=F)
points(BScod$age4.6[BScod$temp>th],resX1,pch=1)
rug(BScod$age4.6[BScod$temp>th])
plot(age1.th1.1,select=2,main='Age4.6 effect when temp<=Th',rug=F)
points(BScod$age4.6[BScod$temp<=th],resX2,pch=1)
rug(BScod$age4.6[BScod$temp<=th])
plot(age1.th1.1,residuals=T,pch=1,select=3,main='Age-0 effect')
plot(y=residuals(age1.th1$res),x=predict(age1.th1$res),main='Fitted vs residuals',xlab='Fitted', ylab='Residuals')
hist(residuals(age1.th1$res),main='Residuals histogram')
plot(age1.th1$rv,age1.th1$gcvv,type='l',xlab='Threshold variable (temperature)',ylab='GCV',main='GCV profile')
abline(v=age1.th1$mr)

#capelin and temperature (Pag. 72)
age1.th2<-threshold.gam(formula(age1~s(capelin,k=5,by=factor(I(1*(temp<=r))))+s(age0,k=5)+s(age4.6,k=5)+factor(trawl.type)),
data=BScod,a=0.15,b=0.85,threshold.name='temp',nthd=20)
summary(age1.th2$res)
#R-sq.(adj) =  0.856   Deviance explained =   90%
#GCV score = 1.3989   Scale est. = 0.92729   n = 23

#Effect of capelin and temp also in the intercept
age1.th2<-threshold.gam(formula(age1~s(capelin,k=5,by=factor(I(1*(temp<=r))))+
factor(I(1*(temp>r)))+s(age0,k=5)+s(age4.6,k=5)+factor(trawl.type)),
data=BScod,a=0.15,b=0.85,threshold.name='temp',nthd=20)
summary(age1.th2$res)
#R-sq.(adj) =   0.94   Deviance explained = 97.5%
#GCV score = 0.95352  Scale est. = 0.38289   n = 23

#Make a GAM model
th<-age1.th2$mr
age1.th2.1<-gam(age1~s(capelin,k=5,by=factor(I(1*(temp<=th))))+
factor(I(1*(temp>th)))+s(age0,k=5)+s(age4.6,k=5)+factor(trawl.type),data=BScod)
summary(age1.th2.1)
#R-sq.(adj) =   0.94   Deviance explained = 97.5%
#GCV score = 0.95352  Scale est. = 0.38289   n = 23

#Partial residuals
predX1<-predict.gam(age1.th2.1,type='terms')[,3][BScod$temp>th]
predX2<-predict.gam(age1.th2.1,type='terms')[,4][BScod$temp<=th]
res<-residuals(age1.th2.1)
resX1<-predX1+res[BScod$temp>th]
resX2<-predX2+res[BScod$temp<=th]

par(mfrow=c(3,2))
plot(age1.th2.1,select=1,main='Capelin effect when temp>Th',rug=F)
points(BScod$capelin[BScod$temp>th],resX1,pch=1)
rug(BScod$capelin[BScod$temp>th])
plot(age1.th2.1,select=2,main='Capelin effect when temp<=Th',rug=F)
points(BScod$capelin[BScod$temp<=th],resX2,pch=1)
rug(BScod$capelin[BScod$temp<=th])
plot(age1.th2.1,residuals=T,pch=1,select=3,main='Age0 effect')
plot(age1.th2.1,residuals=T,pch=1,select=4,main='Age4.6 effect')
plot(y=residuals(age1.th1$res),x=predict(age1.th1$res),main='Fitted vs residuals',xlab='Fitted', ylab='Residuals')
#hist(residuals(age1.th2$res),main='Residuals histogram')
plot(age1.th2$rv,age1.th2$gcvv,type='l',xlab='Threshold variable (temperature)',ylab='GCV',main='GCV profile')
abline(v=age1.th2$mr)

#BARENT SEA COD GENUINE CV (Pag. 75)
age1.2.cv<-gam.cv(response.name='age1',formula(age1~s(age0,k=5)+s(age4.6,k=5)+factor(trawl.type)),data=BScod)
age1.2.cv$cv
#2.184501

age1.th1.cv<-threshold.gam.cv(response.name='age1',formula(age1~s(age4.6,k=5,by=factor(I(1*(temp<=r))))+s(age0,k=5)+factor(trawl.type)),data=BScod,a=0.15,b=0.85,threshold.name='temp',nthd=20)
age1.th1.cv$cv
#2.623411

age1.th2.cv<-threshold.gam.cv(response.name='age1',formula(age1~s(capelin,k=5,by=factor(I(1*(temp<=r))))+
factor(I(1*(temp>r)))+s(age0,k=5)+s(age4.6,k=5)+factor(trawl.type)),
data=BScod,a=0.15,b=0.85,threshold.name='temp',nthd=20)
age1.th2.cv$cv
#4.397023

#COD EGGS EXAMPLE (Pag. 77)

#Import data
codegg<-read.table('/Users/lciannel/Documents/MyDocuments/GAM class/Flodevigen2/data/codeggs.csv',header=T,sep=';')
names(codegg)
codegg$logd<-log(codegg$density)
codegg$area<-factor(codegg$area)
codegg$year<-factor(codegg$year)

#Additive GAM
gam1<-gam(logd~year+area+s(distsill)+s(log(bdepth))-1,data=codegg)
summary(gam1)
#R-sq.(adj) = 0.687   Deviance explained = 87.1%
#GCV score = 0.57103   Scale est. = 0.48576   n = 217
AIC(gam1)
#490.8488

#Make nice plots
quartz()
par(mfrow=c(2,2),mai=c(0.4,0.6,0.23,0.1))
plot(gam1,select=1,residuals=T,pch=4,rug=F,shade=T,cex=0.8, xlab='Distance from the sill (m)', 
ylab='Anomalies of egg density')
abline(v=0)
abline(h=0,lty=2)
plot(gam1,select=2,residuals=T,pch=4,rug=F,shade=T,cex=0.8, xlab='Bottom depth (m)', 
ylab='',axes=F)
a<-c(20,30,50,90,150,250,400)
axis(1,log(a),a)
axis(2)
box()
abline(h=0,lty=2)

#TGAM: Latitude effect
gam5<-threshold.gam(logd~year+area+s(distsill,by=factor(I(1*(latsill<=r))))+s(log(bdepth))-1,
data=codegg,threshold.name='latsill',nthd=20,a=0.1,b=0.9)
summary(gam5$res)
#R-sq.(adj) =  0.727   Deviance explained = 89.2%
#GCV score = 0.51704   Scale est. = 0.4235    n = 217

#GAM version of the TGAM
th<-gam5$mr
gam5.1<-gam(logd~year+area+s(distsill,by=factor(I(1*(latsill<=th))))+
s(log(bdepth))-1,data=codegg)
summary(gam5.1)
AIC(gam5.1)
#466.5853

#Plots
quartz()
par(mfrow=c(2,2),mai=c(0.4,0.6,0.23,0.1))
plot(gam5.1,select=1,shade=T,rug=T,cex=0.8,xlab='',ylab='Anomalies of egg density',
main='High latitude',cex.main=0.95)
abline(v=0)
abline(h=0,lty=2)
plot(gam5.1,select=2,shade=T,rug=T,cex=0.8, xlab='Distance from the sill (m)', ylab='',
main='Low latitude',cex.main=0.95)
abline(v=0)
abline(h=0,lty=2)
plot(gam5$rv,gam5$gcvv,type='b',xlab='Latitude (degree N)',ylab='GCV',main='Latitude')
abline(v=gam5$mr)

#TGAM: sill depth effect
gam7<-threshold.gam(logd~factor(year)+area+s(distsill,by=factor(I(1*(sdepth<=r))))+
s(log(bdepth))-1,data=codegg,threshold.name='sdepth',
nthd=20,a=0.1,b=0.9)
summary(gam7$res)
#R-sq.(adj) =  0.722   Deviance explained = 88.6%
#GCV score = 0.51179   Scale est. = 0.43149   n = 217

#GAM version of the TGAM
th<-gam7$mr
gam7.1<-gam(logd~factor(year)+area+s(distsill,by=factor(I(1*(sdepth<=th))))+s(log(bdepth))-1,data=codegg)
summary(gam7.1)
AIC(gam7.1)
#466.4885

quartz()
par(mfrow=c(2,2),mai=c(0.7,0.6,0.23,0.1))
plot(gam7.1,select=1,shade=T,rug=T,cex=0.8, xlab='', ylab='Anomalies of egg density',
main='Deep sill',cex.main=0.95)
abline(v=0)
abline(h=0,lty=2)
plot(gam7.1,select=2,shade=T,rug=T,cex=0.8, xlab='Distance from the sill (m)', ylab='', 
main='Shallow sill',cex.main=0.95)
abline(v=0)
abline(h=0,lty=2)
plot(gam7$rv,gam7$gcvv,type='b',xlab='Sill depth (m)',ylab='GCV',main='Sill depth')
abline(v=gam7$mr)

#Genuine CV: By removing a random sample of 20 obs (n), to be repeated 500 time 
n<-20
subset<-codegg
cv1.na<-1:500
cv1.a<-cv1.na*NA
cv2.na<-cv1.na*NA
for(i in 1:length(cv1.na)){
index<-sample(1:nrow(subset))
data.in<-subset[index[1:(length(index)-n)],]
data.out<-subset[index[(length(index)-(n-1)):length(index)],]
data.in$area<-factor(data.in$area)
data.in$year<-factor(data.in$year)
data.out$area<-factor(data.out$area)
data.out$year<-factor(data.out$year)
gam.na<-gam(logd~year+area+s(distsill,by=factor(I(1*(sdepth<=37.05))))+s(log(bdepth))-1,data=data.in)
gam.na2<-gam(logd~year+area+s(distsill,by=factor(I(1*(latsill<= 60.80326))))+s(log(bdepth))-1,data=data.in)
gam.a<-gam(logd~year+area+s(distsill)+s(log(bdepth))-1,data=data.in)
pred.na<-predict.gam(gam.na,newdata=data.out)
pred.na2<-predict.gam(gam.na2,newdata=data.out)
pred.a<-predict.gam(gam.a,newdata=data.out)
cv1.na[i]<-mean((pred.na-data.out$logd)^2)
cv2.na[i]<-mean((pred.na2-data.out$logd)^2)
cv1.a[i]<-mean((pred.a-data.out$logd)^2)}

mean(cv1.na)
#0.5564628
mean(cv2.na)
#0.5789815
mean(cv1.a)
#0.6124777

#CHAPTER 11: Variable Coefficients GAMS: pag 82

set.seed(999)
X2<-runif(100)
X1<-runif(100)
Y<-sin(2*pi*X2)+(3+cos(2*pi*X2))*X1+0.3*rnorm(100)
dat<-data.frame(X1=X1,X2=X2,Y=Y)
pairs(dat)

#Fully additive GAM
gam1<-gam(Y~s(X1)+s(X2),data=dat)
summary(gam1)
#R-sq.(adj) =  0.917   Deviance explained = 92.2%
#GCV score = 0.10593  Scale est. = 0.097737  n = 100
plot(gam1,pages=1,res=T,shade=T)


#Variable coefficient GAM
gam2<-gam(Y~s(X2)+s(X2,by=X1),data=dat)
summary(gam2)
#R-sq.(adj) =  0.939   Deviance explained = 94.5%
#GCV score = 0.079154  Scale est. = 0.070953  n = 100
plot(gam2,pages=1,res=T,shade=T)

#Note that the ends do not match. Knowing that the ends need to match... we use a cyclic cubic regression spline (cc)
gam3<-gam(Y~s(X2,bs='cc')+s(X2,by=X1,bs='cc'),data=dat)
summary(gam3)
#R-sq.(adj) =  0.943   Deviance explained = 94.9%
#GCV score = 0.076033  Scale est. = 0.066852  n = 100
plot(gam3,pages=1,res=T,shade=T)
#Note the excessive wiggliness of the S(X1) - this can be fixed by increasing the weight on the penalty function using 'gamma' (e.g., gamma=1.5)

#Note that now smooth functions are no longer centered around zero. To get the error terms we need to manually extract them - this can be tricky!
#Get slope terms for X1 and relative error terms
predX2<-predict(gam3,type='terms')[,2]
SEX2<-predict(gam3,type='terms',se.fit=T)[[2]][,2]
res<-residuals(gam3)

slope_X1<-predX2/X1
plot(sort(X2),slope_X1[order(X2)],type='l',ylim=c(-1,4))
lines(sort(X2),((predX2+1.96*SEX2)/X1)[order(X2)],lty=2)
lines(sort(X2),((predX2-1.96*SEX2)/X1)[order(X2)],lty=2)
points(X2,slope_X1+res)

#CHAPTER 12: SPATIAL DATA: thin plate spline and tensor product 
library(maps)#needed for geographic plots
library(mapdata)#for maps
library(geoR)#for variograms
library(PBSmapping)#for UTM conversions
library(fields)#For image legend

#Import data: Arrowtooth flounder data are NOT provided to the class (sorry)
all.catch<-read.table('/Users/lciannel/Documents/MyDocuments/GAM class/Flodevigen2/data/all_catch.txt',sep='',header=T)
atf.350<-read.table('/Users/lciannel/Documents/MyDocuments/GAM class/Flodevigen2/data/atf350.txt',sep='',header=T)
pos.hab<-read.table('/Users/lciannel/Documents/MyDocuments/GAM class/Flodevigen2/data/pos.hab.txt',sep='',header=T)
annual.average<-tapply(atf.350$avg.wt,atf.350$year,mean)
annual.cp<-tapply(atf.350$cp,atf.350$year,mean)

#DEPTH: import data from: http://www.ngdc.noaa.gov/mgg/gdas/gd_designagrid.html
bathy.dat<-read.table('/Users/lciannel/Documents/MyDocuments/Funding/NSF/Geoscience/data/BeringDepth.txt',sep='')
names(bathy.dat)<-c('lon','lat','depth')
bathy.dat$depth[bathy.dat$depth>0]<-NA#Avoid points above water
head(bathy.dat)
bathy.mat<-matrix(bathy.dat$depth,nrow=length(unique(bathy.dat$lon)),ncol=length(unique(bathy.dat$lat)))[,order(unique(bathy.dat$lat))]
land.mask<-(bathy.mat*0)+1
range(land.mask,na.rm=T)

#Function to calculate distance (in m) between two set fo coordinates

distance.function<-function(start.lat, start.lon, end.lat, end.lon)
{
med.lat <- (start.lat + end.lat)/2
rad.lat <- (pi * med.lat)/180
shrink <- cos(rad.lat)
delta.lat <- end.lat - start.lat
delta.lon <- start.lon - end.lon
mpermile <- 111195
distance <- mpermile * sqrt((delta.lon * shrink)^2 + (delta.lat)^2)
distance
}

#Figure 1, pag 88: plot average B, cold pool index and % of occupied habitat 
quartz(width=7,height=9)
par(mfrow=c(3,1),omi=c(1,1,0.3,1.5),mai=c(0.2,0,0.1,0))
years<-sort(unique(atf.350$year))
tmp<-(annual.average-mean(annual.average))/sd(annual.average)
ann.avg.st<-tmp+1.01*abs(min(tmp))
y2at<-((seq(300000,1200000,by=150000)-mean(annual.average))/sd(annual.average))+1.01*abs(min(tmp))

plot(years,ann.avg.st,type='b',pch=16, ylab='',xlab='',axes=F)
axis(1,at=seq(1982,2010,by=4),labels=F);axis(2,cex.axis=1.3);axis(4,at=y2at,labels=format(round(seq(300000,1200000,by=150000)/100000,1),digits=5,trim=T),cex.axis=1.3);box()
mtext('Standardized biomass',2,line=3.5);mtext('Biomass (100000 t)',4,line=3.5)

plot(years,annual.cp,type='b',ylab='',,xlab='',pch=16,axes=F)
axis(1,at=seq(1982,2010,by=4),labels=F);axis(2,cex.axis=1.3);box()
mtext('Temperature (C)',2,line=3.5)

plot(years,pos.hab[,1],type='b',ylab='',xlab='',axes=F)
axis(1,at=seq(1982,2010,by=4),labels=seq(1982,2010,by=4),cex.axis=1.3);axis(2,cex.axis=1.3);box()
mtext('Occupancy',2,line=3.5);mtext('Year',1,line=3.5)

#Figure 2, pag 89: ATF catches during contrasting years of temp and biomass 

#First we interpolate bottom temp (using loess) during the four contrasting years
years<-sort(unique(atf.350$year))
yr.cold1<-1986
yr.cold2<-2007
yr.warm1<-1987
yr.warm2<-2003
bt.loess.cold.1<-loess(bt~lon*lat,span=0.08,degree=2,data=all.catch[all.catch$year==yr.cold1,])
summary(lm(bt.loess.cold.1$fitted~na.exclude(all.catch$bt[all.catch$year==yr.cold1])))
bt.loess.cold.2<-loess(bt~lon*lat,span=0.08,degree=2,data=all.catch[all.catch$year==yr.cold2,])
summary(lm(bt.loess.cold.2$fitted~na.exclude(all.catch$bt[all.catch$year==yr.cold2])))
bt.loess.warm.1<-loess(bt~lon*lat,span=0.08,degree=2,data=all.catch[all.catch$year==yr.warm1,])
summary(lm(bt.loess.warm.1$fitted~na.exclude(all.catch$bt[all.catch$year==yr.warm1])))
bt.loess.warm.2<-loess(bt~lon*lat,span=0.08,degree=2,data=all.catch[all.catch$year==yr.warm2,])
summary(lm(bt.loess.warm.2$fitted~na.exclude(all.catch$bt[all.catch$year==yr.warm2])))


#Make prediction grid using bathymetry grid
lond<-unique(bathy.dat$lon)
latd<-sort(unique(bathy.dat$lat))
predict.grid<-expand.grid(lond,latd)
names(predict.grid)<-c('lon','lat')
for (i in 1: nrow(predict.grid)){
	predict.grid$dist[i]<-min(distance.function(predict.grid$lat[i],predict.grid$lon[i],all.catch$lat,all.catch$lon))}
head(predict.grid)

#Make predictions using LOESS and plot results and remove points too far from observations
bt.pred.cold1<-predict(bt.loess.cold.1,newdata=predict.grid)
	bt.pred.cold1[predict.grid$dist>30000]<-NA
bt.pred.cold2<-predict(bt.loess.cold.2,newdata=predict.grid)
	bt.pred.cold2[predict.grid$dist>30000]<-NA
bt.pred.warm1<-predict(bt.loess.warm.1,newdata=predict.grid)
	bt.pred.warm1[predict.grid$dist>30000]<-NA
bt.pred.warm2<-predict(bt.loess.warm.2,newdata=predict.grid)
	bt.pred.warm2[predict.grid$dist>30000]<-NA
	
#Make Image of BT with ATF catches. Note that to scale bubble size we have to calculate a max and min cpue
maxcpue<-max(log(atf.350$cpuelt+1)[atf.350$year%in%c(yr.warm1,yr.warm2,yr.cold1,yr.cold2)]) 
mincpue<-min(log(atf.350$cpuelt+1)[atf.350$year%in%c(yr.warm1,yr.warm2,yr.cold1,yr.cold2)]) 

#Start building the figure 2
quartz(width=9,height=7)
par(mfrow=c(2,2),omi=c(1,1,0.5,1.0),mai=c(0,0,0,0))

yr=yr.cold1
image(lond,latd,bt.pred.cold1,col=gray(seq(1,0.1,length=100)),zlim=c(-2,7),ylab='',xlab='',ylim=c(54,63),axes=F)
contour(lond,latd,bt.pred.cold1,levels=2,add=T,col='white')
symbols(atf.350$lon[atf.350$year==yr],atf.350$lat[atf.350$year==yr],
circles=log(atf.350$cpuelt[atf.350$year==yr]+1),inches=0.05*max(log(atf.350$cpuelt[atf.350$year==yr]+1))/maxcpue,add=T,bg='black')
contour(unique(bathy.dat$lon),sort(unique(bathy.dat$lat)),bathy.mat,levels=-200,col='grey',add=T,lwd=2)
map("worldHires",fill=T,col="grey",add=T)
prop<-annual.average[years==yr]/(max(annual.average)-min(annual.average))-(min(annual.average)/(max(annual.average)-min(annual.average)))
symbols(-160,61.5,thermometers=matrix(c(1,2.5,prop),nrow=1,ncol=3),add=T,inches=F)
text(-157,54.7,'A',cex=2.5)
box()

yr=yr.warm1
image(lond,latd,bt.pred.warm1,col=gray(seq(1,0.1,length=100)),zlim=c(-2,7),ylab='',xlab='',ylim=c(54,63),axes=F)
contour(lond,latd,bt.pred.warm1,levels=2,add=T,col='white')
symbols(atf.350$lon[atf.350$year==yr],atf.350$lat[atf.350$year==yr],
circles=log(atf.350$cpuelt[atf.350$year==yr]+1),inches=0.05*max(log(atf.350$cpuelt[atf.350$year==yr]+1))/maxcpue,add=T,bg='black')
contour(unique(bathy.dat$lon),sort(unique(bathy.dat$lat)),bathy.mat,levels=-200,col='grey',add=T,lwd=2)
map("worldHires",fill=T,col="grey",add=T)
prop<-annual.average[years==yr]/(max(annual.average)-min(annual.average))-(min(annual.average)/(max(annual.average)-min(annual.average)))
symbols(-160,61.5,thermometers=matrix(c(1,2.5,prop),nrow=1,ncol=3),add=T,inches=F)
text(-157,54.7,'C',cex=2.5)
box()

yr=yr.cold2
image(lond,latd,bt.pred.cold2,col=gray(seq(1,0.1,length=100)),zlim=c(-2,7),ylab='',xlab='',axes=F,ylim=c(54,63))
axis(1,cex.axis=1.5);axis(2,cex.axis=1.5)
symbols(atf.350$lon[atf.350$year==yr],atf.350$lat[atf.350$year==yr],
circles=log(atf.350$cpuelt[atf.350$year==yr]+1),inches=0.05*max(log(atf.350$cpuelt[atf.350$year==yr]+1))/maxcpue,add=T,bg='black')
contour(lond,latd,bt.pred.cold2,levels=2,add=T,col='white')
contour(unique(bathy.dat$lon),sort(unique(bathy.dat$lat)),bathy.mat,levels=-200,col='grey',add=T,lwd=2)
map("worldHires",fill=T,col="grey",add=T)
prop<-annual.average[years==yr]/(max(annual.average)-min(annual.average))-(min(annual.average)/(max(annual.average)-min(annual.average)))
symbols(-160,61.5,thermometers=matrix(c(1,2.5,prop),nrow=1,ncol=3),add=T,inches=F)
text(-157,54.7,'D',cex=2.5)
mtext('Longitude (degree W)',1,line=3.5,cex=1.5)
mtext('Latitude (degree N)',2,line=3.5,cex=1.5)
box()

yr=yr.warm2
image(lond,latd,bt.pred.warm2,col=gray(seq(1,0.1,length=100)),zlim=c(-2,7),ylab='',xlab='',axes=F,ylim=c(54,63))
contour(lond,latd,bt.pred.warm2,levels=2,add=T,col='white')
symbols(atf.350$lon[atf.350$year==yr],atf.350$lat[atf.350$year==yr],
circles=log(atf.350$cpuelt[atf.350$year==yr]+1),inches=0.05*max(log(atf.350$cpuelt[atf.350$year==yr]+1))/maxcpue,add=T,bg='black')
contour(unique(bathy.dat$lon),sort(unique(bathy.dat$lat)),bathy.mat,levels=-200,col='grey',add=T,lwd=2)
map("worldHires",fill=T,col="grey",add=T)
prop<-annual.average[years==yr]/(max(annual.average)-min(annual.average))-(min(annual.average)/(max(annual.average)-min(annual.average)))
symbols(-160,61.5,thermometers=matrix(c(1,2.5,prop),nrow=1,ncol=3),add=T,inches=F)
text(-157,54.7,'E',cex=2.5)
symbols(rep(-177.8,4),seq(54.5,by=0.7,length=4),circles=seq(4.7,0.1,length=4),add=T,inches=0.05,bg='black')
text(rep(-176,4),seq(54.5,by=0.7,length=4),format(round(seq(4.7,0.1,length=4),1),digits=5,trim=T),cex=1.3)
text(-170.4,54.5,expression(paste("ln (n km"^-2," + 1)")),cex=1.3)
box()
mtext('Temperature (C)',4,line=4,cex=1.5)
par(omi=c(1,1,0.5,0.5))
image.plot(legend.only=T,zlim=c(-2,7),col=gray(seq(1,0.1,length=100)),legend.args=list(cex.axis=2))

#GAM1: fully additive, Normal, no 0s
subdata <- na.omit(atf.350)
subdata$bt<-(subdata$bt-mean(subdata$bt))/sd(subdata$bt)
subdata$bt<-subdata$bt+1.01*abs(min(subdata$bt))
subdata$avg.wt<-(subdata$avg.wt-mean(subdata$avg.wt))/sd(subdata$avg.wt)
subdata$avg.wt<-subdata$avg.wt+1.01*abs(min(subdata$avg.wt))
#Note we constrain df (k=5) to reduce excessive wiggliness
gam1 <- gam(log(cpuelt+1)~avg.wt+bt+s(lon,lat)+s(depth,k=5)+s(phi,k=5),data=subdata)
summary(gam1)
gam.check(gam5,pages=1)
#R-sq.(adj) =  0.535   Deviance explained =   54%
#GCV score = 0.62159  Scale est. = 0.61454   n = 3272
AIC(gam1) 
[1] 7731.362

#plot gam1
quartz()
par(mfrow=c(2,2),mai=c(0.35,0.45,0.15,0.05))
vis.gam(gam1,view=c('lon','lat'),plot.type="contour",color="topo",too.far=.05,main='',ylab='')
text(-175,55.5,labels='Position',cex=1.5)
map("worldHires",fill=T,col="grey",add=T)
#contour(unique(bathy.dat$lon),sort(unique(bathy.dat$lat)),bathy.mat,levels=-seq(20,300,by=20),labcex=0.4,col='grey',add=T)
plot(gam1,select=2,shade=T,scale=0,rug=F,res=F,ylab='')
text(125,-1.6,labels='Depth (m)',cex=1.5)
plot(gam1,select=3,shade=T,scale=0,rug=F,res=F,ylab='')
text(3.3,-1,labels='-log_2(Sediment size)',cex=1.5)
hist(log(subdata$cpuelt+1),main='Histogram of ATF ln(cpue)')

#MODEL2: threshold effect of population B on position
biom<-sort(unique(subdata$avg.wt))[5:25]
aic.bio<-biom*NA
for(i in 1:length(biom)){
gam.obj <- gam(log(cpuelt+1)~avg.wt+bt+s(lon,lat,by=I(1*(avg.wt<=biom[i])))+
s(lon,lat,by=I(1*(avg.wt>biom[i])))+s(depth,k=5)+s(phi,k=5),data=subdata)
aic.bio[i]<-gam.obj$aic}

th<-biom[order(aic.bio)[1]]
subdata$th<-biom[order(aic.bio)[1]]

par(mfrow=c(2,1),omi=c(0,1,0,1))
plot(biom,aic.bio,type='b',xlab='Standardized biomass',ylab='AIC')
abline(v=th,lty=2)
text(0.7,7500,'Low')
text(2.5,7500,'High')
plot(years[5:25],biom,type='b',ylab='Standardized biomass',xlab='Years')
abline(h=th);abline(v=1995,lty=2)
text(1990,2.7,'Before')
text(1999,2.7,'After')

#The real GAMM
subdata <- na.omit(atf.350)
subdata$bt<-(subdata$bt-mean(subdata$bt))/sd(subdata$bt)
subdata$bt<-subdata$bt+1.01*abs(min(subdata$bt))
subdata$avg.wt<-(subdata$avg.wt-mean(subdata$avg.wt))/sd(subdata$avg.wt)
subdata$avg.wt<-subdata$avg.wt+1.01*abs(min(subdata$avg.wt))
subdata$th<-th
gam.2<- gam(log(cpuelt+1)~bt+avg.wt+s(lon,lat,by=I(1*(avg.wt<=th)))+
+s(lon,lat,by=I(1*(avg.wt>th)))+s(depth,k=5)+s(phi,k=5),data=subdata)
 gam.2$aic
#7430.933

summary(gam.2)
#R-sq.(adj) =  0.579   Deviance explained = 58.7%
#GCV score = 0.56719  Scale est. = 0.55655   n = 3272
#Note nonsignificant intercept: effect absorbed by the two terms of the threshold on position

#Plot position and other univariate effects
par(mfrow=c(2,2),mai=c(0.35,0.3,0.15,0.05))
vis.gam(gam.2,view=c('lon','lat'),cond=list(avg.wt=th*0.5),plot.type="contour",color="topo",too.far=.05,main='Low biomass',zlim=range(predict(gam.2)))
map("worldHires",fill=T,col="grey",add=T)
#Add bubbles of observed cpue to the above plot
symbols(subdata$lon[subdata$avg.wt<=th],subdata$lat[subdata$avg.wt<=th],circle=log(subdata$cpuelt+1)[subdata$avg.wt<=th],inches=0.05*max(log(subdata$cpuelt+1)[subdata$avg.wt<=th])/max(log(subdata$cpuelt+1)),add=T,bg='purple',fg='purple')

vis.gam(gam.2,view=c('lon','lat'),cond=list(avg.wt=th*1.5),plot.type="contour",color="topo",too.far=.05,main='High biomass',zlim=range(predict(gam.2)))
map("worldHires",fill=T,col="grey",add=T)
symbols(subdata$lon[subdata$avg.wt>th],subdata$lat[subdata$avg.wt>th],circle=log(subdata$cpuelt+1)[subdata$avg.wt>th],inches=0.05*max(log(subdata$cpuelt+1)[subdata$avg.wt>th])/max(log(subdata$cpuelt+1)),add=T,bg='purple',fg='purple')

plot(gam1,select=2,shade=T,scale=0,rug=F,res=F,ylab='')
text(125,-1.6,labels='Depth (m)',cex=1.5)
plot(gam1,select=3,shade=T,scale=0,rug=F,res=F,ylab='')
text(3.3,-1,labels='-log_2(Sediment size)',cex=1.5)

#GAM 3: Tensor product with biomass
subdata <- na.omit(atf.350)
subdata$bt<-(subdata$bt-mean(subdata$bt))/sd(subdata$bt)
subdata$bt<-subdata$bt+1.01*abs(min(subdata$bt))
subdata$avg.wt<-(subdata$avg.wt-mean(subdata$avg.wt))/sd(subdata$avg.wt)
subdata$avg.wt<-subdata$avg.wt+1.01*abs(min(subdata$avg.wt))

gam.3<-gam(log(cpuelt+1)~avg.wt+bt+
te(lat,lon,avg.wt,k=c(30,5),d=c(2,1),bs=c("tp","cr"))+
+s(depth,k=5)+s(phi,k=5),data=subdata)
summary(gam.3)
#R-sq.(adj) =  0.608   Deviance explained = 62.2%
#GCV score = 0.53796  Scale est. = 0.51839   n = 3272
AIC(gam.3)
#7254.557

#Plotting predictions from 4 increasing values of average population biomass
quartz()
par(mfrow=c(2,2),omi=c(0.5,0.5,0.5,0.5),mai=c(0.35,0.5,0.5,0.05))
vis.gam(gam.3,view=c('lon','lat'),cond=list(avg.wt=0.6),plot.type="contour",color="topo",too.far=.05,,zlim=range(predict(gam.2)),main='B = 0.6')
map("worldHires",fill=T,col="grey",add=T)
vis.gam(gam.3,view=c('lon','lat'),cond=list(avg.wt=1.5),plot.type="contour",color="topo",too.far=.05,,zlim=range(predict(gam.2)),main='B = 1.5')
map("worldHires",fill=T,col="grey",add=T)
vis.gam(gam.3,view=c('lon','lat'),cond=list(avg.wt=2.2),plot.type="contour",color="topo",too.far=.05,,zlim=range(predict(gam.2)),main='B = 2.2')
map("worldHires",fill=T,col="grey",add=T)
vis.gam(gam.3,view=c('lon','lat'),cond=list(avg.wt=3.0),plot.type="contour",color="topo",too.far=.05,,zlim=range(predict(gam.2)),main='B = 3.0')
map("worldHires",fill=T,col="grey",add=T)

#Movie (it is of interest to let this movie run with all the model formulations implemented in this case study)
avg.vect<-seq(0.1,4,by=0.1)
for(i in 1:length(avg.vect)){vis.gam(gam.2,view=c('lon','lat'),cond=list(avg.wt=avg.vect[i]),plot.type="contour",color="topo",too.far=.05,,zlim=range(predict(gam.2)),main=paste('B = ',avg.vect[i]))
map("world",fill=T,col="grey",add=T)}

#GAM 4: Variable coefficient with interaction
subdata <- na.omit(atf.350)
subdata$bt<-(subdata$bt-mean(subdata$bt))/sd(subdata$bt)
subdata$bt<-subdata$bt+1.01*abs(min(subdata$bt))
subdata$avg.wt<-(subdata$avg.wt-mean(subdata$avg.wt))/sd(subdata$avg.wt)
subdata$avg.wt<-subdata$avg.wt+1.01*abs(min(subdata$avg.wt))

gam.4 <- gam(log(cpuelt+1)~s(lon,lat)+s(lon,lat,by=avg.wt)+ s(lon,lat,by=bt)+s(depth,k=5)+s(phi,k=5),data=subdata)
summary(gam.4)
#R-sq.(adj) =  0.566   Deviance explained = 57.7%
#GCV score = 0.58863  Scale est. = 0.57376   n = 3272
AIC(gam.4)  #7551.393

#Get slope coefficients for average biomass and determine significance (tricky!)
pred<-predict(gam.4,type='terms',se.fit=T)
pred.slope.b<-pred[[1]][,2]/subdata$avg.wt
pred.slope.se.b<-1.96*pred[[2]][,2]
pred.slope.up.b<-(pred[[1]][,2]+pred.slope.se.b)/subdata$avg.wt
pred.slope.low.b<-(pred[[1]][,2]-pred.slope.se.b)/subdata$avg.wt
sign.slope.pos.b<-(1:length(pred.slope.b))[pred.slope.low.b>0]
sign.slope.neg.b<-(1:length(pred.slope.b))[pred.slope.up.b<0]
par(mfrow=c(2,2))
hist(pred.slope.b, main='All slopes, biomass')
hist(pred.slope.se.b,main='Standard error, biomass')
hist(pred.slope.b[sign.slope.pos.b], main='Significantly positive, biomass')
hist(pred.slope.b[sign.slope.neg.b], main='Significantly negative, biomass')
max.b<-max(abs(pred.slope.b))

#Get slope coefficients for BT
pred.slope.t<-pred[[1]][,3]/subdata$bt
pred.slope.se.t<-1.96*pred[[2]][,3]
pred.slope.up.t<-(pred[[1]][,3]+pred.slope.se.t)/subdata$bt
pred.slope.low.t<-(pred[[1]][,3]-pred.slope.se.t)/subdata$bt
sign.slope.pos.t<-(1:length(pred.slope.t))[pred.slope.low.t>0]
sign.slope.neg.t<-(1:length(pred.slope.t))[pred.slope.up.t<0]
par(mfrow=c(2,2))
hist(pred.slope.t, main='All slopes, BT')
hist(pred.slope.se.t,main='Standard error, BT')
hist(pred.slope.t[sign.slope.pos.t], main='Significantly positive, BT')
hist(pred.slope.t[sign.slope.neg.t], main='Significantly negative, BT')
max.t<-max(abs(range(pred.slope.t,finite=T)))

#Plot slopes on a map (tricky!)

par(mfrow=c(2,2),omi=c(0.5,0.5,0.5,0.5),mai=c(0.35,0.5,0.5,0.05))
#Plot average ATF distribution and local effect of avg.B
vis.gam(gam.4,view=c('lon','lat'),plot.type="contour",color="gray",too.far=.04,main='',ylab='')
symbols(subdata$lon[sign.slope.pos.b],subdata$lat[sign.slope.pos.b],
circle=pred.slope.b[sign.slope.pos.b],inches=0.03*max(pred.slope.b[sign.slope.pos.b])/max(max.b,max.t),add=T,fg='white',bg='white')
map("worldHires",fill=T,col="grey",add=T)
text(-159,60.7,labels='A',cex=1.5)
mtext('Longitude (degrees west)',1,line=2.5)
mtext('Latitude (degrees north)',2,line=2.5)
#Plot average ATF distribution and local effect of BT
vis.gam(gam.4,view=c('lon','lat'),plot.type="contour",color="gray",too.far=.04,main='',ylab='')
symbols(subdata$lon[sign.slope.pos.t],subdata$lat[sign.slope.pos.t],
circle=pred.slope.t[sign.slope.pos.t],inches=0.03*max(range(pred.slope.t[sign.slope.pos.t],finite=T))/max(max.b,max.t),add=T,bg='white',fg='white')
symbols(subdata$lon[sign.slope.neg.t],subdata$lat[sign.slope.neg.t],
circle=abs(pred.slope.t[sign.slope.neg.t]),inches=0.03*max(range(pred.slope.t[sign.slope.pos.t],finite=T))/max(max.b,max.t),add=T,bg='blue',fg='blue')
map("worldHires",fill=T,col="grey",add=T)
text(-159,60.7,labels='B',cex=1.5)
symbols(rep(-176.7,4),seq(55.2,by=0.5,length=4),circles=seq(max(max.b,max.t),max(max.b,max.t)/5,length=4),add=T,inches=0.04,bg='black')
#Add bubble legend
text(rep(-175,6),seq(55.2,by=0.5,length=4),format(round(seq(max(max.b,max.t),max(max.b,max.t)/5,length=4),1),digits=5,trim=T))
text(-171.2,55.2,"ln([n/h]+1)")
#Plot remaining model terms
plot(gam.4,select=4,shade=T,scale=0,rug=F,ylab='')
text(50,2.15,labels='C',cex=1.5)
mtext('CPUE anomalies',2,line=2.5)
mtext('Bottom depth (m)',1,line=2.5)
plot(gam.4,select=5,shade=T,scale=0,rug=F,ylab='')
text(6.5,0.175,labels='D',cex=1.5)
mtext('Sediment size (phi)',1,line=2.5)


#Other possibilities to deal with variance stabilization: GAMMA distribution 
subdata <- na.omit(atf.350)
subdata$bt<-(subdata$bt-mean(subdata$bt))/sd(subdata$bt)
subdata$bt<-subdata$bt+1.01*abs(min(subdata$bt))
subdata$avg.wt<-(subdata$avg.wt-mean(subdata$avg.wt))/sd(subdata$avg.wt)
subdata$avg.wt<-subdata$avg.wt+1.01*abs(min(subdata$avg.wt))

gam5<-gam(log(I(cpuelt+1))~avg.wt+bt+s(lon,lat)+s(depth,k=5)+s(phi,k=5),data=subdata,family=Gamma(link=log))

summary(gam5)
#R-sq.(adj) =  0.489   Deviance explained =   43%
#GCV score = 0.22269  Scale est. = 0.22027   n = 3272
gam.check(gam5)

#Plot results
quartz()
par(mfrow=c(2,2),mai=c(0.35,0.45,0.15,0.05))
vis.gam(gam5,view=c('lon','lat'),plot.type="contour",color="topo",too.far=.05,main='',ylab='')
text(-175,55.5,labels='Position',cex=1.5)
map("worldHires",fill=T,col="grey",add=T)
#contour(unique(bathy.dat$lon),sort(unique(bathy.dat$lat)),bathy.mat,levels=-seq(20,300,by=20),labcex=0.4,col='grey',add=T)
plot(gam5,select=2,shade=T,scale=0,rug=F,res=F,ylab='')
text(125,-0.7,labels='Depth (m)',cex=1.5)
plot(gam5,select=3,shade=T,scale=0,rug=F,res=F,ylab='')
text(3.3,-0.7,labels='-log_2(Sediment size)',cex=1.5)


#AVAS transformation
library(acepack)
subdata <- na.omit(atf.350)
subdata$bt<-(subdata$bt-mean(subdata$bt))/sd(subdata$bt)
subdata$bt<-subdata$bt+1.01*abs(min(subdata$bt))
subdata$avg.wt<-(subdata$avg.wt-mean(subdata$avg.wt))/sd(subdata$avg.wt)
subdata$avg.wt<-subdata$avg.wt+1.01*abs(min(subdata$avg.wt))
attach(subdata)
atf.avas<-avas(data.frame(lat,lon,bt,depth,phi,avg.wt),cpuelt)
detach(subdata)
plot(atf.avas$y,atf.avas$ty)
gam6<-gam(atf.avas$ty~avg.wt+bt+s(lon,lat)+s(depth,k=5)+s(phi,k=5),data=subdata)
gam.check(gam6)
summary(gam6)
#R-sq.(adj) =  0.536   Deviance explained = 54.1%
#GCV score = 0.46922  Scale est. = 0.46389   n = 3272

#Plot results
quartz()
par(mfrow=c(2,2),mai=c(0.35,0.45,0.15,0.05))
vis.gam(gam6,view=c('lon','lat'),plot.type="contour",color="topo",too.far=.05,main='',ylab='')
text(-175,55.5,labels='Position',cex=1.5)
map("worldHires",fill=T,col="grey",add=T)
#contour(unique(bathy.dat$lon),sort(unique(bathy.dat$lat)),bathy.mat,levels=-seq(20,300,by=20),labcex=0.4,col='grey',add=T)
plot(gam6,select=2,shade=T,scale=0,rug=F,res=F,ylab='')
text(125,-1.4,labels='Depth (m)',cex=1.5)
plot(gam6,select=3,shade=T,scale=0,rug=F,res=F,ylab='')
text(3.3,-1,labels='-log_2(Sediment size)',cex=1.5)

#CHAPTER 13: dealing with overdispersion and autocorrelation
#Overdispersion: Case study 1, Pollock eggs Pag 104
source('/Users/lciannel/Documents/MyDocuments/GAM class/Flodevigen2/data/eggdata.R')
dim(eggdata)
#330,4

#Histogram showing the zero-inflation problem
par(mfrow=c(1,2))
hist(log(eggdata$catch+1), main='Egg density with 0s',density=50,col='black',xlab='LN(density+1)')
hist(log(eggdata$catch+1)[eggdata$catch>0], main='Egg density without 0s',density=50,col='black',xlab='LN(density+1)')

#Remove 0 catches from the data set and fit log-normal model
subdata<-eggdata[eggdata$catch!=0,]
dim(subdata)
#256,4: note there were 74 zero catches, about 22% of original data

#GAM on positive data (Pag 106)
egg1<-gam(log(catch+1)~s(lon,lat)+s(log(bottom)),data=subdata)
summary(egg1)
#R-sq.(adj) =  0.704   Deviance explained = 73.2%
#GCV score = 2.6063   Scale est. = 2.3549    n = 256
gam.check(egg1)

#Plot results:image
par(mfrow=c(2,1),omi=c(0.2,1.5,0.2,1.5),mai=c(0.35,0.1,0.35,0.2))
vis.gam(egg1,view=c('lon','lat'),plot.type="contour",color="topo",too.far=0.05, main="Egg density")
map("worldHires",fill=T,col="grey",add=T)
symbols(subdata$lon,subdata$lat,circle=log(subdata$catch),inches=0.07,add=T,bg='white')
plot(egg1, se=T, select=2, residuals=T,pch=1)
text(6.7,-2,'LN(depth)')

#Plot using symbols only
par(mfrow=c(2,1),omi=c(0.2,1.5,0.2,1.5),mai=c(0.35,0.1,0.35,0.2))
plot(1,1, ylim=c(53,60),xlim=c(-165,-150), xlab="", ylab="",main="Observed egg catches")
map("worldHires",fill=T,col="grey",add=T)
symbols(subdata$lon,subdata$lat,circle=log(subdata$catch),inches=0.07,add=T,bg='green')
plot(1,1, ylim=c(53,60),xlim=c(-165,-150), xlab="", ylab="",main="Predicted egg catches")
map("worldHires",fill=T,col="grey",add=T)
symbols(subdata$lon,subdata$lat,circle=ifelse(egg1$fitted<=0,0,egg1$fitted),inches=0.07,add=T,bg='green')

#Presence/Absence on Binomial distribution (Pag 107)
eggdata$pre<-1*(eggdata$catch>0)#vector of presence/absence
egg1.p<-gam(pre~s(lon,lat,k=20)+s(log(bottom),k=5),data=eggdata,family=binomial)
summary(egg1.p)
#R-sq.(adj) =   0.57   Deviance explained = 58.1%
#UBRE score = -0.47472  Scale est. = 1         n = 330

#Plot results:image
par(mfrow=c(2,1),omi=c(0.2,1.5,0.2,1.5),mai=c(0.35,0.1,0.35,0.2))
vis.gam(egg1.p,view=c('lon','lat'),plot.type="contour",color="topo",too.far=0.05,type='response',main='Probability of catching pollock eggs')
map("worldHires",fill=T,col="grey",add=T)
symbols(eggdata$lon,eggdata$lat,circle=log(eggdata$catch),inches=0.07,add=T,bg='white')
points(eggdata$lon[eggdata$catch==0],eggdata$lat[eggdata$catch==0],pch='+',col='white')
plot(egg1.p, se=T, select=2, residuals=T,pch=1)
text(6.7,-2,'LN(depth)')

#Predict egg cpue based on the results of the previous two models
pred<-egg1.p$fitted*predict(egg1,newdata=eggdata)#vector of predictions

#Plot observations and predictions
par(mfrow=c(2,1),omi=c(0.2,1.5,0.2,1.5),mai=c(0.35,0.1,0.35,0.2))
plot(1,1, ylim=c(53,60),xlim=c(-165,-150), xlab="", ylab="",main="Observed distribution")
map("worldHires",fill=T,col="green4",add=T)
symbols(eggdata$lon[eggdata$catch>0],eggdata$lat[eggdata$catch>0],circle=log(eggdata$catch+1)[eggdata$catch>0],inches=0.07,add=T,bg='grey')
points(eggdata$lon[eggdata$catch==0],eggdata$lat[eggdata$catch==0],pch='+',col='black')

plot(1,1, ylim=c(53,60),xlim=c(-165,-150), xlab="", ylab="",main="Predicted from models")
map("worldHires",fill=T,col="green4",add=T)
symbols(eggdata$lon,eggdata$lat,circle=ifelse(pred<0,0,pred),inches=0.07,add=T,bg='grey')

#EXAMPLE FOR OVERDISPERSED POISSON, 
#Case study 1: Pollock eggs with quasipoisson distribution family 
egg3<-gam(log(catch+0.1)~s(lon,lat)+s(log(bottom)),data=eggdata,family=quasipoisson(link=log))
summary(egg3)
gam.check(egg3)#Residuals do not look good 

#case study 2: Tvedestrand cod eggs (data not provioded) 
egg<-read.table(file='/Users/lciannel/Documents/MyDocuments/GAM class/Flodevigen2/data/tved_egg.txt',sep='',header=T)

# GAM USING ALL DATA (Pag 110)
#define 4 0-1 variables for 4 combinations of year and depth sampled
#-1 removes common intercept
#offset adjusts for meter hauled without actually estimating any parameters
egg$level1 <- 1*(egg$depthmax<=15 & egg$year==2006)
egg$level2 <- 2*(egg$depthmax>15 & egg$year==2006)
egg$level3 <- 3*(egg$depthmax<=15 & egg$year==2007)
egg$level4 <- 4*(egg$depthmax>15 & egg$year==2007)
egg$level<-egg$level1+egg$level2+egg$level3+egg$level4
egg$outlier <- 1*(egg$allegg>30)#this adjusts for three outlier observations

#meter hauled
egg$hauled <- egg$depthmax-egg$depthmin

#binomial response
egg$eggbin <- 1*(egg$allegg>0)
#hist of alleggs
hist(log(egg$allegg+1))
#number of zero catches
sum(1*(egg$allegg==0))/nrow(egg)

#poisson distribution, scale is left open (Pag 111)
gam.poisson <- gam(allegg~outlier+factor(level)+offset(log(hauled))+s(dist,by=factor(level))-1,data=egg,family=poisson,scale=-1,gamma=1.4)#gamma puts extra penalty on roughness, see Wood book 
summary(gam.poisson)
#R-sq.(adj) =  0.676   Deviance explained = 49.9%
#GCV score = 2.6527  Scale est. = 2.5484    n = 583
gam.check(gam.poisson)
#Alternative Poisoon formulation
gam.poisson_1 <- gam(allegg~outlier+offset(log(hauled))+s(dist,by=level1)+s(dist,by=level2)+s(dist,by=level3)+s(dist,by=level4)-1,data=egg,family=poisson,scale=-1,gamma=1.4) 
summary(gam.poisson_1)

#binomial response
gam.binom <- gam(eggbin~+s(dist,by=level1)+s(dist,by=level2)+s(dist,by=level3)+s(dist,by=level4)-1,data=egg,family=binomial,gamma=1.4)
summary(gam.binom)
R-sq.(adj) =   0.17   Deviance explained = 15.3%
UBRE score = 0.15801  Scale est. = 1         n = 583

plot(gam.poisson,pages=1,shade=T)
#Compare results of binomial model
quartz()
plot(gam.binom,pages=1,shade=T)

#Nicer plots
par(mfrow = c(2,2))
#outer margins
par(omi= c(0.5,0.5,0.1,0.1))
par(mai=c(0.5,0.5,0.2,0.2))

plot(gam.poisson,select=1,shade=T,pch=1,xaxt="n",yaxt="n",xaxs="i",yaxs="i",xlab="",ylab="")
axis(2,at=c(-2,-1,0,1))
axis(1,at=c(0,2,4,6,8,10))
abline(h=0,lty=2)
#rug(egg$station)
text(6,1.1,"2006 - shallow",cex=1.2)
mtext("Egg density anomalies",side=2,line=2.5,adj=-2,cex=1.2)

plot(gam.poisson,select=2,shade=T,pch=1,xaxt="n",yaxt="n",xaxs="i",yaxs="i",xlab="",ylab="")
axis(2,at=c(-2,-1,0,1))
axis(1,at=c(0,2,4,6,8,10))
abline(h=0,lty=2)
text(6,1.1,"2006 - deep",cex=1.2)

plot(gam.poisson,select=3,shade=T,pch=1,xaxt="n",yaxt="n",xaxs="i",yaxs="i",xlab="",ylab="")
axis(2,at=c(-2,-1,0,1))
axis(1,at=c(0,2,4,6,8,10))
abline(h=0,lty=2)
text(6,1.1,"2007 - shallow",cex=1.2)

plot(gam.poisson,select=4,shade=T,pch=1,xaxt="n",yaxt="n",xaxs="i",yaxs="i",xlab="",ylab="")
axis(2,at=c(-2,-1,0,1))
axis(1,at=c(0,2,4,6,8,10))
abline(h=0,lty=2)
text(6,1.1,"2007 - deep",cex=1.2)
mtext("Distance from innermost extention of fjord, km",side=1,line=2.5,adj=1.8,cex=1.2)


#SPATIAL AUTOCORRELATION: Variograms (add geoR)
#Convert coordinates from Lat & Lon to UTM (km) Pag 113
source('/Users/lciannel/Documents/MyDocuments/GAM class/Flodevigen2/data/eggdata.R')
pred<-egg1.p$fitted*predict(egg1,newdata=eggdata)#vector of predictions

subdataLL<-eggdata[,c(3,2)]
names(subdataLL)<-c('X','Y')
attr(subdataLL,'projection')<-'LL'
subdataUTM<-convUL(subdataLL)
subdataUTM$resd<-log(eggdata$catch+1)-pred
subdataUTM$eggs<-log(eggdata$catch+1)

subset.geor.egg<-as.geodata(subdataUTM, coords.col=c(1,2),data.col=4)
subset.geor.res<-as.geodata(subdataUTM, coords.col=c(1,2),data.col=3)
vario.egg<-variog(subset.geor.egg,uvec=seq(20,500,by=25),pairs.min=10)
vario.res<-variog(subset.geor.res,uvec=seq(20,500,by=25),pairs.min=10)
plot(vario.egg,main='Variogram',xlab='Distance (km)',ylab='Semivariance',type='b',scaled=T)
lines(vario.res,lty=2,scaled=T)
legend(350,0.5,c('egg density','residuals'),lty=c(1,2))

#ATF data: annual correlation in the residuals
res<-residuals(gam1)
pacf(tapply(res,subdata$year,mean))

#ATF data: variograms by year
subdataLL<-atf.350[,c(5,4)]
names(subdataLL)<-c('X','Y')
attr(subdataLL,'projection')<-'LL'
subdataUTM<-convUL(subdataLL)
subdataUTM$resd<-res
subdataUTM$atf<-log(subdata$cpuelt+1)

years<-sort(unique(atf.350$year))
tmp1<-1:ceiling(length(years)/9)
for(j in 1:length(tmp1)){
quartz()
par(mfcol=c(3,3),mai=c(0.35,0.3,0.15,0.05))
for(i in (9*tmp1[j]-8):min(length(years),(9*tmp1[j]))){
subset.geor.dat<-as.geodata(subdataUTM[subdata$year==years[i],], coords.col=c(1,2),data.col=4)
vario.atf<-variog(subset.geor.dat,uvec=seq(20,500,by=50),pairs.min=50,estimator.type="classical")
plot(vario.atf,type='l',ylab='standardized semivariance',cex.lab=1.1,xlab='distance (km)',main=paste(years[i]),ylim=c(0,1.5),xlim=c(0,500),scaled=T)
subset.geor.dat<-as.geodata(subdataUTM[subdata$year==years[i],], coords.col=c(1,2),data.col=3)
vario.atf<-variog(subset.geor.dat,uvec=seq(20,500,by=50),pairs.min=50,estimator.type="classical")
lines(vario.atf,lty=2,scaled=T)
legend(250,0.3,c('cpue','residuals'),lty=c(1,2))}}

#Remedial measure: Mixed effect GAM (GAMM) on pollock egg data - Pag 114
#Correlation structure on the 1986 pollock egg data
subdata<-eggdata[eggdata$catch!=0,]
egg1.corr<-gamm(log(catch+1)~s(lon,lat)+s(log(bottom)),correlation=corGaus(form=~lon+lat),data=subdata)
summary(egg1.corr$gam)
#R-sq.(adj) =  0.703  Scale est. = 2.3431    n = 256
gam.check(egg1.corr$gam)

#Plot results:image
par(mfrow=c(2,1),omi=c(0.2,1.5,0.2,1.5),mai=c(0.35,0.1,0.35,0.2))
vis.gam(egg1.corr$gam,view=c('lon','lat'),plot.type="contour",color="topo",too.far=0.05, main="Egg density")
map("worldHires",fill=T,col="grey",add=T)
symbols(subdata$lon,subdata$lat,circle=log(subdata$catch),inches=0.07,add=T,bg='white')
plot(egg1.corr$gam, se=T, select=2, residuals=T,pch=1)
text(6.7,-2,'LN(depth)')


#ATF: Autocorrelated error by year (example not in manual)
subdata <- na.omit(atf.350)
subdata$bt<-(subdata$bt-mean(subdata$bt))/sd(subdata$bt)
subdata$bt<-subdata$bt+1.01*abs(min(subdata$bt))
subdata$avg.wt<-(subdata$avg.wt-mean(subdata$avg.wt))/sd(subdata$avg.wt)
subdata$avg.wt<-subdata$avg.wt+1.01*abs(min(subdata$avg.wt))

#Correlation structure over space by year (example not in manual)
gamm1<- gamm(log(cpuelt+1)~avg.wt+bt+s(lon,lat)+s(depth,k=5)+s(phi,k=5),data=subdata, correlation=corGaus(form=~lon+lat|year), niterPQL=200, method="REML")
summary(gamm1$gam)
#R-sq.(adj) =  0.533  Scale est. = 0.61392   n = 3272

#Correlation structure over time by year
gamm1.1<- gamm(log(cpuelt+1)~avg.wt+bt+s(lon,lat)+s(depth,k=5)+s(phi,k=5),data=subdata, correlation=corAR1(form=~1|year), niterPQL=200, method="REML")
summary(gamm1.1$gam)
#R-sq.(adj) =  0.532  Scale est. = 0.62009   n = 3272
AIC(summary(gamm1.1$lme)) 
#7496.907

#plot atf gamm1
quartz()
par(mfrow=c(2,2),mai=c(0.35,0.45,0.15,0.05))
vis.gam(gamm1$gam,view=c('lon','lat'),plot.type="contour",color="topo",too.far=.05,main='',ylab='')
text(-175,55.5,labels='Position',cex=1.5)
map("worldHires",fill=T,col="grey",add=T)
plot(gamm1$gam,select=2,shade=T,scale=0,rug=F,res=F,ylab='')
text(125,-1.6,labels='Depth (m)',cex=1.5)
plot(gamm1$gam,select=3,shade=T,scale=0,rug=F,res=F,ylab='')
text(3.3,-1,labels='-log_2(Sediment size)',cex=1.5)


#Wild bootstrap on the ATF data (Llope et al 2009) Pag 115
atf.350<-read.table('/Users/lciannel/Documents/MyDocuments/GAM class/Flodevigen2/data/atf350.txt',sep='',header=T)
subdata <- na.omit(atf.350)
subdata$bt<-(subdata$bt-mean(subdata$bt))/sd(subdata$bt)
subdata$bt<-subdata$bt+1.01*abs(min(subdata$bt))
subdata$avg.wt<-(subdata$avg.wt-mean(subdata$avg.wt))/sd(subdata$avg.wt)
subdata$avg.wt<-subdata$avg.wt+1.01*abs(min(subdata$avg.wt))
#Note we constrain df (k=5) to reduce excessive wiggliness
gam1 <- gam(log(cpuelt+1)~avg.wt+bt+s(lon,lat)+s(depth,k=5)+s(phi,k=5),data=subdata)
summary(gam1)
#R-sq.(adj) =  0.535   Deviance explained =   54%
#GCV score = 0.62159  Scale est. = 0.61454   n = 3272
AIC(gam1) 
[1] 7731.362

atf.res<-gam1$res;atf.fitted<-egg1$fitted
alfa<-sqrt(summary(gam1)$scale/var(atf.res))
atf.res.scaled<-atf.res*alfa

#P-values and CI
years<-unique(subdata$year)
ps.boot<-matrix(3000,ncol=3,nrow=1000)*NA
pp.boot<-matrix(2000,ncol=2,nrow=1000)*NA
cs.pos<-matrix(nrow(subdata)*1000,ncol=1000,nrow=nrow(subdata))*NA
cs.depth<-cs.pos
cs.phi<-cs.pos
subdata$res.scaled<-NA
#(Takes long time to run ~ 1hr)
for(i in 1:1000){
	for(j in 1:length(years)){
	subdata$res.scaled[subdata$year==years[j]]<-atf.res.scaled[subdata$year==years[j]]*sample(c(-1,1),1)
	subdata$newy[subdata$year==years[j]]<-log(subdata$cpuelt+1)[subdata$year==years[j]]+atf.res.scaled[subdata$year==years[j]]*sample(c(-1,1),1)}
boot.gam<-gam(res.scaled~avg.wt+bt+s(lon,lat)+s(depth,k=5)+s(phi,k=5),data=subdata)
boot.gam.data<-gam(newy~avg.wt+bt+s(lon,lat)+s(depth,k=5)+s(phi,k=5),data=subdata)
cs.pos[,i]<-predict(boot.gam.data,type='terms')[,3]
cs.depth[,i]<-predict(boot.gam.data,type='terms')[,4]
cs.phi[,i]<-predict(boot.gam.data,type='terms')[,5]
ps.boot[i,]<-summary(boot.gam)$s.table[,3]
pp.boot[i,]<-summary(boot.gam)$p.table[2:3,3]
}

p.vals.pos<- sum(1*(ps.boot[,1]>=summary(gam1)$s.table[1,3]))/1000
#0
p.vals.depth<- sum(1*(ps.boot[,2]>=summary(gam1)$s.table[2,3]))/1000
#0
p.vals.phi<- sum(1*(ps.boot[,3]>=summary(gam1)$s.table[3,3]))/1000
#0.001
p.vals.avg.wt<- sum(1*(pp.boot[,1]>=summary(gam1)$p.table[2,3]))/1000
#0
p.vals.bt<- sum(1*(pp.boot[,2]>=summary(gam1)$p.table[3,3]))/1000
#0

#Plot CI for each smooth term Pag 117
mean.phi<-apply(cs.phi,1,mean)
low.phi<-apply(cs.phi,1,function(x)quantile(x,0.025))
up.phi<-apply(cs.phi,1,function(x)quantile(x,0.975))
mean.depth<-apply(cs.depth,1,mean)
low.depth<-apply(cs.depth,1,function(x)quantile(x,0.025))
up.depth<-apply(cs.depth,1,function(x)quantile(x,0.975))

par(mfrow=c(1,2))
plot(sort(subdata$phi),mean.phi[order(subdata$phi)],type='l',ylim=c(range(c(mean.phi,up.phi,low.phi))),xlab="Phi",ylab='Anomalies on ATF catches')
lines(sort(subdata$phi),up.phi[order(subdata$phi)],lty=2)
lines(sort(subdata$phi),low.phi[order(subdata$phi)],lty=2)
rug(subdata$phi)
plot(sort(subdata$depth),mean.depth[order(subdata$depth)],type='l',ylim=c(range(c(mean.depth,up.depth,low.depth))),xlab="Depth",ylab='Anomalies on ATF catches')
lines(sort(subdata$depth),up.depth[order(subdata$depth)],lty=2)
lines(sort(subdata$depth),low.depth[order(subdata$depth)],lty=2)
rug(subdata$depth)
