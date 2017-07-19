#This code fits mixed-effects models on movement kinematics for Experiment 2A.

library("lme4")
library("multcomp")

sink("R_exp2a_rt.out")

Data <- read.table("rtdata.txt")
Data$Group <- factor(Data$Group)
Data$Condition <- factor(Data$Condition)
Data$TB <- factor(Data$TB)

cat("********************Latency comparison, full model ********************\n")

lat.model <- lmer(Lat ~ Group + Condition + Group:Condition + (1|TB) + (1|Subject),data = Data,REML=FALSE)
lat.nInt <- lmer(Lat ~ Group + Condition + (1|TB) + (1|Subject),data = Data,REML=FALSE)
lat.nGroup <- lmer(Lat ~ Condition + Group:Condition + (1|TB) + (1|Subject),data = Data,REML=FALSE)
lat.nGroupInt <- lmer(Lat ~ Condition + (1|TB) + (1|Subject),data = Data,REML=FALSE)
lat.nCond <- lmer(Lat ~ Group + Group:Condition + (1|TB) + (1|Subject),data = Data,REML=FALSE)
lat.nCondInt <- lmer(Lat ~ Group + (1|TB) + (1|Subject),data = Data,REML=FALSE)

print(summary(lat.model))

cat("\n\n>>>Interaction ANOVA: \n\n")
interactanova <- anova(lat.nInt,lat.model)
print(interactanova)

if (interactanova$Pr[2] < 0.05) {

cat("\n----------\n")

cat("\n>>>Group effect ANOVA: \n\n")
nGroupanova <- anova(lat.nGroup,lat.model)
print(nGroupanova)

cat("\n\n>>>Condition effect ANOVA: \n\n")
nCondanova <- anova(lat.nCond,lat.model)
print(nCondanova)

} else {

cat("\n----------\n")

cat("\n>>>Group effect ANOVA (no interaction): \n\n")
nGroupanova <- anova(lat.nGroupInt,lat.nInt)
print(nGroupanova)

cat("\n\n>>>Condition effect ANOVA (no interaction): \n\n")
nCondanova <- anova(lat.nCondInt,lat.nInt)
print(nCondanova)

}

cat("\n\n\n")

Data$Group_Cond <- interaction(Data$Group,Data$Condition)

lat.model <- lmer(Lat ~ 0 + Group_Cond + (1|Subject), data = Data,REML = FALSE)

K <- t(matrix(c(1, -1, 0, 0,
                0, 0, 1,-1,
                1, 0, -1, 0,
                0, 1, 0,-1,
                1, 0, 0, -1,
                0, 1, -1, 0),4))
rownames(K) <- c("NTF_Tr vs TF_Tr","NTF_NT vs TF_NT","NTF_Tr vs NTF_NT","TF_Tr vs TF_NT", "Blk1", "Blk2")
#shorthand: NTF = UncuedFirst
#            TF = CuedFirst
#            NT = Uncued
#             T = Cued

posthocs <- glht(lat.model,linfct = K)


print(summary(posthocs, test = adjusted('holm')))



cat("********************Latency comparison, UncuedFirst ********************\n")

DataNTF <- subset(Data,Group == 1)

#fixed effects model below reported as rank deficient
lat.model <- lmer(Lat ~ Condition + (1|TB) + (1|Subject),data = DataNTF,REML=FALSE)
lat.nCond <- lmer(Lat ~ 1 + (1|TB) + (1|Subject),data = DataNTF,REML=FALSE)

print(summary(lat.model))

cat("\n>>>Condition effect ANOVA: \n\n")
nCondanova <- anova(lat.nCond,lat.model)
print(nCondanova)

cat("\n\n\n")



cat("********************Latency comparison, CuedFirst ********************\n")

DataTF <- subset(Data,Group == 0)

#fixed effects model below reported as rank deficient
lat.model <- lmer(Lat ~ Condition + (1|TB) + (1|Subject),data = DataTF,REML=FALSE)
lat.nCond <- lmer(Lat ~ 1 + (1|TB) + (1|Subject),data = DataTF,REML=FALSE)

print(summary(lat.model))

cat("\n>>>Condition effect ANOVA: \n\n")
nCondanova <- anova(lat.nCond,lat.model)
print(nCondanova)

cat("\n\n\n")



cat("********************Latency comparison, Uncued blocks ********************\n")

DataNT <- subset(Data,Condition == 1)

lat.model <- lmer(Lat ~ Group + (1|TB) + (1|Subject),data = DataNT,REML=FALSE)
lat.nGroup <- lmer(Lat ~ 1 + (1|TB) + (1|Subject),data = DataNT,REML=FALSE)


print(summary(lat.model))

cat("\n>>>Group effect ANOVA: \n\n")
nGroupanova <- anova(lat.nGroup,lat.model)
print(nGroupanova)

cat("\n\n\n")


cat("********************Latency comparison, Cued blocks ********************\n")

DataT <- subset(Data,Condition == 0)

lat.model <- lmer(Lat ~ Group + (1|TB) + (1|Subject),data = DataT,REML=FALSE)
lat.nGroup <- lmer(Lat ~ 1 + (1|TB) + (1|Subject),data = DataT,REML=FALSE)

print(summary(lat.model))

cat("\n>>>Group effect ANOVA: \n\n")
nGroupanova <- anova(lat.nGroup,lat.model)
print(nGroupanova)

cat("\n\n\n")





sink()
