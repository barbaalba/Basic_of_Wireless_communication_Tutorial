clc;clear;close all;
% Parameters
num_subcarriers = 64; % Number of subcarriers
cp_len = 16; % Length of the cyclic prefix
num_taps = 10; % Number of taps in the FIR filter (channel impulse response)
snr_db = 30; % Signal-to-noise ratio in dB
M = 16; % Modulation order for 16-QAM

% Generate random data symbols for OFDM subcarriers
data_bits = randi([0 M-1], 1, num_subcarriers); % Random bits for 16-QAM
data_symbols = qammod(data_bits, M, 'UnitAveragePower', true); % 16-QAM modulation
scatterplot(data_symbols);
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

% Add noise
signal_power = mean(abs(rx_signal).^2);
noise_power = signal_power / (db2pow(snr_db));
noise = sqrt(noise_power / 2) * (randn(size(rx_signal)) + 1i*randn(size(rx_signal)));
rx_signal = rx_signal + noise;

% Remove the cyclic prefix
rx_ofdm_symbol = rx_signal(cp_len+1:end);

% Convert back to frequency domain using FFT
rx_data_symbols = fft(rx_ofdm_symbol);

% Zero Forcing Equalization 
H = fft(h,num_subcarriers); % Channel frequency response
rx_data_symbols_zf = rx_data_symbols ./ H;
scatterplot(rx_data_symbols_zf);

% MMSE equalization
H_mag_squared = abs(H).^2;
rx_data_symbols_mmse = (H_mag_squared ./ (H_mag_squared + noise_power)) .* (rx_data_symbols ./ H);
scatterplot(rx_data_symbols_mmse);


% Calculate MSE 
MSE_mmse = mean(abs(data_symbols - rx_data_symbols_mmse).^2);
MSE_zf = mean(abs(data_symbols - rx_data_symbols_zf).^2);

% report the results 
disp(['MMSE MSE in dB: ', num2str(pow2db(MSE_mmse))]);
disp(['ZF MSE in dB: ', num2str(pow2db(MSE_zf))]);

% Plot transmitted, received, and equalized data symbols
figure;
subplot(2, 1, 1);
stem(abs(data_symbols),'LineWidth',2);
hold on;
stem(abs(rx_data_symbols_zf),'LineWidth',2,'LineStyle',':');
title('Equalized Data Symbols (ZF)');
xlabel('Subcarrier Index');
ylabel('Magnitude');

subplot(2, 1, 2);
stem(abs(data_symbols),'LineWidth',2);
hold on;
stem(abs(rx_data_symbols_mmse),'LineWidth',2,'LineStyle',':');
title('Equalized Data Symbols (MMSE)');
xlabel('Subcarrier Index');
ylabel('Magnitude');