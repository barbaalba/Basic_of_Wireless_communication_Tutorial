clc;clear;close all;
% Parameters
num_subcarriers = 64; % Number of subcarriers
cp_len = 16; % Length of the cyclic prefix
num_taps = 10; % Number of taps in the FIR filter (channel impulse response)

% Generate random data symbols for OFDM subcarriers
data_symbols = (randn(1, num_subcarriers) + 1i*randn(1, num_subcarriers)) / sqrt(2);

% Create the OFDM symbol by taking IFFT of data symbols
ofdm_symbol = ifft(data_symbols);

% Add cyclic prefix
cyclic_prefix = ofdm_symbol(end-cp_len+1:end);
ofdm_symbol_cp = [cyclic_prefix ofdm_symbol];

% Generate random complex gains for each tap (channel coefficients)
h = (randn(1, num_taps) + 1i*randn(1, num_taps)) / sqrt(2*num_taps);
h = sort(h,'descend');

% Normalize the channel to ensure unit power
h = h / norm(h);

% Pass the OFDM symbol with CP through the channel
rx_signal = conv(ofdm_symbol_cp, h);

% Extract the part corresponding to the received OFDM symbol
rx_signal = rx_signal(1:length(ofdm_symbol_cp));

% Remove the cyclic prefix
rx_ofdm_symbol = rx_signal(cp_len+1:end);

% Convert back to frequency domain using FFT
rx_data_symbols = fft(rx_ofdm_symbol);

% Plot transmitted and received data symbols
figure;
subplot(2, 1, 1);
stem(abs(data_symbols));
title('Transmitted Data Symbols (Magnitude)');
xlabel('Subcarrier Index');
ylabel('Magnitude');

subplot(2, 1, 2);
stem(abs(rx_data_symbols),'LineWidth',2);
title('Received Data Symbols (Magnitude)');
xlabel('Subcarrier Index');
ylabel('Magnitude');

%% This part of the code follow parallel memeoryless channel attained using 
% cyclic prefix
h_freq = fft(h,num_subcarriers);
rx_data_symbols = data_symbols .* h_freq;

% Plot received data symbols
subplot(2, 1, 2);
hold on;
stem(abs(rx_data_symbols),'LineStyle',':','LineWidth',2);
legend('Time domain processing','Frequency domain processing');


% Plot the channel impulse response
figure;
stem(abs(h));
title('Channel Impulse Response (Magnitude)');
xlabel('Tap Index');
ylabel('Magnitude');

figure;
stem(abs(h_freq));
title('Channel Frequency Response (Magnitude)');
xlabel('Subcarrier Index');
ylabel('Magnitude');