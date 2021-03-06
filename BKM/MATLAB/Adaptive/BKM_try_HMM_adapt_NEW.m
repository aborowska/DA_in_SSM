function Results = BKM_try_HMM_adapt(N_q, M, BurnIn, save_on)
%     clear all
%     close all
%     N_q = 30;
%     M = 10000;
%     BurnIn = 20000; %50000;
    M=100000; BurnIn=10000; N_q = 20;
    
    fprintf('*** BKM_HMM_adapt M=%i, BurnIn=%i, N_q = %i ***\n', M, BurnIn,N_q);
    
    addpath(genpath('../'));

    plot_on = false;

    sc = 1;
    [y, T, time, stdT, f, m, T1, T2] = BKM_Data_HMM(sc);

    Na = round( [1000, 1000, 1092.23, 1100.01, 1234.32, 1460.85, 1570.38, 1819.79,...
        1391.27, 1507.60, 1541.44, 1631.21, 1628.60, 1609.33, 1801.68, 1809.08, 1754.74,...
        1779.48, 1699.13, 1681.39, 1610.46, 1918.45, 1717.07, 1415.69, 1229.02, 1082.02,...
        1096.61, 1045.84, 1137.03, 981.1, 647.67, 992.65, 968.62, 926.83, 952.96, 865.64]/sc);

    Na(31) = 900;


%        alpha1        alphaa        alphal        alphar         beta1         betaa         betal         betar          sigy 
%     0.5490783     1.5673245    -4.5771131    -1.1760594    -0.1907766    -0.2472439    -0.3636677    -0.3421766 30440.2276841 
    alpha1 = 0.5490783;%1;
    alphaa = 1.5673245 ; %2;
    alphar = -1.1760594; %-2;
    alphal = -4.5771131 ; %-4;
    beta1 = -0.1907766; %-2;
    betaa = -0.2472439 ; %0.1;
    betar = -0.3421766; %-0.7;
    betal = -0.3636677  ; %-0.3;
    sigy = 30440;%1;
 
    
    params = {'alpha1', 'alphaa', 'alphar', 'alphal', ...
        'beta1', 'betaa', 'betar', 'betal',...
        'sigy'};

    theta_init = [alpha1, alphaa, alphar, alphal, beta1, betaa, betar, betal, sigy];
    [phi1, phia, rho, lambda] = BKM_covariates(theta_init,f,stdT);  

    D = size(theta_init,2);
    prior.N = [200/sc 2000/sc 0.5];
    prior.S = [0.001,0.001];
    prior.T_mu = 0*ones(D-1,1);
    prior.T_sigma2 = 100*ones(D-1,1);

    % Quanatiles
%     N_q = 20; 
    qu = (0:(N_q-1))/N_q;
    qu_mid = qu + qu(2)/2; 
    mid = norminv(qu_mid);  

    logfact_fun = @(xx) sum(log(1:1:xx));
    logfact = arrayfun(logfact_fun,0:10000) ;
    %% Set the proposals
    % for the parameters

    % step sizes 
    % given step size delta, std for URW is delta/sqrt(3), for NRW 1*delta
    % 0.5 of posterior st. dev. turns out to be: 
    % [0.04 0.04 0.1 0.02 0.03 0.02 0.06 0.02]
    % from JAGS [0.04 0.04 0.05 0.02 0.03 0.02 0.03 0.02]
    delta.T = [0.1 0.04 0.05 0.1 0.1 0.035 0.05 0.12]; %    0.3149    0.3243    0.2822    0.3033    0.2950    0.3043    0.3145    0.3009
    % delta.T = [0.04 0.04 0.05 0.02 0.03 0.02 0.03 0.02];
% mean(accept(:,37:44)))
    %     delta.N = 130 + 0.5;  
    % delta.N = 80 + 0.5;  %mean(mean(accept(:,3:T))) = 0.3952
    % delta.N = 90 + 0.5;  %mean(mean_accept(:,3:T)) = 0.3770
    if (N_q == 20)
%         delta.N = 95 + 0.5;  %mean(mean(accept(:,1:T))) =  0.2096
        delta.N = 65 + 0.5;  %mean(mean(accept(:,1:T))) =  0.2096
    elseif (N_q == 10)
    %     delta.N = 65 + 0.5;  %mean(mean_accept(:,1:T)) = 0.4376
        delta.N = 75 + 0.5;  %mean(mean_accept(1:T)) = 0.4141
    elseif (N_q == 30)
        delta.N = 95 + 0.5;  %mean(mean_accept(1:T)) =  0.3672
    else
        delta.N = 15 + 0.5;
    end

    oldlikhood = BKM_calclikhood_HMM_adapt_NEW(Na, theta_init, y, m, f,...
        stdT, prior.N, mid, logfact);


    N = Na;
    theta = theta_init;
    NN = zeros(T,M);
    Theta = zeros(M,9);
    accept = zeros(M,T+D-1);

    tic
    % profile on
    for ii = 1:M%-BurnIn:M
        % Update the parameters in the model using function "updateparam": 
        % Set parameter values and log(likelihood) value of current state to be the output from
        % the MH step:

        if (mod(ii,1000)==0)
            fprintf('MH iter = %i\n',ii); toc;
        end
        [N, theta, acc] = BKM_update_HMM_adapt_NEW(N, theta, prior, delta, y, m, f, stdT, mid, logfact);
        if (ii > 0)
            NN(:,ii) = N;
            Theta(ii,:)= theta; 
            accept(ii,:) = acc; 
        end
    end
    time_sampl = toc;  
    
    Results.NN = NN;
    Results.Theta = Theta;
    Results.accept = accept;
    Results.time_sampl = time_sampl;
    if save_on
% %         name = ['../Results/BurnIn_',num2str(BurnIn),'/BKM_adapt_Nq',num2str(N_q),'.mat'];
%         name = ['Results/BurnIn_',num2str(BurnIn),'/BKM_adapt_Nq',num2str(N_q),'.mat'];
%         name = ['/home/aba228/Documents/BKM/BKM_adapt_Nq',num2str(N_q),'_v2.mat'];
        name = ['Results/BKM_adapt_Nq',num2str(N_q),'_v2.mat'];
        save(name,'delta','prior','theta_init','Na','NN','Theta',...
            'accept','time_sampl');
    end
end