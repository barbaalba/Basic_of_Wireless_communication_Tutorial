% This code is written to demonstrate the frequency offset effect that
% might exist between the Tx and Rx. This phenamena frequently happens due
% to inaccuracy in oscilator [Conclusion: when the length of singal 
% increased the effect is emphasized since the phase is accumulated]
close all; clear;clc;
% Parameters
Fs = 20e9;                % Sampling frequency (20 GHz)
Fc = 2e9;                 % Carrier frequency (2 GHz)
deltaF = 500;              % Frequency offset at the receiver
Rb = 1e6;                 % Bit rate (1 Mbps)
N = 2000;                  % Number of bits to transmit (0.6 ms)
Tb = 1/Rb;                % Bit duration
t = (0:Fs*N*Tb-1)/Fs;     % Time vector for all samples
samples_per_bit = Fs / Rb; % Number of samples per bit

% Generate random bits (0 or 1)
bits = randi([0 1], 1, N);

% BPSK Modulation
bpsk_signal = 2*bits - 1; % Convert bits to BPSK symbols (+1 or -1)

% Upsample the signal to match the sampling frequency
upsampled_signal = repelem(bpsk_signal, samples_per_bit);

% Carrier signal
carrier = cos(2*pi*Fc*t);

% Modulate the BPSK signal with the carrier
tx_signal = upsampled_signal .* carrier;

% Add noise (optional for realistic scenarios)
SNR = 30; % Signal-to-noise ratio in dB
rx_signal = awgn(tx_signal, SNR, 'measured');


%% Ideal Receiver 
% Receiver (Downconvert the signal back to baseband)
rx_mixed = rx_signal .* cos(2*pi*Fc*t);

% low pass filter to extract information from [-Rb/2,Rb/2] in baseband
% if you let higher freq pass as well, the error will increase as you
% include more noise into the system
[baseband_signal,digifilter] = lowpass(rx_mixed,Rb/2,Fs);

% Downsample to recover the original bits, we use averaging over symbol
% period
recovered_bits = zeros(1, N);
for i = 1:N
    % Extract samples corresponding to the i-th bit
    bit_samples = baseband_signal((i-1)*samples_per_bit+1:i*samples_per_bit);
    
    % Take the mean value over the bit duration
    bit_value = mean(bit_samples);
    
    % Decision: If the average is greater than 0, it's a '1', otherwise '0'
    recovered_bits(i) = bit_value > 0;
end
% The following method is prone to noise and not stable
%recovered_bits = baseband_signal(1:Fs/Rb:end) > 0;

% Compare transmitted and received bits
num_errors = sum(bits ~= recovered_bits);
ber = num_errors / N;

% Display results
disp(['Bit Error Rate (BER) in ideal scenario: ', num2str(ber)]);

% Plot signals [Uncomment if you want to see step by step results]
% figure;
% subplot(3,1,1);
% plot(t(1:5000), tx_signal(1:5000));
% title('Transmitted BPSK Signal (2 GHz carrier)');
% xlabel('Time (s)');
% ylabel('Amplitude');
% 
% subplot(3,1,2);
% plot(t(1:5000), rx_signal(1:5000));
% title('Received Signal (with noise)');
% xlabel('Time (s)');
% ylabel('Amplitude');
% 
% subplot(3,1,3);
% plot(t(1:5000), baseband_signal(1:5000));
% title('Baseband Signal (after demodulation and filtering)');
% xlabel('Time (s)');
% ylabel('Amplitude');

% Frequency domain representation
L = length(tx_signal);  % Signal length for FFT
f = (-L/2:L/2-1)*(Fs/L); % Frequency vector centered at 0 Hz

% FFT of transmitted and received baseband signals
tx_signal_fft = fftshift(fft(tx_signal, L));
% rx_mixed_fft = fftshift(fft(rx_mixed, L));
% baseband_signal_fft = fftshift(fft(baseband_signal, L));

% Plot frequency-domain signals
% figure;
% subplot(3,1,1);
% plot(f/1e6, abs(tx_signal_fft));
% title('Frequency Spectrum of Transmitted Signal');
% xlabel('Frequency (MHz)');
% ylabel('Magnitude');
% 
% subplot(3,1,2);
% plot(f/1e6, abs(rx_mixed_fft));
% title('Frequency Spectrum of Received Baseband Signal');
% xlabel('Frequency (MHz)');
% ylabel('Magnitude');
% 
% subplot(3,1,3);
% plot(f/1e6, abs(baseband_signal_fft));
% title('Frequency Spectrum of Filtered Baseband Signal');
% xlabel('Frequency (MHz)');
% ylabel('Magnitude');

% Filter response
% figure;
% freqz(digifilter, 1024, Fs);
%filterAnalyzer(digifilter,Analysis="magnitude",OverlayAnalysis="phase");

%% Receiver with frequency offset
%Receiver (Downconvert the signal back to baseband with frequecy drift)
rx_mixed_offset = rx_signal .* cos(2*pi*(Fc+deltaF)*t);

% low pass filter to extract information from [-Rb/2,Rb/2] in baseband
% if you let higher freq pass as well, the error will increase as you
% include more noise into the system
[baseband_signal_offset,digifilter] = lowpass(rx_mixed_offset,Rb/2,Fs);

% Downsample to recover the original bits
recovered_bits_offset = zeros(1, N);
for i = 1:N
    % Extract samples corresponding to the i-th bit
    bit_samples = baseband_signal_offset((i-1)*samples_per_bit+1:i*samples_per_bit);
    
    % Take the mean value over the bit duration
    bit_value = mean(bit_samples);
    
    % Decision: If the average is greater than 0, it's a '1', otherwise '0'
    recovered_bits_offset(i) = bit_value > 0;
end

% Compare transmitted and received bits
num_errors_offset = sum(bits ~= recovered_bits_offset);
ber_offset = num_errors_offset / N;

% Display results
disp(['Bit Error Rate (BER) when there is frequency offset: ', num2str(ber_offset)]);

% FFT of received baseband signals
rx_mixed_offset_fft = fftshift(fft(rx_mixed_offset, L));
baseband_signal_offset_fft = fftshift(fft(baseband_signal_offset, L));

% Plot frequency-domain signals when there is freq offset
figure;
subplot(3,1,1);
plot(f/1e6, abs(tx_signal_fft));
title('Frequency Spectrum of Transmitted Signal');
xlabel('Frequency (MHz)');
ylabel('Magnitude');

subplot(3,1,2);
plot(f/1e6, abs(rx_mixed_offset_fft));
title('Frequency Spectrum of Received Baseband Signal');
xlabel('Frequency (MHz)');
ylabel('Magnitude');

subplot(3,1,3);
plot(f/1e6, abs(baseband_signal_offset_fft));
title('Frequency Spectrum of Filtered Baseband Signal');
xlabel('Frequency (MHz)');
ylabel('Magnitude');

%% Receiver with frequency offset but ideal filter
baseband_signal_offset = upsampled_signal .* cos(2*pi*deltaF*t);

% Downsample to recover the original bits
recovered_bits_offset = zeros(1, N);
for i = 1:N
    % Extract samples corresponding to the i-th bit
    bit_samples = baseband_signal_offset((i-1)*samples_per_bit+1:i*samples_per_bit);
    
    % Take the mean value over the bit duration
    bit_value = mean(bit_samples);
    
    % Decision: If the average is greater than 0, it's a '1', otherwise '0'
    recovered_bits_offset(i) = bit_value > 0;
end

% Compare transmitted and received bits
num_errors_offset = sum(bits ~= recovered_bits_offset);
ber_offset = num_errors_offset / N;

% Display results
disp(['Bit Error Rate (BER) when there is frequency offset and ideal filter: ', num2str(ber_offset)]);

% The accumulated phase shift in time, when the cosine changes the sign it
% changes the phase and mess the system
figure;
plot(t,cos(2*pi*deltaF*t));
hold on;
plot(t(Fs/(4*deltaF): 3*Fs/(4*deltaF)),cos(2*pi*deltaF*t(Fs/(4*deltaF):3*Fs/(4*deltaF))) ,'r');
xlabel('Time','FontSize',20,'Interpreter','latex');
ylabel('$cos(2\pi \Delta f t)$','FontSize',20,'Interpreter','latex');