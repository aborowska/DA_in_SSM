function [h, accept, A_sum] = update_h_HMM_v2(y, h, theta, delta_h,  bins, bin_midpoint)
% integrate out the odd h(t)'s and impute the even ones
    T = length(y);
    odd = mod(T,2);    
    T2 = floor(T/2);
    T = 2*T2; % to make T even

%     bin_size = bin_midpoint(2)-bin_midpoint(1);
    
    mu = theta(1);
    phi = theta(2);
    sigma2 = theta(3);
%     stdev_y = exp((mu+bin_midpoint)/2);  

    accept = 0;
    A_sum = 0;
    
    h0 = mu; %mu/(1-phi); % unconditional mean
    
    for t = 2:2:T % 1:2:T    
        %% RW IMPUTATION
        % Keep a record of the current N1 value being updated
        h_old = h(t);
        % normal  RW for h
        h(t) = h_old + delta_h*randn;
        % Calculate the log(acceptance probability):
        % Calculate the new likelihood value for the proposed move:
        % Calculate the numerator (num) and denominator (den) in turn:

        %% Numerator
        num = -0.5*(log(2*pi) + h(t) + (y(t)^2)/exp(h(t)));
        % integrate out the previous h 
        loglik_int = - 0.5*(log(2*pi) + log(sigma2) + ((h(t) - mu - phi*bin_midpoint).^2)/sigma2);
        loglik_int = loglik_int - 0.5*(log(2*pi) + (mu + bin_midpoint) + (y(t-1)^2)./exp(mu + bin_midpoint));    
    %     loglik_int = loglik_int + log(diff(normcdf((bins-phi*(h_prev-mu))/sigma)));
        if (t==2)
            loglik_int = loglik_int - 0.5*(log(2*pi) + log(sigma2) + ((bin_midpoint - phi*(h0-mu)).^2)/sigma2);
        else
            loglik_int = loglik_int - 0.5*(log(2*pi) + log(sigma2) + ((bin_midpoint - phi*(h(t-2)-mu)).^2)/sigma2);
        end    
        num = num + log(sum(exp(loglik_int)));
        
        % integrate out the next h 
        if (t<T)   % t+2 <= T
            loglik_int = - 0.5*(log(2*pi) + log(sigma2) + ((h(t+2) - mu - phi*bin_midpoint).^2)/sigma2);
            loglik_int = loglik_int - 0.5*(log(2*pi) + (mu + bin_midpoint) + (y(t+1)^2)./exp(mu + bin_midpoint));    
    %     loglik_int = loglik_int + log(diff(normcdf((bins-phi*(h_prev-mu))/sigma)));
            loglik_int = loglik_int - 0.5*(log(2*pi) + log(sigma2) + ((bin_midpoint - phi*(h(t)-mu)).^2)/sigma2);
            num = num + log(sum(exp(loglik_int)));
        end    
        
        %% Denominator
        den = -0.5*(log(2*pi) + h_old + (y(t)^2)/exp(h_old));
        % integrate out the previous h 
        loglik_int = - 0.5*(log(2*pi) + log(sigma2) + ((h_old - mu - phi*bin_midpoint).^2)/sigma2);
        loglik_int = loglik_int - 0.5*(log(2*pi) + (mu + bin_midpoint) + (y(t-1)^2)./exp(mu + bin_midpoint));    
    %     loglik_int = loglik_int + log(diff(normcdf((bins-phi*(h_prev-mu))/sigma)));
        if (t==2)
            loglik_int = loglik_int - 0.5*(log(2*pi) + log(sigma2) + ((bin_midpoint - phi*(h0-mu)).^2)/sigma2);
        else
            loglik_int = loglik_int - 0.5*(log(2*pi) + log(sigma2) + ((bin_midpoint - phi*(h(t-2)-mu)).^2)/sigma2);
        end    
        den = den + log(sum(exp(loglik_int)));
        
        % integrate out the next h 
        if (t<T)   % t+2 <= T
            loglik_int = - 0.5*(log(2*pi) + log(sigma2) + ((h(t+2) - mu - phi*bin_midpoint).^2)/sigma2);
            loglik_int = loglik_int - 0.5*(log(2*pi) + (mu + bin_midpoint) + (y(t+1)^2)./exp(mu + bin_midpoint));    
    %     loglik_int = loglik_int + log(diff(normcdf((bins-phi*(h_prev-mu))/sigma)));
            loglik_int = loglik_int - 0.5*(log(2*pi) + log(sigma2) + ((bin_midpoint - phi*(h_old-mu)).^2)/sigma2);
            den = den + log(sum(exp(loglik_int)));
        end  
        
        %% Acceptance Rate
        % Proposal terms cancel since proposal distribution is symmetric.
        % All other prior terms cancel in the acceptance probability. 
        % Acceptance probability of MH step:
        A = min(1,exp(num-den));
 
        A_sum = A_sum + A;
        % To do the accept/reject step of the algorithm:        
        % Accept the move with probability A:
        if (rand <= A)  % Accept the proposed move:
            % Update the log(likelihood) value:
%             oldlikhood = newlikhood;     
            accept = accept+1;
        else  % Reject proposed move:
            % Na stays at current value:
            h(t) = h_old;
        end              
    end
end
