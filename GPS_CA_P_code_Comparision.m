%% This code demonstrate the accuracy of the C/A and P-codes in GPS system
% To do list:
%   - Add noise into the system
%   - Use L1 and L2 carrier waves to modulate the signal

clear;clc;close all;
% Parameters
c = 299792458; % Speed of light in m/s
fs = 10.23e6;  % Sampling frequency for P-code (10.23 MHz)
fc_ca = 1.023e6; % Chipping rate of C/A code (1.023 MHz)
t_ca = 1e-3; % Time periof of one cycle of C/A code (1 ms)
fc_p = 10.23e6;  % Chipping rate of P code (10.23 MHz)
f_L1_carrier = 1.57542e9; % Carrier frequency for L1 (GPS) in Hz
f_L2_carrier = 1.2276e9; % Carrier frequency for L2 (GPS) in Hz
sim_time = 1; % Simulation time in seconds (1 s)
num_samples_ca = sim_time * fc_ca;
num_samples_p = sim_time * fc_p;
monte = 100; % number of monte carlo simulations

% Simulate propagation delay (distance)
true_distance = 20200e3; % Assume a distance of 20,200 km (typical GPS satellite distance)
prop_delay = true_distance / c; % Propagation delay in seconds
prop_delay_samples_ca = round(prop_delay * fc_ca);
prop_delay_samples_p = round(prop_delay * fc_p);

dist_err_ca = zeros(1,monte);
dist_err_p = zeros(1,monte);
for monte_idx = 1:monte
    % Generate C/A and P codes (simplified)
    ca_code_one_cycle =  randi([0 1], 1, fc_ca*t_ca) * 2 - 1; % BPSK: {0,1} -> {-1,1}
    ca_code = repmat(ca_code_one_cycle,1,sim_time/t_ca);
    p_code = randi([0 1], 1, num_samples_p) * 2 - 1;   % BPSK: {0,1} -> {-1,1}
    
    % Receiver signal (delayed version of transmitted signal)
    rx_ca_code = [zeros(1, prop_delay_samples_ca), ca_code];
    rx_ca_code = rx_ca_code(1:num_samples_ca); % Truncate to original signal length
    
    rx_p_code = [zeros(1, prop_delay_samples_p), p_code];
    rx_p_code = rx_p_code(1:num_samples_p); % Truncate to original signal length
    
    % Pseudorange estimation using cross-correlation
    [corr_signal_ca,lags_ca] = xcorr(rx_ca_code, ca_code_one_cycle);
    [corr_signal_p,lags_p] = xcorr(rx_p_code, p_code);
    
    %[~, peak_idx_ca] = max(corr_signal_ca);
    [~,peak_idx_ca] = findpeaks(corr_signal_ca,'MinPeakHeight',max(corr_signal_ca)/1.8);
    estimated_delay_ca = lags_ca(peak_idx_ca(1)) / fc_ca;
    estimated_distance_ca = estimated_delay_ca * c;

    %estimated_delay_ca = lags_ca(peak_idx_ca) / fc_ca;
    %estimated_distance_ca = estimated_delay_ca * c;
    %disp(estimated_distance_ca);
    [~, peak_idx_p] = max(corr_signal_p);
    estimated_delay_p = lags_p(peak_idx_p) / fc_p;
    estimated_distance_p = estimated_delay_p * c;

    dist_err_ca(monte_idx) = abs(true_distance - estimated_distance_ca);
    dist_err_p(monte_idx) = abs(true_distance - estimated_distance_p);
end
figure;
subplot(2, 1, 1);
plot(lags_ca,corr_signal_ca);
subplot(2,1,2);
plot(lags_p,corr_signal_p);

% Display results
fprintf('True distance: %.2f km\n', true_distance / 1e3);
fprintf('Error using C/A code: %.4f km\n', mean(dist_err_ca)/1e3);
fprintf('Error using P code: %.4f km\n', mean(dist_err_p)/1e3);