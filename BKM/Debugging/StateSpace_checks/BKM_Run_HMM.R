# Load required packages and fix the random seed
rm(list=ls())

setwd("BKM/StateSpace_checks")
library(rjags)
library(coda)
library(lattice)
set.seed(134522)

save_on = FALSE
# MCMC details: ####

ada=100
iter=10000
th=1
cha=2

# Read data ###
source("BKM_Data_HMM.R")
# Set parameters and inital values
source("BKM_StartingVals_HMM.R")
 
# Compile the model: ####
tstart=proc.time()
mod <- jags.model('BKM_Bugs_HMM.R',data,inits,n.chains=cha,n.adapt=ada) #   Total graph size: 94551

temp=proc.time()-tstart
time_HMM_init <- temp #  436.83 
if (save_on) {
  save(mod, time_HMM_init, file = paste("Results/BKM_HMM_model_ada",toString(ada),".RData",sep=""))
}


# Compile the REVERSED model: ####
tstart=proc.time()
mod2 <- jags.model('BKM_Bugs_HMM_reversed.R',data,inits,n.chains=cha,n.adapt=ada) #   Total graph size: 53955
temp=proc.time()-tstart
time_HMM_init2 <- temp # 494 || 84.99 with Up 300 instead of 2000 fot Na_prior <- rep(1/(Up+1), Up+1) || 13.60 with Up 30 

if (save_on) {
  save(mod2, time_HMM_init2, file = paste("Results/BKM_HMM_model_ada",toString(ada),"_reversed.RData",sep=""))
}


# Compile the REVERSED model 2: ####
tstart=proc.time()
mod3 <- jags.model('BKM_Bugs_HMM_reversed2.R',data,inits,n.chains=cha,n.adapt=ada) #   Total graph size: 53955
temp=proc.time()-tstart
time_HMM_init3 <- temp # 461.06  476.88 (no max) 430.55 (no ifelse) || 73.86 with Up 300 instead of 2000 fot Na_prior <- rep(1/(Up+1), Up+1) 

if (save_on) {
  save(mod3, time_HMM_init3, file = paste("Results/BKM_HMM_model_ada",toString(ada),"_reversed2.RData",sep=""))
}


###########################################################
# Run the MCMC: #### 
tstart=proc.time()
output1 <- coda.samples(mod,params,n.iter=iter,thin=th)
temp=proc.time()-tstart
time_HMM_sample <- temp # 
if (save_on) {
  save(output1, time_HMM_sample, file =  paste("Results/BKM_HMM_iter",toString(iter),"_ada",toString(ada),".RData",sep=""))
}

# Run the MCMC for the reversed model: #### 
tstart=proc.time()
output2 <- coda.samples(mod2,params,n.iter=iter,thin=th)
temp=proc.time()-tstart
time_HMM_sample2 <- temp # xxx xxx || 1381.89 with Up 30 
if (save_on) {
  save(output2, time_HMM_sample2, file =  paste("Results/BKM_HMM_iter",toString(iter),"_ada",toString(ada),"_reversed.RData",sep=""))
}


###### PRIOR FOR Na CHANGED 
source("BKM_Data_HMM_unifprior.R")
source("BKM_StartingVals_HMM_unifprior.R")

# Compile the model:
tstart=proc.time()
mod5 <- jags.model('BKM_Bugs_HMM_unifprior.R',data_unifprior,inits_unifprior,n.chains=cha,n.adapt=ada) #   Total graph size: 53955
temp=proc.time()-tstart
time_HMM_init5 <- temp 

tstart=proc.time()
output5 <- coda.samples(mod5,params,n.iter=iter,thin=th)
temp=proc.time()-tstart
time_HMM_sample5 <- temp


mat5 = as.matrix(output5[1])
mat6 = as.matrix(output5[2])
mat5_names <- colnames(mat5) 


par(mfrow=c(3,3), oma = c(0, 0, 1.5, 0))
for (i in c(37:43)){
  plot(mat1[,i], type="l", xlab ="", ylab="", sub=mat1_names[i])
}

par(mfrow=c(3,3), oma = c(0, 0, 1.5, 0))
for (i in c(1:9)){
  plot(mat2[,4*(i-3)+9], type="l", xlab ="", ylab="", sub=mat1_names[4*(i-3)+9])
}

par(mfrow=c(3,3), oma = c(0, 0, 1.5, 0))
for (i in c(37:43)){
  plot(mat5[,i], type="l", xlab ="", ylab="", sub=mat5_names[i])
}

par(mfrow=c(3,3), oma = c(0, 0, 1.5, 0))
for (i in c(1:9)){
  plot(mat6[,4*(i-3)+9], type="l", xlab ="", ylab="", sub=mat5_names[4*(i-3)+9])
}


# Collect the results ####
mat1 = as.matrix(output1[1])
mat2 = as.matrix(output1[2])

mat3 = as.matrix(output2[1])
mat4 = as.matrix(output2[2])

# Retrieve the names ####
mat1_names <- colnames(mat1) 

mat1_names[1] # "G[1,3]"
mat1_names[34*100]      # "G[100,36]"
mat1_names[34*100+1]    # "Na[1]"
mat1_names[34*100+1+35] # "Na[36]"
mat1_names[34*100+1+35+1] # "P[1,3]"
mat1_names[34*100+1+35+34*100] #"P[100,36]"
mat1_names[7036]
(34*100+1+35+1):(34*100+1+35+34*100)


# PLOTS ####
source("BKM_HMM_plots.R")

# Check the transition probabilities ####
Gamma_last = matrix(mat1[1000,1:(34*100)], nrow = 100, ncol = 34, byrow = FALSE)
Gamma_last_10 = diag(Gamma_last[,12])
sum(Gamma_last_10) #1
sum_Gamma_last = colSums(Gamma_last)

###  plots and acfs
par(mfrow=c(1,1))
plot(output1[[1]][,"sigy"])
par(mfrow=c(1,1))
acf(output1[[2]][,"alphar"])
par(mfrow=c(1,1))
acf(output1[[2]][,"betar"])
par(mfrow=c(1,1))
acf(output1[[2]][,"Na[36]"])
par(mfrow=c(1,1))
acf(output1[[2]][,"Na[1]"])

par(mfrow=c(1,1))
acf(output1[[1]][,"Na[10]"])


# Refer to particular variables ####
sd(output1[[1]][,1])
sd(output1[[1]][,"Na[10]"])
sd(output1[[1]][,100])
sd(output1[[1]][,"sigy"])



# Collect results for printing ####
### FULL DA posterior means and std####
# alpha1     0.5540 6.888e-02 
# alphaa     1.5678 6.338e-02 
# alphal    -4.5760 3.534e-02 
# alphar    -1.1723 6.579e-02 
# beta1     -0.1913 5.668e-02 
# betaa     -0.2465 3.786e-02 
# betal     -0.3650 3.981e-02 
# betar     -0.3360 3.254e-02 

# Na[3]    993.9475 26.52
# Na[13]  1789.2550 52.95
# Na[23]  1469.4150 49.46
# Na[33]   975.9720 59.51

### FULL DA SCALED adapt 1000 iter 3000

# Na[3]  104.7057, 5.74023, 
# Na[13] 170.9540, 6.73734, 
# Na[23] 158.9238,  7.29764, 
# Na[33]  94.5547,  5.72801, 
# 
# alpha1   0.5261,  0.06790, 
# alphaa   1.5357,  0.06691,
# alphal  -2.2752,  0.03572, 
# alphar  -1.1330,  0.09853, 
# beta1   -0.2034,  0.05903,
# betaa   -0.2501,  0.03805, 
# betal   -0.3564,  0.04183, 
# betar   -0.3061,  0.07159, 
# sigy   157.1837, 57.75430, 

# DA WITH HMM MEANS STD #####
# sigy #### 
sigy <- round(c(30755.8259, 8700, 
                157.7786,60.7126,
                mean(mat1[501:2000,"sigy"]),sd(mat1[501:2000,"sigy"]),
                mean(mat2[501:2000,"sigy"]),sd(mat2[501:2000,"sigy"]),
                mean(mat3[501:2000,"sigy"]),sd(mat3[501:2000,"sigy"])),4)

# alphas betas  ####


#  DA scaled for ada=100, iter=2000
alphar <- round(c(-1.1723, 0.06579, 
                  -1.1429, 0.1013, 
                mean(mat1[501:2000,"alphar"]),sd(mat1[501:2000,"alphar"]),
                mean(mat2[501:2000,"alphar"]),sd(mat2[501:2000,"alphar"]),
                mean(mat3[501:2000,"alphar"]),sd(mat3[501:2000,"alphar"])),4)
betar <- round(c(-0.3360, 0.03254, 
                 -0.3069, 0.0729,
                  mean(mat1[501:2000,"betar"]),sd(mat1[501:2000,"betar"]),
                  mean(mat2[501:2000,"betar"]),sd(mat2[501:2000,"betar"]),
                  mean(mat3[501:2000,"betar"]),sd(mat3[501:2000,"betar"])),4) 

alphal <- round(c(-4.5760, 0.3534, 
                  -2.2751, 0.0368,
                  mean(mat1[501:2000,"alphal"]),sd(mat1[501:2000,"alphal"]),
                  mean(mat2[501:2000,"alphal"]),sd(mat2[501:2000,"alphal"]),
                  mean(mat3[501:2000,"alphal"]),sd(mat3[501:2000,"alphal"])),4)
betal <- round(c(-0.3650, 0.03981,
                 -0.3589, 0.0435,                 
                 mean(mat1[501:2000,"betal"]),sd(mat1[501:2000,"betal"]),
                 mean(mat2[501:2000,"betal"]),sd(mat2[501:2000,"betal"]),
                 mean(mat3[501:2000,"betal"]),sd(mat3[501:2000,"betal"])),4) 

alpha1 <- round(c(0.5540, 0.06888,
                  0.5262, 0.0689,                  
                  mean(mat1[501:2000,"alpha1"]),sd(mat1[501:2000,"alpha1"]),
                  mean(mat2[501:2000,"alpha1"]),sd(mat2[501:2000,"alpha1"]),
                  mean(mat3[501:2000,"alpha1"]),sd(mat3[501:2000,"alpha1"])),4)
beta1 <- round(c(-0.1913, 0.05668, 
                 -0.2078, 0.0601,
                 mean(mat1[501:2000,"beta1"]),sd(mat1[501:2000,"beta1"]),
                 mean(mat2[501:2000,"beta1"]),sd(mat2[501:2000,"beta1"]),
                 mean(mat3[501:2000,"beta1"]),sd(mat3[501:2000,"beta1"])),4) 
       
alphaa <- round(c(1.5678, 0.06338, 
                  1.5409, 0.0720,                  
                  mean(mat1[501:2000,"alphaa"]),sd(mat1[501:2000,"alphaa"]),
                  mean(mat2[501:2000,"alphaa"]),sd(mat2[501:2000,"alphaa"]),
                  mean(mat3[501:2000,"alphaa"]),sd(mat3[501:2000,"alphaa"])),4)
betaa <- round(c(-0.2465, 0.03786, 
                 -0.2468, 0.0417,
                 mean(mat1[501:2000,"betaa"]),sd(mat1[501:2000,"betaa"]),
                 mean(mat2[501:2000,"betaa"]),sd(mat2[501:2000,"betaa"]),
                 mean(mat3[501:2000,"betaa"]),sd(mat3[501:2000,"betaa"])),4) 
# Nas ####
Na3 <- round(c(993.9475, 26.52, 
               104.7687, 6.0909,
                  mean(mat1[501:2000,"Na[3]"]),sd(mat1[501:2000,"Na[3]"]),
                  mean(mat2[501:2000,"Na[3]"]),sd(mat2[501:2000,"Na[3]"]),
                  mean(mat3[501:2000,"Na[3]"]),sd(mat3[501:2000,"Na[3]"])),4)

Na13 <- round(c(1789.2550, 52.95, 
                170.5947, 6.6869,
                  mean(mat1[501:2000,"Na[13]"]),sd(mat1[501:2000,"Na[13]"]),
                  mean(mat2[501:2000,"Na[13]"]),sd(mat2[501:2000,"Na[13]"]),
                  mean(mat3[501:2000,"Na[13]"]),sd(mat3[501:2000,"Na[13]"])),4)

Na23 <- round(c(1469.4150, 49.46, 
                158.5800, 7.2918,
                  mean(mat1[501:2000,"Na[23]"]),sd(mat1[501:2000,"Na[23]"]),
                  mean(mat2[501:2000,"Na[23]"]),sd(mat2[501:2000,"Na[23]"]),
                  mean(mat3[501:2000,"Na[23]"]),sd(mat3[501:2000,"Na[23]"])),4)

Na33 <- round(c(975.9720, 59.51, 
                94.9613, 5.6326,
                mean(mat1[501:2000,"Na[33]"]),sd(mat1[501:2000,"Na[33]"]),
                mean(mat2[501:2000,"Na[33]"]),sd(mat2[501:2000,"Na[33]"]),
                mean(mat3[501:2000,"Na[33]"]),sd(mat3[501:2000,"Na[33]"])),4)


HMM_Resultsparams <- matrix(c(sigy,alphar,betar,alphal,betal,alpha1,beta1,alphaa,betaa,Na3,Na13,Na23,Na33),
                            ncol=10,byrow=T,
                            dimnames=list(c("sigy","alphar","betar","alphal","betal","alpha1","beta1","alphaa","betaa", "Na3","Na13","Na23","Na33"),
                                    c("Mean Full DA", "SD Full DA","Mean Scaled DA", "SD Scaled DA", "Mean Chain1","SD Chain1","Mean Chain2","SD Chain2","Mean Chain3","SD Chain3")))

save(HMM_Resultsparams, file = "BKM_HMM_Resultsparams.RData")
       

# ESS and IF ####
hist(mat1[,20])
IF_ess <- nrow(mat1)/ apply(mat1, 2, effectiveSize)
ESS <- apply(mat1, 2, effectiveSize)

par(mfrow=c(1,2))
barplot(ESS)
hist(ESS)

par(mfrow=c(1,2))
barplot(IF)
hist(IF)

IF = matrix(data=NA,nrow=ncol(mat1),ncol=1)
for (ii in 1:ncol(mat1)){
  acf_curr = acf(mat1[,ii],lag=iter,plot=FALSE)
  acf_curr = acf_curr$acf
  IF_curr = 1 + 2*sum(acf_curr[-1])
  IF[ii] = IF_curr
}