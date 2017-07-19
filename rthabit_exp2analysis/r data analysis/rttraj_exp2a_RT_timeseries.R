#This code performs a general linear model on time series of RTs during the cued block in Experiment 2A.

library("nlme")

sink("R_exp2a_rt_timeseries.out")

Data <- read.table("rtdata.txt")

cat("********************Latency time series, Cued blocks ********************\n")

DataT <- subset(Data,Data$Condition == 0)

model.interact <- gls(Lat ~ Group*Trial,data=DataT,correlation=corARMA(form=~1|Subject,p=1,q=1),na.action = na.exclude)
print(summary(model.interact))

cat("\n\n\n")




#the code below does a model comparison to find the most appropriate ARMA form for use in the GLM above.
#it should only be active if needed, because it takes some time to run.

if (FALSE)
{

cat("********************Latency time series, ARMA fits ********************\n")

cat("\n\n")

modaic <- c(rep(0,36))
modbic <- c(rep(0,36))
for (n in 1:24)
{
	tmpdat <- subset(Data,Data$Subject == n)

	vec <- tmpdat$Lat
	for (a in 0:5)
	{
		for (b in 0:5)
		{
			modfit <- arima(vec,order=c(a,0,b),include.mean=TRUE,method="ML")
			modaic[(a*6+b+1)] <- modaic[(a*6+b+1)] + modfit$aic
			modbic[(a*6+b+1)] <- modbic[(a*6+b+1)] + (modfit$aic-2*(a+b)+(a+b)*log(128))
		}
	}

}
cat("AIC:\n")
for (a in 0:5)
{
	print(sprintf("%.3f  %.3f  %.3f  %.3f  %.3f  %.3f",modaic[(a*6+1)],modaic[(a*6+2)],modaic[(a*6+3)],modaic[(a*6+4)],modaic[(a*6+5)],modaic[(a*6+6)]))
}
minAicI <- which.min(modaic)
print(sprintf("    ARMA(%d,%d)",floor(minAicI/6),minAicI%%6-1))
cat("\nBIC:\n")
for (a in 0:5)
{
	print(sprintf("%.3f  %.3f  %.3f  %.3f  %.3f  %.3f",modbic[(a*6+1)],modbic[(a*6+2)],modbic[(a*6+3)],modbic[(a*6+4)],modbic[(a*6+5)],modbic[(a*6+6)]))
}
minBicI <- which.min(modbic)
print(sprintf("    ARMA(%d,%d)",floor(minBicI/6),minBicI%%6-1))


}



sink()