clc;clear;close all;
% Parameters
num_subcarriers = 64; % Number of subcarriers
cp_len = 10; % Length of the cyclic prefix
num_taps = 4; % Number of taps in the FIR filter (channel impulse response)
snr_db = 50; % Signal-to-noise ratio in dB
M = 16; % Modulation order for 16-QAM
k = log2(M); % Number of bits per symbol
waterconfig = 'bisect'; % solve waterfilling using bisection ('bisect') or closed form

% Generate random QAM data
% data = randi([0 1], 1,num_subcarriers*k); % Random 16-QAM symbols
% qam_data = transpose(qammod(data', M, "bin",'InputType','bit','UnitAveragePower',1)); % QAM modulation (Complex signal)
data = randi([0 M-1], 1, num_subcarriers); % Random symbols
qam_data = qammod(data, M, 'UnitAveragePower', true); % QAM modulation
scatterplot(qam_data);
title('16-QAM, Average Power = 1 W');

% Channel (random frequency-selective fading channel with num_taps taps)
h = (randn(1, num_taps) + 1i * randn(1, num_taps)) / sqrt(2 * num_taps); % Random channel impulse response
H = fft(h, num_subcarriers); % Channel frequency response

% Compute channel gain
channel_gain = abs(H).^2;

% Waterfilling power allocation
total_power = num_subcarriers; % Total transmit power
noise_power = total_power / db2pow(snr_db);
csi = channel_gain ./ noise_power; % channel gain to noise ratio
if strcmp(waterconfig,'bisect')
    power_alloc = waterfilling(csi,total_power);
else
    power_alloc = transpose(functionWaterfilling(total_power,(1./csi)'));
end

% Apply power allocation to the QAM-modulated data
tx_ofdm_waterfilled = sqrt(power_alloc) .* qam_data;

% Perform IFFT to get the time domain signal
tx_ofdm = ifft(tx_ofdm_waterfilled, num_subcarriers);

% Add cyclic prefix
tx_cp = [tx_ofdm(end-cp_len+1:end) tx_ofdm];

% Transmit through the channel
rx_signal = conv(tx_cp, h);
rx_signal = rx_signal(1:length(tx_cp));

% Add noise
noise = sqrt(noise_power/2) * (randn(size(rx_signal)) + 1i*randn(size(rx_signal)));
rx_signal = rx_signal + noise;

% Remove cyclic prefix
rx_signal = rx_signal(cp_len+1:end);

% Perform FFT to get the frequency domain signal
rx_ofdm = fft(rx_signal(1:num_subcarriers), num_subcarriers);

% Equalize the received signal
rx_ofdm_equalized = rx_ofdm .* conj(H) ./ channel_gain;

% Decode the received signal
received_data = rx_ofdm_equalized ./ sqrt(power_alloc);

% Demodulate the received QAM symbols
demodulated_data = qamdemod(received_data, M, 'UnitAveragePower', true);

disp(['Symbole Error rate [in percent]: ', num2str(sum(data ~= demodulated_data)/num_subcarriers * 100)]);