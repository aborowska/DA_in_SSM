# keep X1 and X3 to initialise X2 and X4
# X1init=rep(1400,T)/sc
# X1init[2:T] <- rpois((T-1),c(4000/sc,y[2:(T-1)])*0.5)
# X2init=rep(1200,T)/sc
# X2init[2:T] <- rbinom((T-1),X1init[1:(T-1)],0.9)
# X3init=rep(1000,T)/sc
# X3init[2:T] <- rbinom((T-1),X2init[1:(T-1)],0.9)
# X4init=rep(900,T)/sc
# X4init[2:T] <- rbinom((T-1),X3init[1:(T-1)],0.9)
# 
# 
# X2init=rep(1200,T)/sc
# X4init=rep(2000,T)/sc

# tauy = 1 #1000
alpha = c(-0.55, -0.1, 0.5, 1.1)
beta = c(0.02, -0.15, -0.15, -0.2)
alphal = 1.65
betal = -0.2
alpharho = 1.1
tauy = 0.1000


X2init= c(1500,y[-1]*2/7);
X4init= c(4000, y[-1]*4/7);

 
# inits <- function()(list(alpha=rep(0,4),beta=rep(0,4),alphal=0,betal=0,alpharho=0,tauy=tauy,
#                          X2_cont=X2init,X4_cont=X4init))


inits <- function()(list(alpha=alpha,beta=beta,alphal=alphal,betal=betal,alpharho=alpharho,tauy=tauy,
                         X2_cont=X2init,X4_cont=X4init))

# params <- c('alpha','alpharho','alphal', 'beta', 'betal', 'tauy', 'X2', 'X4','G1','P2','G3','P4','Q')
# params <- c('alpha','alpharho','alphal', 'beta', 'betal', 'tauy', 'X2', 'X4','G1','P2')
params <- c('alpha','alpharho','alphal', 'beta', 'betal', 'tauy', 'X2', 'X4')
