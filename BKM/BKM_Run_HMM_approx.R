# Load required packages and fix the random seed
rm(list=ls())

setwd("BKM")
library(rjags)
library(coda)
library(lattice)
set.seed(134522)

save_on = FALSE
# MCMC details: ####

ada=100
iter=1000
th=1
cha=1

# Read data ###
source("BKM_Data_HMM_approx.R")
# Set parameters and inital values
source("BKM_StartingVals_HMM_approx.R")

if (1==0){
  alpha1 = 1
  beta1 =-2
  index = alpha1 + beta1*f
  phi1 = exp(index)/(1+exp(index))
  
  alpha1 = 0.54
  beta1 = -0.19
  index = alpha1 + beta1*f
  phi12 = exp(index)/(1+exp(index))
  
  alphar = -2
  betar = -0.7      
  index = alphar + betar*stdT
  rho = exp(index)
  
  par(mfrow=c(1,2))
  plot(f,type='l',col='blue')
  lines(phi1,col='red')
  lines(phi12,col='magenta')
  lines(rho,col='green')
  lines(phi1*0)
  plot(Na,type='l',col='blue')
}

# Compile the model: ####
tstart=proc.time()
mod <- jags.model('BKM_Bugs_HMM_approx.R',data,inits,n.chains=cha,n.adapt=ada)
temp=proc.time()-tstart
time_HMM_init <- temp # ada=100 PC: 357.39 ~ 6min --> 188.28 ~3 min with 0!
# ada = 1000 --> PC: 1798.68 
# ada = 100 --> laptop: 659
## updated code with ifelse etc: ada=100 PC:  1108.95 ~ 18 min
if (save_on) {
  save(mod, time_HMM_init, file = paste("Results/BKM_HMM_model_ada",toString(ada),"_laptop.RData",sep=""))
}


# Run the MCMC: #### 
tstart=proc.time()
output1 <- coda.samples(mod,params,n.iter=iter,thin=th)
temp=proc.time()-tstart
time_HMM_sample <- temp # PC:   1843.02 ~31 min
# ada = 1000 --> 1741.71
# ada = 100 --> laptop: 6449 ~ 108 min
if (save_on) {
  save(output1, time_HMM_sample, file =  paste("Results/BKM_HMM_approx_iter",toString(iter),"_ada",toString(ada),"_laptop.RData",sep=""))
}


# Collect the results ####
mat1 = as.matrix(output1[1])
mat2 = as.matrix(output1[2])
mat3 = as.matrix(output1[3])


# Retrieve the names ####
mat1_names <- colnames(mat1) 

mat1_names[1] # "G[1,3]"
mat1_names[34*(N_bin+1)]      # "G[60,36]"
mat1_names[34*(N_bin+1)+1]    # "Na[1]"
mat1_names[34*(N_bin+1)+1+35] # "Na[36]"
mat1_names[34*(N_bin+1)+1+35+1] # "P[1,3]"
mat1_names[34*(N_bin+1)+1+35+34*(N_bin+1)] #"P[100,36]"
mat1_names[7036]
mat1_names[(34*(N_bin+1)+1+35+1):(34*(N_bin+1)+1+35+34*(N_bin+1))]


# PLOTS ####

# with Gammas and Ps ####

# Posterior means 
plot(colMeans(mat1[,(34*(N_bin+1)+1):(34*(N_bin+1)+1+35)]), type='l', xlab ="", ylab="", sub="Na")
mtext("Posterior means", outer=TRUE, cex=1)

mat1_names[1397:1405]
# "alpha1" "alphaa" "alphal" "alphar" "beta1"  "betaa"  "betal"  "betar"  "sigy"  
 
par(mfrow=c(3,3), oma = c(0, 0, 1.5, 0))
for (i in c(1397:1405)){
  plot(mat1[,i], type="l", xlab ="", ylab="", sub=mat1_names[i])
}

par(mfrow=c(3,3), oma = c(0, 0, 1.5, 0))
for (i in c(1397:1405)){
  acf(mat1[,i], main=mat1_names[i])
}

par(mfrow=c(3,3), oma = c(0, 0, 1.5, 0))
for (i in c(1:9)){
  plot(mat1[,34*(N_bin+1)+1+4*(i-3)+9], type="l", xlab ="", ylab="", sub=mat1_names[34*(N_bin+1)+1+4*(i-3)+9])
}

par(mfrow=c(3,3), oma = c(0, 0, 1.5, 0))
for (i in c(1:9)){
  acf(mat1[,34*(N_bin+1)+1+4*(i-3)+9], main=mat1_names[34*(N_bin+1)+1+4*(i-3)+9])
}

# without Gamma and Ps ####

# Posterior means 
par(mfrow=c(1,1))
plot(colMeans(mat1[,1:36]), type='l', xlab ="", ylab="", sub="Na")
mtext("Posterior means", outer=TRUE, cex=1)

mat1_names[37:45]
# "alpha1" "alphaa" "alphal" "alphar" "beta1"  "betaa"  "betal"  "betar"  "sigy"  

par(mfrow=c(3,3), oma = c(0, 0, 1.5, 0))
for (i in c(37:45)){
  plot(mat1[,i], type="l", xlab ="", ylab="", sub=mat1_names[i])
}

par(mfrow=c(3,3), oma = c(0, 0, 1.5, 0))
for (i in c(37:45)){
  acf(mat1[,i], main=mat1_names[i])
}

par(mfrow=c(3,3), oma = c(0, 0, 1.5, 0))
for (i in c(1:9)){
  plot(mat1[,4*(i-3)+9], type="l", xlab ="", ylab="", sub=mat1_names[4*(i-3)+9])
}

par(mfrow=c(3,3), oma = c(0, 0, 1.5, 0))
for (i in c(1:9)){
  acf(mat1[,4*(i-3)+9], main=mat1_names[4*(i-3)+9])
}







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




# DA WITH HMM MEANS STD #####
# sigy #### 
sigy <- round(c(30755.8259, 8700, 
                mean(mat1[501:2000,"sigy"]),sd(mat1[501:2000,"sigy"]),
                mean(mat2[501:2000,"sigy"]),sd(mat2[501:2000,"sigy"]),
                mean(mat3[501:2000,"sigy"]),sd(mat3[501:2000,"sigy"])),4)

# alphas betas  ####


#  DA scaled for ada=100, iter=2000
alphar <- round(c(-1.1723, 0.06579, 
                mean(mat1[501:2000,"alphar"]),sd(mat1[501:2000,"alphar"]),
                mean(mat2[501:2000,"alphar"]),sd(mat2[501:2000,"alphar"]),
                mean(mat3[501:2000,"alphar"]),sd(mat3[501:2000,"alphar"])),4)
betar <- round(c(-0.3360, 0.03254, 
                  mean(mat1[501:2000,"betar"]),sd(mat1[501:2000,"betar"]),
                  mean(mat2[501:2000,"betar"]),sd(mat2[501:2000,"betar"]),
                  mean(mat3[501:2000,"betar"]),sd(mat3[501:2000,"betar"])),4) 

alphal <- round(c(-4.5760, 0.3534, 
                  mean(mat1[501:2000,"alphal"]),sd(mat1[501:2000,"alphal"]),
                  mean(mat2[501:2000,"alphal"]),sd(mat2[501:2000,"alphal"]),
                  mean(mat3[501:2000,"alphal"]),sd(mat3[501:2000,"alphal"])),4)
betal <- round(c(-0.3650, 0.03981,
                 mean(mat1[501:2000,"betal"]),sd(mat1[501:2000,"betal"]),
                 mean(mat2[501:2000,"betal"]),sd(mat2[501:2000,"betal"]),
                 mean(mat3[501:2000,"betal"]),sd(mat3[501:2000,"betal"])),4) 

alpha1 <- round(c(0.5540, 0.06888,
                  mean(mat1[501:2000,"alpha1"]),sd(mat1[501:2000,"alpha1"]),
                  mean(mat2[501:2000,"alpha1"]),sd(mat2[501:2000,"alpha1"]),
                  mean(mat3[501:2000,"alpha1"]),sd(mat3[501:2000,"alpha1"])),4)
beta1 <- round(c(-0.1913, 0.05668, 
                 mean(mat1[501:2000,"beta1"]),sd(mat1[501:2000,"beta1"]),
                 mean(mat2[501:2000,"beta1"]),sd(mat2[501:2000,"beta1"]),
                 mean(mat3[501:2000,"beta1"]),sd(mat3[501:2000,"beta1"])),4) 
       
alphaa <- round(c(1.5678, 0.06338, 
                  mean(mat1[501:2000,"alphaa"]),sd(mat1[501:2000,"alphaa"]),
                  mean(mat2[501:2000,"alphaa"]),sd(mat2[501:2000,"alphaa"]),
                  mean(mat3[501:2000,"alphaa"]),sd(mat3[501:2000,"alphaa"])),4)
betaa <- round(c(-0.2465, 0.03786, 
                 mean(mat1[501:2000,"betaa"]),sd(mat1[501:2000,"betaa"]),
                 mean(mat2[501:2000,"betaa"]),sd(mat2[501:2000,"betaa"]),
                 mean(mat3[501:2000,"betaa"]),sd(mat3[501:2000,"betaa"])),4) 
# Nas ####
Na3 <- round(c(993.9475, 26.52, 
                  mean(mat1[501:2000,"Na[3]"]),sd(mat1[501:2000,"Na[3]"]),
                  mean(mat2[501:2000,"Na[3]"]),sd(mat2[501:2000,"Na[3]"]),
                  mean(mat3[501:2000,"Na[3]"]),sd(mat3[501:2000,"Na[3]"])),4)

Na13 <- round(c(1789.2550, 52.95, 
                  mean(mat1[501:2000,"Na[13]"]),sd(mat1[501:2000,"Na[13]"]),
                  mean(mat2[501:2000,"Na[13]"]),sd(mat2[501:2000,"Na[13]"]),
                  mean(mat3[501:2000,"Na[13]"]),sd(mat3[501:2000,"Na[13]"])),4)

Na23 <- round(c(1469.4150, 49.46, 
                  mean(mat1[501:2000,"Na[23]"]),sd(mat1[501:2000,"Na[23]"]),
                  mean(mat2[501:2000,"Na[23]"]),sd(mat2[501:2000,"Na[23]"]),
                  mean(mat3[501:2000,"Na[23]"]),sd(mat3[501:2000,"Na[23]"])),4)

Na33 <- round(c(975.9720, 59.51, 
                mean(mat1[501:2000,"Na[33]"]),sd(mat1[501:2000,"Na[33]"]),
                mean(mat2[501:2000,"Na[33]"]),sd(mat2[501:2000,"Na[33]"]),
                mean(mat3[501:2000,"Na[33]"]),sd(mat3[501:2000,"Na[33]"])),4)


HMM_approx_Resultsparams <- matrix(c(sigy,alphar,betar,alphal,betal,alpha1,beta1,alphaa,betaa,Na3,Na13,Na23,Na33),
                            ncol=8,byrow=T,
                            dimnames=list(c("sigy","alphar","betar","alphal","betal","alpha1","beta1","alphaa","betaa", "Na3","Na13","Na23","Na33"),
                                    c("Mean Full DA", "SD Full DA", "Mean Chain1","SD Chain1","Mean Chain2","SD Chain2","Mean Chain3","SD Chain3")))

save(HMM_approx_Resultsparams, file = "BKM_HMM_approx_bin27_Resultsparams.RData")
       

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