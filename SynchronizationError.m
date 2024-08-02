clc; clear; close all;

% Parameters
fs = 1e6; % Sampling frequency (Hz)
symbol_rate = 100e3; % Symbol rate (symbols per second)
samples_per_symbol = fs / symbol_rate; % Number of samples per symbol
num_symbols = 100; % Number of symbols to transmit
sync_error = 0.25; % Synchronization error as a fraction of the symbol period

% Generate random data symbols (BPSK)
data = randi([0 1], 1, num_symbols); % Random binary data
tx_symbols = 2*data - 1; % BPSK mapping: 0 -> -1, 1 -> 1

% Generate transmitted signal
t = (0:num_symbols*samples_per_symbol-1) / fs; % Time vector
tx_signal = repelem(tx_symbols, samples_per_symbol);

% Perfect synchronization (no error)
rx_signal_perfect = tx_signal;

% Synchronization error (offset in samples)
offset_samples = round(sync_error * samples_per_symbol);
rx_signal_error = [zeros(1, offset_samples), tx_signal(1:end-offset_samples)];

% Add noise
SNR = -10; % Signal-to-noise ratio in dB
rx_signal_perfect_noisy = awgn(rx_signal_perfect, SNR, 'measured');
rx_signal_error_noisy = awgn(rx_signal_error, SNR, 'measured');

% Plotting
figure;
subplot(3,1,1);
plot(t, tx_signal);
title('Transmitted Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3,1,2);
plot(t, rx_signal_perfect_noisy);
title('Received Signal with Perfect Synchronization');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3,1,3);
plot(t, rx_signal_error_noisy);
title('Received Signal with Synchronization Error');
xlabel('Time (s)');
ylabel('Amplitude');

% Receiver: Averaging over symbol period
averaged_perfect = zeros(1, num_symbols);
averaged_error = zeros(1, num_symbols);

for i = 1:num_symbols
    % Average the samples corresponding to each symbol
    start_idx = (i-1)*samples_per_symbol + 1;
    end_idx = i*samples_per_symbol;
    averaged_perfect(i) = mean(rx_signal_perfect_noisy(start_idx:end_idx));
    averaged_error(i) = mean(rx_signal_error_noisy(start_idx:end_idx));
end

% Decision making based on averaging
received_data_perfect_avg = averaged_perfect > 0;
received_data_error_avg = averaged_error > 0;

% Calculate BER (Bit Error Rate) for averaging method
ber_perfect_avg = sum(received_data_perfect_avg ~= data) / num_symbols;
ber_error_avg = sum(received_data_error_avg ~= data) / num_symbols;

% Display BER for averaging method
fprintf('BER with Perfect Synchronization (Averaging): %.4f\n', ber_perfect_avg);
fprintf('BER with Synchronization Error (Averaging): %.4f\n', ber_error_avg);