setwd("C:/Users/Aaron/Documents/papers and conferences/rt habit/data analysis/")

library(brms)

dat <- read.table("CNCpdistdata.txt")

dat$Block <- factor(dat$Block)
#dat$B2 <- 1 * (dat$Block == 2)
#dat$B3 <- 1 * (dat$Block == 3)
dat$Cond <- factor(dat$Cond)
dat$TB <- factor(dat$TB)

tdata <- subset(dat,Cond == 0)

mod.full <- brm(PDist ~ Block + (1|Subj) + (1|TB), data = dat, family = 'lognormal', warmup = 1000, iter = 6000, cores=6, prior = set_prior('normal(0,1)', class = 'b'), sample_prior = TRUE)
#mod.full.nBlock <- brm(PDist ~ 1 + (1|Subj) + (1|TB), data = dat, family = 'lognormal', warmup = 1000, iter = 6000, cores=6, prior = set_prior('normal(0,1)', class = 'b'), sample_prior = TRUE)
#mod.fullB <- brm(PDist ~ B2 + B3 + (1|Subj) + (1|TB), data = dat, family = 'lognormal', warmup = 1000, iter = 6000, cores=6, prior = set_prior('normal(0,1)', class = 'b'), sample_prior = TRUE)
#mod.fullB.nB2 <- brm(PDist ~ B3 + (1|Subj) + (1|TB), data = dat, family = 'lognormal', warmup = 1000, iter = 6000, cores=6, prior = set_prior('normal(0,1)', class = 'b'), sample_prior = TRUE)
#mod.fullB.nB3 <- brm(PDist ~ B2 + (1|Subj) + (1|TB), data = dat, family = 'lognormal', warmup = 1000, iter = 6000, cores=6, prior = set_prior('normal(0,1)', class = 'b'), sample_prior = TRUE)

mod.tr <- brm(PDist ~ Block + (1|Subj) + (1|TB), data = tdata, family = 'lognormal', warmup = 1000, iter = 6000, cores=6, prior = set_prior('normal(0,1)', class = 'b'), sample_prior = TRUE)
mod.trnull <- brm(PDist ~ 1 + (1|Subj) + (1|TB), data = tdata, family = 'lognormal', warmup = 1000, iter = 6000, cores=6, prior = set_prior('normal(0,1)', class = 'b'), sample_prior = TRUE)


sink("R_pdistcompareCNC.out")

#if (FALSE) {

cat("-------------------  Full Model  -------------------")
cat("\n\n")



print(summary(mod.full))


#modcmp <- loo(mod.full,mod.full.nBlock,cores = 6)

cat("\n\n")
cat("~~~")
cat("\n\n")

cat("Effect of Block2:\n\n")

h1 <- hypothesis(mod.full,'Block2 = 0')
print(h1)

cat("\n\n--\n\n")

cat("Effect of Block3:\n\n")

h1 <- hypothesis(mod.full,'Block3 = 0')
print(h1)

cat("Block2 v Block3:\n\n")

h1 <- hypothesis(mod.full,'Block2 = Block3')
print(h1)




#print(marginal_effects(mod.full.nI)$Group)
#print(marginal_effects(mod.full)$Group)

cat("\n\n~~~\n\n")

#}

cat("\n\n")
cat("-------------------  Trace-Only Model  -------------------")
cat("\n\n")

print(summary(mod.tr))

cat("\n\n")
cat("~~~")
cat("\n\n")

cat("Effect of Block:\n\n")

h1 <- hypothesis(mod.tr,'(Block+Intercept) = Intercept')
print(h1)

cat("\n\n---\n\n")

h1 <- hypothesis(mod.tr,'(Block+Intercept) < Intercept')
print(h1)



cat("\n\n")
cat("-------------------")
cat("\n\n")


print(citation('brms'))

cat("\n\n")

print(citation('rstan'))



sink()
