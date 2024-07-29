clc; clear; close all;
% Parameters
fs = 1e8; % Sampling frequency (Hz)
signal_duration = 10e-3; % Duration of the signal in seconds (longer the signal is, the more accurate the estimation)
t = 0:1/fs:signal_duration; % Time vector for the signal duration
signal_length = length(t); % Length of the signal
SNR = 5; % in dB

% Transmitted Signal (chirp)
f0 = 1000; % Start frequency of the chirp
f1 = 50000; % End frequency of the chirp
tx_signal = chirp(t, f0, signal_duration, f1);

% Location of APs and user in 2D plane
AP1 = [0,0];
AP2 = [100,0];
AP3 = [50,100];
userPos = [45,45];

% Delay in seconds
c = 3e8; % propagation speed
delay1 = norm(AP1-userPos)/c;
delay2 = norm(AP2-userPos)/c;
delay3 = norm(AP3-userPos)/c;

% Display the true delay
fprintf('True Time of Arrival to AP1: %.9f seconds\n', delay1);
fprintf('True Time of Arrival to AP2: %.9f seconds\n', delay2);
fprintf('True Time of Arrival to AP3: %.9f seconds\n', delay3);

% Delay in samples
delay_samples1 = round(delay1 * fs); 
delay_samples2 = round(delay2 * fs);
delay_samples3 = round(delay3 * fs);

% Rx copies at the APs (delayed and added noise)
rx_signal1 = circshift(tx_signal, delay_samples1);
rx_signal1(1:delay_samples1) = 0;
rx_signal1 = awgn(rx_signal1, SNR, 'measured');

rx_signal2 = circshift(tx_signal, delay_samples2);
rx_signal2(1:delay_samples2) = 0;
rx_signal2 = awgn(rx_signal2, SNR, 'measured');

rx_signal3 = circshift(tx_signal, delay_samples3);
rx_signal3(1:delay_samples3) = 0;
rx_signal3 = awgn(rx_signal3, SNR, 'measured');

%% Estimate time of arrivals and distance at APs
% Cross-correlation to estimate the delay
[corr1, lags1] = xcorr(rx_signal1, tx_signal);
[corr2, lags2] = xcorr(rx_signal2, tx_signal);
[corr3, lags3] = xcorr(rx_signal3, tx_signal);

% Find the peaks of the cross-correlation
[pks1, locs1] = findpeaks(corr1, 'MinPeakHeight', max(corr1) * 0.5);
[pks2, locs2] = findpeaks(corr2, 'MinPeakHeight', max(corr2) * 0.5);
[pks3, locs3] = findpeaks(corr3, 'MinPeakHeight', max(corr3) * 0.5);

estimated_delay_samples1 = lags1(locs1);
estimated_delay_samples2 = lags2(locs2);
estimated_delay_samples3 = lags3(locs3);

estimated_delay1 = estimated_delay_samples1 / fs;
estimated_delay2 = estimated_delay_samples2 / fs;
estimated_delay3 = estimated_delay_samples3 / fs;

% Display the estimated delay
fprintf('Estimated Time of Arrival to AP1: %.9f seconds\n', estimated_delay1);
fprintf('Estimated Time of Arrival to AP2: %.9f seconds\n', estimated_delay2);
fprintf('Estimated Time of Arrival to AP3: %.9f seconds\n', estimated_delay3);

% Estimate the distance
estimated_dist1 = estimated_delay1 * c;
estimated_dist2 = estimated_delay2 * c;
estimated_dist3 = estimated_delay3 * c;

%% Trilateration
AP_positions = [AP1;AP2;AP3];
Estimated_distances = [estimated_dist1;estimated_dist2;estimated_dist3];
A = 2 * (AP_positions(2:end, :) - AP_positions(1, :));
B = Estimated_distances(1)^2 - Estimated_distances(2:end).^2 + sum(AP_positions(2:end, :).^2, 2) - sum(AP_positions(1, :).^2);
pos = A \ B;

% Plotting
figure;
plot(AP_positions(:,1), AP_positions(:,2), 'ro', 'MarkerSize', 10, 'DisplayName', 'APs');
hold on;
plot(userPos(1), userPos(2), 'bx', 'MarkerSize', 10, 'DisplayName', 'True Position');
plot(pos(1),pos(2), 'g+', 'MarkerSize', 10, 'DisplayName', 'Estimated Position');
[x,y] = circle(AP1(1),AP1(2),estimated_dist1);
plot(x,y);
[x,y] = circle(AP2(1),AP2(2),estimated_dist2);
plot(x,y);
[x,y] = circle(AP3(1),AP3(2),estimated_dist3);
plot(x,y);
legend;
grid on;
xlabel('X Position (m)');
ylabel('Y Position (m)');
title('Trilateration Positioning');