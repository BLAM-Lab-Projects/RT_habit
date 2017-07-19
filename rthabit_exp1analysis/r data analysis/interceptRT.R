#This code fits mixed-effects models for the interception task.

library("lme4")
library("multcomp")

sink("R_interceptRT.out")


DataOut <- read.table("interceptout.txt",na.strings = "NaN")
DataOut$Subj <- factor(DataOut$Subj)
DataOut$Block <- factor(DataOut$Block)
DataOut$Group <- 0

DataIn <- read.table("interceptin.txt",na.strings = "NaN")
DataIn$Subj <- factor(DataIn$Subj+10)
DataIn$Block <- factor(DataIn$Block)
DataIn$Group <- 1

Data <- rbind(DataOut, DataIn)

DataPre <- subset(Data,Block == 1)
DataPst <- subset(Data,Block == 2)

DataInPre <- subset(DataIn,Block == 1)
DataOutPre <- subset(DataOut,Block == 1)


cat("********************Latency comparison, full model ********************\n")
lat.model <- lmer(Lat ~ Block + Group + Block:Group + (1|Subj),data = Data,REML=FALSE)
lat.nInt <- lmer(Lat ~ Block + Group + (1|Subj),data = Data,REML=FALSE)
lat.nBlock <- lmer(Lat ~ Group + Block:Group + (1|Subj),data = Data,REML=FALSE)
lat.nGroup <- lmer(Lat ~ Block + Block:Group + (1|Subj),data = Data,REML=FALSE)
lat.nIntnBlock <- lmer(Lat ~ Group + (1|Subj),data = Data,REML=FALSE)
lat.nIntnGroup <- lmer(Lat ~ Block + (1|Subj),data = Data,REML=FALSE)

print(summary(lat.model))

cat("\n\n>>>Interaction ANOVA: \n\n")
interactanova <- anova(lat.nInt,lat.model)
print(interactanova)

if (interactanova$Pr[2] < 0.05) {
  
  cat("\n----------\n")
  
  cat("\n>>>Group effect ANOVA: \n\n")
  nGroupanova <- anova(lat.nGroup,lat.model)
  print(nGroupanova)
  
  cat("\n\n>>>Block effect ANOVA: \n\n")
  nBlockanova <- anova(lat.nBlock,lat.model)
  print(nBlockanova)
  
} else {
  
  cat("\n----------\n")
  
  cat("\n>>>Group effect ANOVA (no interaction): \n\n")
  nGroupanova <- anova(lat.nIntnGroup,lat.nInt)
  print(nGroupanova)
  
  cat("\n\n>>>Block effect ANOVA (no interaction): \n\n")
  nBlockanova <- anova(lat.nIntnBlock,lat.nInt)
  print(nBlockanova)
  
}

cat("\n\n\n")




cat("********************Latency comparison, Effect of Group in Pre/Pst ********************\n")

K <- t(matrix(c(0, 0, 1, 0, 0, 1, -1, -1),4,dimnames = list(c('Incpt','Block2','Group','Block2:Group'),c('Pre','Post'))))

posthocs <- glht(lat.model,linfct = K)


print(summary(posthocs, test = adjusted('holm')))


cat("\n\n\n")


cat("********************Peak Velocity comparison, full model ********************\n")
vel.model <- lmer(Vpeak ~ Block + Group + Block:Group + (1|Subj),data = Data,REML=FALSE)
vel.nInt <- lmer(Vpeak ~ Block + Group + (1|Subj),data = Data,REML=FALSE)
vel.nBlock <- lmer(Vpeak ~ Group + Block:Group + (1|Subj),data = Data,REML=FALSE)
vel.nGroup <- lmer(Vpeak ~ Block + Block:Group + (1|Subj),data = Data,REML=FALSE)
vel.nIntnBlock <- lmer(Vpeak ~ Group + (1|Subj),data = Data,REML=FALSE)
vel.nIntnGroup <- lmer(Vpeak ~ Block + (1|Subj),data = Data,REML=FALSE)

print(summary(vel.model))

cat("\n\n>>>Interaction ANOVA: \n\n")
interactanova <- anova(vel.nInt,vel.model)
print(interactanova)

if (interactanova$Pr[2] < 0.05) {
  
  cat("\n----------\n")
  
  cat("\n>>>Group effect ANOVA: \n\n")
  nGroupanova <- anova(vel.nGroup,vel.model)
  print(nGroupanova)
  
  cat("\n\n>>>Block effect ANOVA: \n\n")
  nBlockanova <- anova(vel.nBlock,vel.model)
  print(nBlockanova)
  
} else {
  
  cat("\n----------\n")
  
  cat("\n>>>Group effect ANOVA (no interaction): \n\n")
  nGroupanova <- anova(vel.nIntnGroup,vel.nInt)
  print(nGroupanova)
  
  cat("\n\n>>>Block effect ANOVA (no interaction): \n\n")
  nBlockanova <- anova(vel.nIntnBlock,vel.nInt)
  print(nBlockanova)
  
}

cat("\n\n\n")




cat("********************Peak Velocity comparison, Effect of Group in Pre/Pst ********************\n")

K <- t(matrix(c(0, 0, 1, 0, 0, 1, -1, -1),4,dimnames = list(c('Incpt','Block2','Group','Block2:Group'),c('Pre','Post'))))

posthocs <- glht(vel.model,linfct = K)


print(summary(posthocs, test = adjusted('holm')))


cat("\n\n\n")


cat("********************Latency comparison, Outward ********************\n")

lat.model <- lmer(Lat ~ Block + Vpeak + Err + (1|Subj),data = DataOut,REML=FALSE)
lat.nVpeak <- lmer(Lat ~ Block + Err + (1|Subj),data = DataOut,REML=FALSE)
lat.nErr <- lmer(Lat ~ Block + Vpeak + (1|Subj),data = DataOut,REML=FALSE)
lat.nVpeaknErr <- lmer(Lat ~ Block + (1|Subj),data = DataOut,REML=FALSE)
lat.nBlk <- lmer(Lat ~ Vpeak + Err + (1|Subj),data = DataOut,REML=FALSE)
lat.null <- lmer(Lat ~ 1 + (1|Subj),data = DataOut,REML=FALSE)

print(summary(lat.model))

cat("\n\n>>>Peak Vel ANOVA: \n\n")
velanova <- anova(lat.nVpeak,lat.model)
print(velanova)

cat("\n\n>>>Endpt Err ANOVA: \n\n")
erranova <- anova(lat.nErr,lat.model)
print(erranova)

cat("\n\n>>>Block ANOVA: \n\n")
nullanova <- anova(lat.null,lat.nVpeaknErr)
print(nullanova)



cat("\n\n\n")



cat("********************Peak Vel comparison, Outward ********************\n")

vel.model <- lmer(Vpeak ~ Block + (1|Subj),data = DataOut,REML=FALSE)
vel.null <- lmer(Vpeak ~ 1 + (1|Subj),data = DataOut,REML=FALSE)

print(summary(vel.model))

cat("\n>>>Vel effect ANOVA: \n\n")
nvelanova <- anova(vel.null,vel.model)
print(nvelanova)

cat("\n\n\n")


cat("********************Endpt Err comparison, Outward ********************\n")

err.model <- lmer(Err ~ Block + (1|Subj),data = DataOut,REML=FALSE)
err.null <- lmer(Err ~ 1 + (1|Subj),data = DataOut,REML=FALSE)

print(summary(err.model))

cat("\n>>>Err effect ANOVA: \n\n")
nerranova <- anova(err.null,err.model)
print(nerranova)

cat("\n\n\n")







cat("********************Latency comparison, Inward ********************\n")

lat.model <- lmer(Lat ~ Block + Vpeak + Err + (1|Subj),data = DataIn,REML=FALSE)
lat.nVpeak <- lmer(Lat ~ Block + Err + (1|Subj),data = DataIn,REML=FALSE)
lat.nErr <- lmer(Lat ~ Block + Vpeak + (1|Subj),data = DataIn,REML=FALSE)
lat.nVpeaknErr <- lmer(Lat ~ Block + (1|Subj),data = DataIn,REML=FALSE)
lat.nBlk <- lmer(Lat ~ Vpeak + Err + (1|Subj),data = DataIn,REML=FALSE)
lat.null <- lmer(Lat ~ 1 + (1|Subj),data = DataIn,REML=FALSE)

print(summary(lat.model))

cat("\n\n>>>Peak Vel ANOVA: \n\n")
velanova <- anova(lat.nVpeak,lat.model)
print(velanova)

cat("\n\n>>>Endpt Err ANOVA: \n\n")
erranova <- anova(lat.nErr,lat.model)
print(erranova)

cat("\n\n>>>Block ANOVA: \n\n")
nullanova <- anova(lat.null,lat.nVpeaknErr)
print(nullanova)



cat("\n\n\n")



cat("********************Peak Vel comparison, Inward ********************\n")

vel.model <- lmer(Vpeak ~ Block + (1|Subj),data = DataIn,REML=FALSE)
vel.null <- lmer(Vpeak ~ 1 + (1|Subj),data = DataIn,REML=FALSE)

print(summary(vel.model))

cat("\n>>>Vel effect ANOVA: \n\n")
nvelanova <- anova(vel.null,vel.model)
print(nvelanova)

cat("\n\n\n")


cat("********************Endpt Err comparison, Inward ********************\n")

err.model <- lmer(Err ~ Block + (1|Subj),data = DataIn,REML=FALSE)
err.null <- lmer(Err ~ 1 + (1|Subj),data = DataIn,REML=FALSE)

print(summary(err.model))

cat("\n>>>Err effect ANOVA: \n\n")
nerranova <- anova(err.null,err.model)
print(nerranova)

cat("\n\n\n")




sink()
