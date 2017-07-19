setwd("C:/Users/Aaron/Documents/papers and conferences/rt habit/trajectory data analysis")

library("lme4")
library("multcomp")

sink("R_contextScore.out")

Data <- read.table("scoredata.txt")
Data$Group <- factor(Data$Group)
Data$Condition <- factor(Data$Condition)
Data$Subject <- factor(Data$Subject)
Data$Group_Cond <- interaction(Data$Group, Data$Condition)

cat("********************Score comparison, full model ********************\n")

score.model <- lmer(Score ~ Group + Condition + Group:Condition + (1|Subject),data = Data,REML=FALSE)
score.nGroup <- lmer(Score ~ Condition + Group:Condition + (1|Subject),data = Data,REML=FALSE)
score.nCond <- lmer(Score ~ Group + Group:Condition + (1|Subject),data = Data,REML=FALSE)
score.nInt <- lmer(Score ~ Group + Condition + (1|Subject),data = Data,REML=FALSE)
score.nIntnGroup <- lmer(Score ~ Condition + (1|Subject),data = Data,REML=FALSE)
score.nIntnCond <- lmer(Score ~ Group + (1|Subject),data = Data,REML=FALSE)

print(summary(score.model))

cat("\n\n>>>Interaction ANOVA: \n\n")
interactanova <- anova(score.model,score.nInt)
print(interactanova)

if (interactanova$Pr[2] < 0.05) {

cat("\n----------\n")

cat("\n>>>Group effect ANOVA: \n\n")
nGroupanova <- anova(score.nGroup,score.model)
print(nGroupanova)

cat("\n\n>>>Condition effect ANOVA: \n\n")
nCondanova <- anova(score.nCond,score.model)
print(nCondanova)

} else {

cat("\n----------\n")

cat("\n>>>Group effect ANOVA (no interaction): \n\n")
nGroupanova <- anova(score.nIntnGroup,score.nInt)
print(nGroupanova)

cat("\n\n>>>Condition effect ANOVA (no interaction): \n\n")
nCondanova <- anova(score.nIntnCond,score.nInt)
print(nCondanova)

}

cat("\n\n\n")


score.model <- lmer(Score ~ 0 + Group_Cond + (1|Subject), data = Data,REML = FALSE)

cat("\n\n\n>>>Blockwise posthoc paired testing: \n\n")
K <- t(matrix(c(1, 0,-1, 0,
                0, 1, 0,-1,
                1,-1, 0, 0,
                0, 0, 1,-1),4))
rownames(K) <- c("Grp NTF","Grp TF","NTF.NT vs TF.NT","NTF.T vs TF.T")

posthocs <- glht(score.model,linfct = K)

print(summary(posthocs))




sink()
