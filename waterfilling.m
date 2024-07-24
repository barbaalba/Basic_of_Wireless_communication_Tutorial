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

end