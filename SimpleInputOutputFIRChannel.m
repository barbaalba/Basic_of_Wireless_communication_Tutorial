clear;clc;close all;
% Define signal type (sine or random)
sigshape = "sin";

% Define the number of taps in the FIR filter (channel impulse response)
num_taps = 10;

% Generate random complex gains for each tap (channel coefficients)
h = (randn(1, num_taps) + 1i*randn(1, num_taps)) / sqrt(2*num_taps);

% Normalize the channel to ensure unit power
h = h / norm(h);
h = sort(h,'descend');

% Generate a transmitted signal (for example, a random signal)
N = 100; % length of the transmitted signal
if sigshape == "sin"
    fs = 1000; % sampling frequency in Hz
    f = 50; % frequency of the sine wave in Hz
    t = (0:N-1)/fs; % time vector
    tx_signal = sin(2*pi*f*t); % real sine wave
else
    tx_signal = randn(1, N) + 1i*randn(1, N);
end
% Pass the transmitted signal through the channel
rx_signal = conv(tx_signal, h);

% Truncate the received signal to the original signal length (if desired)
rx_signal = rx_signal(1:N);

% Plot the transmitted and received signals
figure;
subplot(2, 1, 1);
plot(real(tx_signal), 'b');
title('Transmitted Signal (Real Part)');
xlabel('Sample Index');
ylabel('Amplitude');

subplot(2, 1, 2);
plot(real(rx_signal), 'r');
title('Received Signal (Real Part)');
xlabel('Sample Index');
ylabel('Amplitude');

% Plot the channel impulse response
figure;
stem(abs(h));
title('Channel Impulse Response (Magnitude)');
xlabel('Tap Index');
ylabel('Magnitude');