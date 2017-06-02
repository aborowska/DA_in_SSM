function h = integrate_h_HMM(y, theta, bins, bin_midpoint)

    T = length(y);
    N_bin = length(bin_midpoint);
    % bins are the demeaned volatilities
    mu = theta(1);
    phi = theta(2);
    sigma2 = theta(3);
    sigma = sqrt(sigma2);
    
    G = zeros(N_bin,N_bin);
    % G(ii,jj) = Pr((h_t-mu)in bins(jj:(jj+1)) | (h_t-1 - mu) = bin_midpoint(jj))
    P = zeros(N_bin,T);
    
    for ii = 1:N_bin
        for jj = 1:N_bin
            z_up = (bins(jj+1)- phi*bin_midpoint(ii))/sigma;
            z_dn = (bins(jj)  - phi*bin_midpoint(ii))/sigma;
            G(jj,ii) = normcdf(z_up) - normcdf(z_dn); 
        end
    end
  
    delta =  % the stationary distribution
    
%     z = exp(-0.5*(bin_midpoint+mu)')*y;
%     P = normpdf(z);
    for ii = 1:N_bin
        for t = 1:T
            P(ii,t) = normpdf(y(t),0,exp(0.5*(bin_midpoint(ii)+mu)));   
        end
    end
    
    loglik = zeros(1,T);
    for t = 2:T
        loglik(t) = log(sum(sum(G*diag(P(:,t)))));
    end
end