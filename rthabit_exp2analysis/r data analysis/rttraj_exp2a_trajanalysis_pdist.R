#This code performs generalized linear mixed model on the Procrustes distance analysis
# data from Experiment 2A.

library(brms)

dat <- read.table("pdistdata.txt")

dat$Group <- factor(dat$Group)
dat$Cond <- factor(dat$Cond)
dat$TB <- factor(dat$TB)

ntfdata <- subset(dat,Group == 1)
tfdata <- subset(dat, Group == 0)

ntdata = subset(dat,Cond == 1)
tdata = subset(dat,Cond == 0)


mod.full <- brm(PDist ~ Group + Cond + Group:Cond + (1|Subj) + (1|TB), data = dat, family = 'lognormal', warmup = 1000, iter = 6000, cores=6, prior = set_prior('normal(0,1)', class = 'b'), sample_prior = TRUE)
mod.full.nI <- brm(PDist ~ Group + Cond + (1|Subj) + (1|TB), data = dat, family = 'lognormal', warmup = 1000, iter = 6000, cores=6, prior = set_prior('normal(0,1)', class = 'b'), sample_prior = TRUE)
mod.full.nG <- brm(PDist ~ Cond + Group:Cond + (1|Subj) + (1|TB), data = dat, family = 'lognormal', warmup = 1000, iter = 6000, cores=6, prior = set_prior('normal(0,1)', class = 'b'), sample_prior = TRUE)
mod.full.nC <- brm(PDist ~ Group + Group:Cond + (1|Subj) + (1|TB), data = dat, family = 'lognormal', warmup = 1000, iter = 6000, cores=6, prior = set_prior('normal(0,1)', class = 'b'), sample_prior = TRUE)

mod.ntf <- brm(PDist ~ Cond + (1|Subj) + (1|TB), data = ntfdata, family = 'lognormal', warmup = 1000, iter = 6000, cores=6, prior = set_prior('normal(0,1)', class = 'b'), sample_prior = TRUE)

mod.tf <- brm(PDist ~ Cond + (1|Subj) + (1|TB), data = tfdata, family = 'lognormal', warmup = 1000, iter = 6000, cores=6, prior = set_prior('normal(0,1)', class = 'b'), sample_prior = TRUE)

mod.nt <- brm(PDist ~ Group + (1|Subj) + (1|TB), data = ntdata, family = 'lognormal', warmup = 1000, iter = 6000, cores=6, prior = set_prior('normal(0,1)', class = 'b'), sample_prior = TRUE)

mod.t <- brm(PDist ~ Group + (1|Subj) + (1|TB), data = tdata, family = 'lognormal', warmup = 1000, iter = 6000, cores=6, prior = set_prior('normal(0,1)', class = 'b'), sample_prior = TRUE)



sink("R_exp2a_pdistcompare.out")

cat("-------------------  Full Model  -------------------")
cat("\n\n")



print(summary(mod.full))

cat("\n\n")
cat("~~~")
cat("\n\n")

cat("Effect of Interaction\n\n")

h3 <- hypothesis(mod.full,'Group1:Cond1 = 0')
print(h3)

cat("\n\n--\n\n")

loo1 <- LOO(mod.full,mod.full.nI, cores = 6)
print(loo1)

cat("\n\n--\n\n")

mef <- marginal_effects(mod.full)
print(mef$'Group:Cond')

cat("\n\n")
cat("~~~")
cat("\n\n")

cat("Main effect of Group (UncuedFirst/CuedFirst):\n\n")

h1 <- hypothesis(mod.full,'(Intercept+(Intercept+Cond1))/2 = ((Intercept+Group1) + (Intercept+Group1+Cond1))/2')
print(h1)

cat("\n\n--\n\n")

loo2 <- LOO(mod.full,mod.full.nG, cores = 6)
print(loo2)


cat("\n\n~~~\n\n")

cat("Main effect of Condition (Cued/Uncued)\n\n")

h2 <- hypothesis(mod.full,'(Intercept+(Intercept+Group1))/2 = ((Intercept+Cond1) + (Intercept+Group1+Cond1))/2')
print(h2)

cat("\n\n--\n\n")

loo3 <- LOO(mod.full,mod.full.nC, cores = 6)
print(loo3)



cat("\n\n")
cat("-------------------  UncuedFirst Model  -------------------")
cat("\n\n")

print(summary(mod.ntf))

cat("\n\n")
cat("~~~")
cat("\n\n")

cat("Effect of Condition:\n\n")

h1 <- hypothesis(mod.ntf,'(Cond1+Intercept) = Intercept')
print(h1)

cat("\n\n--\n\n")

cat("Main effect of Condition (Cued/Uncued)\n\n")

print(marginal_effects(mod.ntf)$Cond)


cat("\n\n")
cat("-------------------  CuedFirst Model  -------------------")
cat("\n\n")

print(summary(mod.tf))

cat("\n\n")
cat("~~~")
cat("\n\n")

cat("Effect of Condition:\n\n")

h2 <- hypothesis(mod.tf,'(Cond1+Intercept) = Intercept')
print(h2)

cat("\n\n--\n\n")

cat("Main effect of Condition (Cued/Uncued)\n\n")

print(marginal_effects(mod.tf)$Cond)



cat("\n\n")
cat("-------------------  Uncued Model  -------------------")
cat("\n\n")

print(summary(mod.nt))

cat("\n\n")
cat("~~~")
cat("\n\n")

cat("Effect of Group:\n\n")

h3 <- hypothesis(mod.nt,'(Group1+Intercept) = Intercept')
print(h3)

cat("\n\n--\n\n")

cat("Main effect of Group (UncuedFirst/CuedFirst)\n\n")

print(marginal_effects(mod.nt)$Group)



cat("\n\n")
cat("-------------------  Cued Model  -------------------")
cat("\n\n")

print(summary(mod.t))

cat("\n\n")
cat("~~~")
cat("\n\n")

cat("Effect of Group:\n\n")

h4 <- hypothesis(mod.t,'(Group1+Intercept) = Intercept')
print(h4)

cat("\n\n--\n\n")

cat("Main effect of Group (UncuedFirst/CuedFirst)\n\n")

print(marginal_effects(mod.t)$Group)





cat("\n\n")
cat("-------------------")
cat("\n\n")


print(citation('brms'))

cat("\n\n")

print(citation('rstan'))



sink()
