params <- c('sigy','Na',
            'alpha1','alphaa','alphar','alphal',
            'beta1', 'betaa','betar', 'betal')
 
inits <- function(){list(tauy = 1,
                         Na_cont = c(1000, 1000, 1092.23, 1100.01, 1234.32, 1460.85, 1570.38, 1819.79,
                                      1391.27, 1507.60, 1541.44, 1631.21, 1628.60, 1609.33, 1801.68, 1809.08, 1754.74,
                                      1779.48, 1699.13, 1681.39, 1610.46, 1918.45, 1717.07, 1415.69, 1229.02, 1082.02,
                                      1096.61, 1045.84, 1137.03, 981.1, 647.67, 992.65, 968.62, 926.83, 952.96, 865.64)/sc,
                         alpha1 = 1, alphaa = 2, alphar = -1.106, alphal = -4,
                         beta1 = -0.19, betaa = 0.1, betar = -0.299 , betal = -0.3)}

 
Na = round(c(1000, 1000, 1092.23, 1100.01, 1234.32, 1460.85, 1570.38, 1819.79,
             1391.27, 1507.60, 1541.44, 1631.21, 1628.60, 1609.33, 1801.68, 1809.08, 1754.74,
             1779.48, 1699.13, 1681.39, 1610.46, 1918.45, 1717.07, 1415.69, 1229.02, 1082.02,
             1096.61, 1045.84, 1137.03, 981.1, 647.67, 992.65, 968.62, 926.83, 952.96, 865.64)/sc)