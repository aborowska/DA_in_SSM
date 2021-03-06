T=36

# SCALE TO PRACTICE HMM
sc <- 10 
 
time <- seq(1,T,1)                
# standardize the variable
stdT <- (time-mean(time))/sd(time)

# index record - SCALED FOR HMM
y=c(0, 0, 1092.23, 1100.01, 1234.32, 1460.85, 1570.38, 1819.79, 1391.27, 1507.60,
    1541.44, 1631.21, 1628.60, 1609.33, 1801.68, 1809.08, 1754.74, 1779.48, 1699.13,
    1681.39, 1610.46, 1918.45, 1717.07, 1415.69, 1229.02, 1082.02, 1096.61, 1045.84,
    1137.03, 981.1, 647.67, 992.65, 968.62, 926.83, 952.96, 865.64)/sc

# frost days 
f=c(0.1922, 0.3082, 0.3082, -0.9676, 0.5401, 0.3082, 1.1995, 0.1921, -0.8526,
    -1.0835, -0.6196, -1.1995, -0.5037, -0.1557, 0.0762, 2.628, -0.3877, -0.968,
    1.9318, -0.6196, -0.3877, 1.700, 2.2797, 0.6561, -0.8516, -1.0835, -1.0835,
    0.1922, 0.1922, -0.1557, -0.5037, -0.8516, 0.8880, -0.0398, -1.1995, 0)


data <-list(T=T, y=y, f=f, stdT=stdT)
