clc;clear;close all;
% Parameters
fs = 1e6; % Sampling frequency (Hz)
signal_duration = 10e-3; % Duration of the signal in seconds (longer the signal is, the more accurate the estimation)
t = 0:1/fs:signal_duration; % Time vector for the signal duration
signal_length = length(t); % Length of the signal

% Transmitted Signal (sinc function)
tx_signal = sinc(2*pi*100*(t-signal_duration/2));

% Simulate the received signal with delay
delay = 50e-6; % Delay in seconds
delay_samples = round(delay * fs); % Delay in samples

rx_signal = [zeros(1, delay_samples) tx_signal]; % Received signal with delay
rx_signal = rx_signal(1:signal_length); % Truncate to the original signal length

% Add noise to the received signal
SNR = 20; % Signal-to-noise ratio in dB
rx_signal_noisy = awgn(rx_signal, SNR, 'measured');

% Cross-correlation to estimate the delay
[corr, lags] = xcorr(rx_signal_noisy, tx_signal);

% Find the peaks of the cross-correlation
[pks, locs] = findpeaks(corr, 'MinPeakHeight', max(corr)*0.5);

% Select the highest peak
[~, max_idx] = max(pks);
estimated_delay_samples = lags(locs(max_idx));
estimated_delay = estimated_delay_samples / fs;

% Plotting
figure;
subplot(3,1,1);
plot(t, tx_signal);
title('Transmitted Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3,1,2);
plot(t, rx_signal_noisy);
title('Received Signal with Noise');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3,1,3);
plot(lags/fs, corr);
title('Cross-Correlation');
xlabel('Lag (s)');
ylabel('Correlation');
hold on;
plot(estimated_delay, corr(locs(max_idx)), 'ro');
hold off;

% Display the estimated delay
fprintf('Estimated Time of Arrival: %.6f seconds\n', estimated_delay);