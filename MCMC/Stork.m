% setwd("../MCMC")
%%%%%%
% Main code for running MCMC algorithm for capture-recapture data
% - white stork data using MH random walk update - created by RK (Nov 08)
%%%%%%

% Define the function: with input parameters:
% nt = number of iterations
% nburn  = burn-in
nt = 10000;
nburn = 1000;


% funtion storkcodeMH(nt,nburn)

    % Define the parameter values:
    % ni = number of release years
    % nj = number of recapture years
    % nparam = maximum number of parameters
    % ncov = maximum number of covariates
    ni = 16;
    nj = 16;
    nparam = 3;
    ncov = 1;

    % Read in the data:
    data = [19,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5;
            0,33,3,0,0,0,0,0,0,0,0,0,0,0,0,0,14;
            0,0,35,4,0,0,0,0,0,0,0,0,0,0,0,0,14;
            0,0,0,42,1,0,0,0,0,0,0,0,0,0,0,0,26;
            0,0,0,0,42,1,0,0,0,0,0,0,0,0,0,0,30;
            0,0,0,0,0,32,2,1,0,0,0,0,0,0,0,0,36;
            0,0,0,0,0,0,46,2,0,0,0,0,0,0,0,0,16;
            0,0,0,0,0,0,0,33,3,0,0,0,0,0,0,0,28;
            0,0,0,0,0,0,0,0,44,2,0,0,0,0,0,0,20;
            0,0,0,0,0,0,0,0,0,43,1,0,0,1,0,0,10;
            0,0,0,0,0,0,0,0,0,0,34,1,0,0,0,0,25;
            0,0,0,0,0,0,0,0,0,0,0,36,1,0,0,0,16;
            0,0,0,0,0,0,0,0,0,0,0,0,27,2,0,0,22;
            0,0,0,0,0,0,0,0,0,0,0,0,0,22,0,0,16;
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,15,1,17;
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,15,8];
    
    % Read in the covariate values:
    cov = [0.79,2.04,1.04,-0.15,-0.01,-0.48,1.72,-0.83,...
    -0.02,0.14,-0.71,0.50,-0.62,-0.88,-1.00,-1.52];
    
    mn = zeros(1,nparam);
    std = zeros(1,nparam);

    % Read in the priors:
    % Beta prior on recapture probability
    alphap = 1;
    betap = 1;
    % Normal priors (mean and variance) on regression coefficients
    mu = [0,0];
    sig2 = [10,10];
    sig = sqrt(sig2);

    % Parameters for MH updates (Uniform random walk):
    delta = [0.05,0.1,0.1];

    % Set initial parameter values:
    param = [0.9,0.7,0.1];

    % param[1] = recapture rate
    % param[2:12] = regression coefficients for survival rates

    % sample is an array in which we put the sample from the posterior distribution.
    sample = zeros(nt, nparam);
 
    % Label the columns of the array "sample"
    names_sample = ['p', 'beta0', 'beta1'];

    % Calculate log(likelihood) for initial state using a separate function "calclikhood":
    likhood = calclikhood(ni, nj, data, param, nparam, cov, ncov);

    % Set up a vector for parameter values and associated log(likelihood):
%     output = zeros(1,nparam+1);

    % MCMC updates - MH algorithm: %%%%
    % Cycle through each iteration:

    for t = 1:nt
        % Update the parameters in the model using function "updateparam":
        [param, likhood] = updateparam(nparam, param, ncov, cov, ni, nj, data, likhood, alphap, betap, mu, sig, delta);

        % Set parameter values and log(likelihood) value of current state to be the output from
        % the MH step:

%         param = output(1:nparam);
%         likhood = output(nparam+1)

        % Record the set of parameter values:
%         for ii =  1:nparam            
%             sample[t,i] = param(ii)
%         end
        sample(t,:)= param;
%         if (t >= (nburn+1)) 
%             for ii = 1:nparam 
%                 mn(ii) = mn(ii) + param(ii);
%                 std(ii) = std(ii) + param(ii).^2;
%             end
%         end
    end
mn = mean(sample((nburn+1):end,:));
sd = std(sample((nburn+1):end,:));
    % Calculate the mean and standard deviation of the parameters
    % following burn-in:
    for ii = 1:nparam
        mn(ii) = mn(ii)/(nt-nburn);
        std(ii) = std(ii)/(nt-nburn);
        std(ii) = std(ii) - (mn(ii)).^2;
    end
    
%     % Output the posterior mean and standard deviation of the parameters
%     % following burn-in to the screen:
%     cat("Posterior summary estimates for each parameter:  ", "\n")
%     cat("\n")
%     cat("mean  (SD)", "\n")
%     cat("p: ", "\n")
%     cat(mn[1], "   (", std[1], ")", "\n")
%     for (i in 2:nparam) 
%         if (mn(ii) != 0) 
%             cat("\n")
%             cat("beta_",(i-2), "\n")
%             cat(mn(ii), " (", std(ii), ")", "\n")
%         end
%     end

    % Output the sample from the posterior distribution:
%     sample
% end