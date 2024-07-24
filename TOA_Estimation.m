% Parameters
fs = 1e6; % Sampling frequency (Hz)
t = 0:1/fs:1e-3; % Time vector for 1 ms
fc = 2.4e9; % Carrier frequency (Hz)
signal_length = length(t); % Length of the signal

% Transmitted Signal (example: a simple sine wave)
tx_signal = cos(2*pi*fc*t);

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

% Find the peak of the cross-correlation
[~, I] = max(abs(corr));

% Calculate the estimated delay
estimated_delay_samples = lags(I);
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
plot(lags/fs, abs(corr));
title('Cross-Correlation');
xlabel('Lag (s)');
ylabel('Correlation');
hold on;
plot(estimated_delay, max(abs(corr)), 'ro');
hold off;

% Display the estimated delay
fprintf('Estimated Time of Arrival: %.6f seconds\n', estimated_delay);
