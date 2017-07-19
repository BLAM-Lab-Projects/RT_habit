setwd("C:/Users/Aaron/Documents/papers and conferences/rt habit/data analysis")

library("lme4")
library("multcomp")
library("lsmeans")

sink("R_contextCNC.out")

Data <- read.table("rtcnc.txt")
Data$Block <- factor(Data$Block)
Data$Condition <- factor(Data$Condition)
Data$Subject <- factor(Data$Subject)
Data$TB <- factor(Data$TB)

cat("********************Latency, full model ********************\n")

#lat.model <- lmer(Lat ~ Block + Condition + Block:Condition + (1|TB) + (1|Subject),data = Data,REML=FALSE)
#lat.nInt <- lmer(Lat ~ Block + Condition + (1|TB) + (1|Subject),data = Data,REML=FALSE)
#lat.nBlock <- lmer(Lat ~ Condition + Block:Condition + (1|TB) + (1|Subject),data = Data,REML=FALSE)
#lat.nBlockInt <- lmer(Lat ~ Condition + (1|TB) + (1|Subject),data = Data,REML=FALSE)
#lat.nCond <- lmer(Lat ~ Block + Block:Condition + (1|TB) + (1|Subject),data = Data,REML=FALSE)
#lat.nCondInt <- lmer(Lat ~ Block + (1|TB) + (1|Subject),data = Data,REML=FALSE)


lat.model <- lmer(Lat ~ Block + (1|TB) + (1|Subject),data = Data,REML=FALSE)
lat.nBlock <- lmer(Lat ~ 1 + (1|TB) + (1|Subject),data = Data,REML=FALSE)

if (FALSE) {

print(summary(lat.model))

cat("\n\n>>>Interaction ANOVA: \n\n")
interactanova <- anova(lat.nInt,lat.model)
print(interactanova)

if (interactanova$Pr[2] < 0.05) {

cat("\n----------\n")

cat("\n>>>Block effect ANOVA: \n\n")
nBlockanova <- anova(lat.nBlock,lat.model)
print(nBlockanova)

cat("\n\n>>>Condition effect ANOVA: \n\n")
nCondanova <- anova(lat.nCond,lat.model)
print(nCondanova)

} else {

cat("\n----------\n")

cat("\n>>>Group effect ANOVA (no interaction): \n\n")
nBlockanova <- anova(lat.nBlockInt,lat.nInt)
print(nBlockanova)

cat("\n\n>>>Condition effect ANOVA (no interaction): \n\n")
nCondanova <- anova(lat.nCondInt,lat.nInt)
print(nCondanova)

}

}

cat("\n>>>Block effect ANOVA: \n\n")
nBlockanova <- anova(lat.nBlock,lat.model)
print(nBlockanova)

if (nBlockanova$Pr[2] < 0.05) {
  
  K <- rbind("NT-T1" = c(-1, 1, 0),
             "T2-T1" = c(-1, 0, 1),
             "T2-NT" = c(0, -1, 1))
               
  blkcmp <- glht(lat.model,linfct = mcp(Block = K))
  
  print(summary(blkcmp))
  
  
  #blkcmp <- lsmeans(lat.model, revpairwise ~ Block, adjust="Tukey")
  #
  #print(summary(blkcmp))
  
  
  
}


cat("\n\n\n")



if (FALSE) {

cat("********************Latency comparison, Trace ********************\n")

DataTR <- subset(Data,Condition == "T")

lat.model <- lmer(Lat ~ Block + (1|TB) + (1|Subject),data = DataTR,REML=FALSE)
lat.nBlock <- lmer(Lat ~ 1 + (1|TB) + (1|Subject),data = DataTR,REML=FALSE)

print(summary(lat.model))

cat("\n>>>Condition effect ANOVA: \n\n")
nBlockanova <- anova(lat.nBlock,lat.model)
print(nBlockanova)

cat("\n\n\n")

}




sink()
