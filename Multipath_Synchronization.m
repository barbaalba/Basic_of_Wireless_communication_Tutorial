clc; clear; close all;

% Parameters
fs = 1e6; % Sampling frequency (Hz)
signal_duration = 10e-3; % Duration of the signal in seconds (longer the signal is, the more accurate the estimation)
t = 0:1/fs:signal_duration; % Time vector for the signal duration
signal_length = length(t); % Length of the signal

% Transmitted Signal (chirp function)
f0 = 1000; % Start frequency of the chirp
f1 = 50000; % End frequency of the chirp
tx_signal = chirp(t, f0, signal_duration, f1);

% Simulate the received signal with delay
multipath_gain = [1, 0.5, 0.3];
multipath_delays = [50e-6, 80e-6, 120e-6]; % Delays in seconds
delay_samples = round(multipath_delays * fs); % Delay in samples

delayed_copies = repmat(tx_signal, length(multipath_gain), 1);
for i = 1:length(multipath_gain)
    delayed_copies(i, :) = circshift(delayed_copies(i, :), delay_samples(i));
    delayed_copies(i, 1:delay_samples(i)) = 0;
end

rx_signal = sum(multipath_gain' .* delayed_copies);

% Add noise to the received signal
SNR = 20; % Signal-to-noise ratio in dB
rx_signal_noisy = awgn(rx_signal, SNR, 'measured');

% Cross-correlation to estimate the delay
[corr, lags] = xcorr(rx_signal_noisy, tx_signal);

% Find the peaks of the cross-correlation
[pks, locs] = findpeaks(corr, 'MinPeakHeight', max(corr) * 0.5);

% Select the highest peak
[~, max_idx] = max(pks);
estimated_delay_samples = lags(locs(max_idx));
estimated_delay = estimated_delay_samples / fs;

%% Plotting
% time domain and frequency representation of the signal
figure;
subplot(2, 1, 1);
plot(t, tx_signal);
title('Transmitted Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2, 1, 2);
plot(fs/signal_length*(-signal_length/2:signal_length/2-1), abs(fftshift(fft(tx_signal))));
xlim([-10e4,10e4])
title('Frequency Response');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

% received signal and correlation
figure;
subplot(2, 1, 1);
plot(t, rx_signal_noisy);
title('Received Signal with Noise');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2, 1, 2);
plot(lags / fs, corr);
title('Cross-Correlation');
xlabel('Lag (s)');
ylabel('Correlation');
hold on;
plot(estimated_delay, corr(locs(max_idx)), 'ro');
hold off;

% Display the estimated delay
fprintf('Estimated Time of Arrival: %.6f seconds\n', estimated_delay);