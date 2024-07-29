clear; clc; close all;
N = 64; % number of antennas
d_H = 1/2; % Normalized inter-element spacing

grid_angles = -pi/2:pi/180:pi/2;
grid_responses = exp(1i * 2 * pi * d_H * (0:N-1)' * sin(grid_angles));

AoA = pi/4;
response_vector = exp(1i * 2 * pi * d_H * (0:N-1)' * sin(AoA));

gain = abs(1/sqrt(N) * grid_responses' * response_vector).^2;

polarplot(grid_angles,pow2db(gain));
