function P_opt = waterfilling(csi,P_t)
% This function is assigning power to different user/subcarrier/mimo
% channel according to waterfilling. The optimization is solved using
% bisection
% csi: channel state information which is the ration between channel gain
% and noise power
% P_t: Total power budget
var = inf;
mu_upperbound = max(csi)+1;
mu_lowerbound = 1e-4;

mu_half = mean([mu_lowerbound,mu_upperbound]);
p_k = max(1./mu_half - (1./csi)',0); % all the possible power allocation for grid of mu (num_parallel * search_resolution)
disp(sum(p_k));
while var > 0.0001 || sum(p_k) > P_t
    if sum(p_k) < P_t
        mu_upperbound = mu_half;
        mu_half = mean([mu_lowerbound,mu_upperbound]);
        p_k = max(1./mu_half - (1./csi)',0); % all the possible power allocation for grid of mu (num_parallel * search_resolution)
        var = abs(mu_half - mu_upperbound);
    else
        mu_lowerbound = mu_half;
        mu_half = mean([mu_lowerbound,mu_upperbound]);
        p_k = max(1./mu_half - (1./csi)',0); % all the possible power allocation for grid of mu (num_parallel * search_resolution)
        var = abs(mu_half - mu_lowerbound);
    end
end
mu_opt = mu_half;
P_opt = max(1/mu_opt - 1./csi,0);

% Perform 1D search since the objective function is nonlinear function of mu
% search_resolution = 1e4; 
% mu = linspace(1e-4,P_t,search_resolution);
% 
% p_k = max(1./mu - (1./csi)',0); % all the possible power allocation for grid of mu (num_parallel * search_resolution)
% 
% g = sum(log2(1 + p_k.* (repmat(csi',[1 search_resolution])))) - ...
%     mu.*(sum(p_k) - P_t); % Dual function value for all possible mu
% 
% [~,ind] = find(g == min(g));
% mu_opt = mu(ind); % The power level 
% 
% P_opt = max(1/mu_opt - 1./csi,0);
end